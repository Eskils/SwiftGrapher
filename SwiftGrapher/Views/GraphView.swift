//
//  GraphView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import AppKit

final class GraphView: TransformManager {
    
    weak var dataSource: GraphViewDataSource?
    
    @Invalidating(.display)
    var functionLineWidth: Double = 2
    
    @Invalidating(.display)
    var showAxes: Bool = true
    
    var horizontalUnitSize: CGFloat = 40.0
    
    var verticalUnitSize: CGFloat = 40.0
    
    var isScrollEnabled: Bool = true {
        didSet {
            self.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    private func drawAxes(context: CGContext) {
        let width = self.frame.width
        let height = self.frame.height
        
        let verticalBarPath = CGMutablePath()
        let verticalBaseX = (width * transformAnchorPoint.x + translation.x)
        verticalBarPath.move(to: CGPoint(x: verticalBaseX, y: 0))
        verticalBarPath.addLine(to: CGPoint(x: verticalBaseX, y: height))
        
        let horizontalBarPath = CGMutablePath()
        let horizontalBaseY = (height * transformAnchorPoint.y + translation.y)
        horizontalBarPath.move(to: CGPoint(x: 0, y: horizontalBaseY))
        horizontalBarPath.addLine(to: CGPoint(x: width, y: horizontalBaseY))
        
        context.setStrokeColor(NSColor.lightGray.cgColor)
        context.setLineWidth(1)
        
        context.addPath(verticalBarPath)
        context.strokePath()
        
        context.addPath(horizontalBarPath)
        context.strokePath()
    }
    
    private func drawAxisNumbers(context: CGContext) {
        let width = self.frame.width
        let height = self.frame.height
        
        let verticalBaseX = (width * transformAnchorPoint.x + translation.x)
        let horizontalBaseY = (height * transformAnchorPoint.y + translation.y)
        let origin = CGPoint(x: verticalBaseX, y: horizontalBaseY)
        
        let deltaSteps = if scale < 1 {
            floor(1.0 / scale)
        } else {
            1 / floor(scale)
        }
        
        drawHorizontalAxisNumbers(context: context, origin: origin, deltaSteps: deltaSteps, width: width)
        
        drawVerticalAxisNumbers(context: context, origin: origin, deltaSteps: deltaSteps, height: height)
    }
    
    private func drawHorizontalAxisNumbers(context: CGContext, origin: CGPoint, deltaSteps: CGFloat, width: CGFloat) {
        let range = functionRange(width: width, scale: 2)
        let iterations = (range.upperBound - range.lowerBound) / deltaSteps
        let drawDelta = self.frame.width / iterations * 2
        
        var x = range.lowerBound < 0 ? floor(range.lowerBound) : ceil(range.lowerBound / scale) + deltaSteps
        let numIterationsForOrigin = x / deltaSteps
        var drawX = origin.x + drawDelta * numIterationsForOrigin
        
        for _ in 0..<Int(ceil(iterations)) {
            
            defer {
                x += deltaSteps
                drawX += drawDelta
            }
            
            let drawPoint = CGPoint(x: drawX, y: origin.y)
            let padding = CGPoint(x: x == 0 ? -16 : 0, y: -16)
            drawAxisNumber(context: context, number: x, atPoint: drawPoint, padding: padding)
             
        }
    }
    
    private func drawVerticalAxisNumbers(context: CGContext, origin: CGPoint, deltaSteps: CGFloat, height: CGFloat) {
        let range = verticalFunctionRange(height: height, scale: 2)
        let iterations = (range.upperBound - range.lowerBound) / deltaSteps
        let drawDelta = self.frame.height / iterations * 2
        
        var y = range.lowerBound < 0 ? floor(range.lowerBound) : ceil(range.lowerBound / scale) + deltaSteps
        let numIterationsForOrigin = y / deltaSteps
        var drawY = origin.y + drawDelta * numIterationsForOrigin
        
        for _ in 0..<Int(ceil(iterations)) {
            
            defer {
                y += deltaSteps
                drawY += drawDelta
            }
            
            if y == 0 {
                continue
            }
            
            let drawPoint = CGPoint(x: origin.x, y: drawY)
            let padding = CGPoint(x: -16, y: 0)
            drawAxisNumber(context: context, number: y, atPoint: drawPoint, padding: padding)
             
        }
    }
    
    private func drawAxisNumber(context: CGContext, number x: CGFloat, atPoint point: CGPoint, padding: CGPoint) {
        let frac = floor(abs(x - floor(x)) * 1000) / 1000
        let dSigfigs = (frac == 0) ? 0 : ceil(abs(log(frac)))
        let sigfigs = min(3, !dSigfigs.isFinite ? 0 : Int(dSigfigs))
        let text = String(format: "%.\(sigfigs)f", x)
        drawText(context: context, text: text, point: point, padding: padding)
    }
    
    private func drawText(context: CGContext, text: String, point: CGPoint, padding: CGPoint = .zero) {
        let color = NSColor.textColor.cgColor
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: color]
        let attributedString = NSAttributedString(string: text,
                                                  attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)
        context.textPosition = CGPoint(x: point.x + padding.x,
                                       y: point.y + padding.y)
        CTLineDraw(line, context)
    }
    
    private func drawFunctions(context: CGContext) {
        guard let dataSource else {
            return
        }
        
        let numberOfFunctions = dataSource.numberOfGraphs(in: self)
        for index in 0..<numberOfFunctions {
            if !dataSource.graph(self, showGraph: index) {
                continue
            }
            
            drawFunction(context: context, withIndex: index)
        }
    }
    
    private func drawFunction(context: CGContext, withIndex index: Int) {
        guard let dataSource else {
            return
        }
        
        let width = self.frame.width
        let height = self.frame.height
        
        let range = functionRange(width: width)
        
        let functionPath = CGMutablePath()
        
        let deltaSteps = 2 * .pi * max(1, scale)
        let delta = 1 / Double(deltaSteps)
        let iterations = deltaSteps * (range.upperBound - range.lowerBound)
        let drawDelta = self.frame.width / iterations
        
        var x = Double(range.lowerBound)
        var drawX = 0.0
        var didSkipPoint = false
        var skipPointCap = 0.0
        
        for _ in 0...Int(ceil(iterations)) {
            
            defer {
                x += delta
                drawX += drawDelta
            }
            
            let y = verticalUnitSize * scale * dataSource.graph(self, valueForGraph: index, x: x) + transformAnchorPoint.y * height + translation.y
            let point = CGPoint(x: drawX, y: y)
            
            // FIXME: Use vertical asymptotic analysis to determine
            if y.isInfinite || y.isNaN || y > height || y < -height {
                if y > height {
                    skipPointCap = height
                } else {
                    skipPointCap = -height
                }
                
                if !didSkipPoint && !functionPath.isEmpty {
                    functionPath.addLine(to: CGPoint(x: drawX, y: skipPointCap))
                }
                
                didSkipPoint = true
                
                continue
            }
            
            if didSkipPoint {
                functionPath.move(to: CGPoint(x: drawX - drawDelta, y: skipPointCap))
                functionPath.addLine(to: CGPoint(x: drawX, y: skipPointCap))
                didSkipPoint = false
            }
            
            if functionPath.isEmpty {
                functionPath.move(to: point)
            } else {
                functionPath.addLine(to: point)
            }
        }
        
        let color = dataSource.graph(self, colorForGraph: index)
        
        context.setStrokeColor(color)
        context.setLineWidth(functionLineWidth)
        context.setLineCap(.round)
        
        context.addPath(functionPath)
        context.strokePath()
    }
    
    private func functionRange(width: CGFloat, scale finalScale: CGFloat = 1) -> Range<CGFloat> {
        let midWidth = width / 2
        let horizontalScale = horizontalUnitSize * scale
        let horizontalScaleFactor = 1 / horizontalScale
        
        let start = (-midWidth - translation.x) * horizontalScaleFactor * finalScale
        let end = (midWidth - translation.x) * horizontalScaleFactor * finalScale
        let range = start..<end
        
        return range
    }
    
    private func verticalFunctionRange(height: CGFloat, scale finalScale: CGFloat = 1) -> Range<CGFloat> {
        let midHeight = height / 2
        let verticalScale = verticalUnitSize * scale
        let verticalScaleFactor = 1 / verticalScale
        
        let start = (-midHeight - translation.y) * verticalScaleFactor * finalScale
        let end = (midHeight - translation.y) * verticalScaleFactor * finalScale
        let range = start..<end
        
        return range
    }
    
    override func didUpdateTranslationOrScale() {
        super.didUpdateTranslationOrScale()
        
        self.display()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }
        
        if showAxes {
            drawAxes(context: context)
            drawAxisNumbers(context: context)
        }
        drawFunctions(context: context)
    }
    
}

protocol GraphViewDataSource: AnyObject {
    
    func numberOfGraphs(in graphView: GraphView) -> Int
    func graph(_ graphView: GraphView, valueForGraph graphIndex: Int, x: Double) -> Double
    func graph(_ graphView: GraphView, colorForGraph graphIndex: Int) -> CGColor
    func graph(_ graphView: GraphView, showGraph graphIndex: Int) -> Bool
    
}
