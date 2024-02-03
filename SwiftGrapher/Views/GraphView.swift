//
//  GraphView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import AppKit

final class GraphView: TransformManager {
    
    weak var dataSource: GraphViewDataSource?
    
    private func drawAxes() {
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
        
        NSColor.lightGray.setStroke()
        NSBezierPath(cgPath: verticalBarPath).stroke()
        NSBezierPath(cgPath: horizontalBarPath).stroke()
    }
    
    private func drawFunctions() {
        guard let dataSource else {
            return
        }
        
        let numberOfFunctions = dataSource.numberOfGraphs(in: self)
        for index in 0..<numberOfFunctions {
            if !dataSource.graph(self, showGraph: index) {
                continue
            }
            
            drawFunction(withIndex: index)
        }
    }
    
    private func drawFunction(withIndex index: Int) {
        guard let dataSource else {
            return
        }
        
        let width = self.frame.width
        let height = self.frame.height
        
        let midWidth = width / 2
        let horizontalScale = 10.0 * scale
        let horizontalScaleFactor = 1 / horizontalScale
        
        let functionPath = CGMutablePath()
        let start = (-midWidth - translation.x) * horizontalScaleFactor
        let end = (midWidth - translation.x) * horizontalScaleFactor
        let range = start..<end
        
        let deltaSteps = 6.0 * scale
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
            
            let y = scale * dataSource.graph(self, valueForGraph: index, x: x) + transformAnchorPoint.y * height + translation.y
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
        NSColor(cgColor: color)?.setStroke()
        let functionNS = NSBezierPath(cgPath: functionPath)
        functionNS.lineWidth = 2
        functionNS.stroke()
    }
    
    override func didUpdateTranslationOrScale() {
        super.didUpdateTranslationOrScale()
        
        self.display()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        drawAxes() 
        drawFunctions()
    }
    
}

protocol GraphViewDataSource: AnyObject {
    
    func numberOfGraphs(in graphView: GraphView) -> Int
    func graph(_ graphView: GraphView, valueForGraph graphIndex: Int, x: Double) -> Double
    func graph(_ graphView: GraphView, colorForGraph graphIndex: Int) -> CGColor
    func graph(_ graphView: GraphView, showGraph graphIndex: Int) -> Bool
    
}
