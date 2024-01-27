//
//  GraphView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import AppKit

class GraphView: TransformManager {
    
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
    
    private func drawFunction() {
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
            
            let y = scale * dataSource.graph(self, valueForX: x) + transformAnchorPoint.y * height + translation.y
            let point = CGPoint(x: drawX, y: y)
            print(x, y)
            
            // FIXME: Use vertical asymptotic analysis to determine
            if y.isInfinite || y.isNaN || y > height || y < -height {
                if y > height {
                    skipPointCap = height
                } else {
                    skipPointCap = -height
                }
                
                if !didSkipPoint {
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
        
        NSColor.systemBlue.setStroke()
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
        drawFunction()
    }
    
}

protocol GraphViewDataSource: AnyObject {
    
    func graph(_ graphView: GraphView, valueForX x: Double) -> Double
    
}

class TransformManager: NSView {
    
    private enum TransformMode {
        case translation
        case scale
        case idle
    }
    
    let scrollView = NSScrollView()
    let contentView = NSView()
    var translationMagnitude: Int = 1000
    var transformAnchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var didResetTransform: Bool = false
    
    private var translationAccumulated: CGPoint = .zero
    var translation: CGPoint = .zero
    var scale: CGFloat = 1
    private var transformMode: TransformMode = .idle
    
    lazy var startpnt = CGPoint(x: magnitude() * transformAnchorPoint.x, y: magnitude() * transformAnchorPoint.y)
    private var startScale = 1.0
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.addSubview(scrollView)
        scrollView.documentView = contentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        scrollView.contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.verticalScrollElasticity = .none
        scrollView.horizontalScrollElasticity = .none
        scrollView.usesPredominantAxisScrolling = false
        scrollView.allowsMagnification = true
        scrollView.minMagnification = 0.1
        scrollView.maxMagnification = 100
        
        didResetTransform = true
        
        configureScrollView(scrollView)
        
        scrollView.contentView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidStartScrolling(notification:)),
            name: NSScrollView.willStartLiveScrollNotification,
            object: scrollView
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidStartMagnification(notification:)),
            name: NSScrollView.willStartLiveMagnifyNotification,
            object: scrollView
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidEndMagnification(notification:)),
            name: NSScrollView.didEndLiveMagnifyNotification,
            object: scrollView
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidScroll(notification:)),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func magnitude(offset: CGFloat = 0) -> CGFloat {
        return 2 * CGFloat(translationMagnitude) + offset
    }
    
    override func layoutSubtreeIfNeeded() {
        super.layoutSubtreeIfNeeded()
        
        configureScrollView(scrollView)
    }
    
    func configureScrollView(_ scrollView: NSScrollView) {
        let contentSize = CGSize(width: magnitude(offset: self.bounds.width), height: magnitude(offset: self.bounds.width))
        let contentOffset = CGPoint(x: magnitude() * -transformAnchorPoint.x, y: magnitude() * -transformAnchorPoint.y)
        contentView.frame = CGRect(origin: contentOffset, size: contentSize)
    }
    
    @objc 
    private func scrollViewDidScroll(notification: NSNotification) {
        if notification.object as? NSObject != scrollView.contentView {
            return
        }
        
        print("magnification: \(scrollView.magnification)")
        print("translation: \(translation)")
        
        switch transformMode {
        case .translation:
            scrollViewDidScroll(scrollView)
        case .scale:
            scale = scrollView.magnification
            let locationInWindow = NSEvent.mouseLocation
            let translation = convertWindowLocationToTransformPoint(locationInWindow)
            let deltaScale = scrollView.magnification - startScale
            let t = deltaScale
            print(t)
            self.translation = CGPoint(x: translationAccumulated.x - t * translation.x, y: translationAccumulated.y - t * translation.y)
            
            didUpdateTranslationOrScale()
        case .idle:
            break
        }
    }
    
    @objc
    private func scrollViewDidStartScrolling(notification: NSNotification) {
        if notification.object as? NSObject != scrollView {
            return
        }
        
        transformMode = .idle
        scrollView.contentView.bounds.origin = .zero
        
        let off = scrollView.contentView.bounds.origin
        startpnt = off
        translationAccumulated = translation
        
        print("Did start scroll")
        transformMode = .translation
    }
    
    @objc
    private func scrollViewDidStartMagnification(notification: NSNotification) {
        if notification.object as? NSObject != scrollView {
            return
        }
        
        transformMode = .idle
        print("Did start magnification")
        translationAccumulated = translation
        startScale = scrollView.magnification
        transformMode = .scale
    }
    
    @objc
    private func scrollViewDidEndMagnification(notification: NSNotification) {
        if notification.object as? NSObject != scrollView {
            return
        }
        
        print("Did finish magnification")
        transformMode = .idle
        translationAccumulated = translation
        startScale = scrollView.magnification
    }
    
    private func scrollViewDidScroll(_ scrollView: NSScrollView) {
        
        if didResetTransform {
            didResetTransform = false
            return
        }
        
        let off = scrollView.contentView.bounds.origin
        
        if off == startpnt { translationAccumulated = .zero; return }
        
        let deltaOffset = SIMD2(x: off.x - startpnt.x, y: off.y - startpnt.y) * startScale
        
        translation = CGPoint(x: translationAccumulated.x + deltaOffset.x, y: translationAccumulated.y + deltaOffset.y)
        
        didUpdateTranslationOrScale()
    }
    
    open func didUpdateTranslationOrScale() {}
    
    override func mouseDown(with event: NSEvent) {
        let locationInWindow = NSEvent.mouseLocation
        let translation = convertWindowLocationToTransformPoint(locationInWindow)
        print(translation)
    }
    
    private func convertWindowLocationToTransformPoint(_ locationInWindow: CGPoint) -> CGPoint {
        let originX = (self.frame.width * transformAnchorPoint.x + translationAccumulated.x)
        let originY = (self.frame.height * transformAnchorPoint.y + translationAccumulated.y)
        let screenRect = CGRect(origin: locationInWindow, size: CGSize(width: 1, height: 1));
        let baseRect = self.window?.convertFromScreen(screenRect) ?? screenRect
        let locationInView = self.convert(baseRect.origin, from: nil)
        let location = SIMD2(x: locationInView.x - originX, y: locationInView.y - originY) / startScale
        return CGPoint(x: location.x, y: location.y)
    }
    
}
