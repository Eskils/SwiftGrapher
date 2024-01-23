//
//  GraphView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import AppKit

class GraphView: TransformManager {
    
    weak var dataSource: GraphViewDataSource?
    
    private var imageToDraw: CGImage?
    
    private func drawAxes() {
        let width = self.frame.width
        let height = self.frame.height
        
        let verticalBarPath = CGMutablePath()
        verticalBarPath.move(to: CGPoint(x: width * transformAnchorPoint.x + translation.x, y: 0))
        verticalBarPath.addLine(to: CGPoint(x: width * transformAnchorPoint.x + translation.x, y: height))
        
        let horizontalBarPath = CGMutablePath()
        horizontalBarPath.move(to: CGPoint(x: 0, y: height * transformAnchorPoint.y + translation.y))
        horizontalBarPath.addLine(to: CGPoint(x: width, y: height * transformAnchorPoint.y + translation.y))
        
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
        let horizontalScale = 10.0
        let horizontalScaleFactor = 1 / horizontalScale
        
        let functionPath = CGMutablePath()
        let start = (-midWidth - translation.x) * horizontalScaleFactor
        let end = (midWidth - translation.x) * horizontalScaleFactor
        let range = start..<end
        
        let deltaSteps = 10.0
        let delta = 1 / Double(deltaSteps)
        let iterations = deltaSteps * (range.upperBound - range.lowerBound)
        let drawDelta = self.frame.width / iterations
        
        var x = Double(range.lowerBound)
        var drawX = 0.0
        
        for _ in 0..<Int(ceil(iterations)) {
            let y = dataSource.graph(self, valueForX: x) + transformAnchorPoint.y * height + translation.y
            let point = CGPoint(x: drawX, y: y)
            
            if functionPath.isEmpty {
                functionPath.move(to: point)
            } else {
                functionPath.addLine(to: point)
            }
            
            x += delta
            drawX += drawDelta
        }
        
        NSColor.systemBlue.setStroke()
        let functionNS = NSBezierPath(cgPath: functionPath)
        functionNS.lineWidth = 2
        functionNS.stroke()
    }
    
    private func makeGraphicsContext() -> CGContext? {
        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        let bitmapBytesPerRow = width * 4

        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        return CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
              bitmapInfo: bitmapInfo.rawValue
        )
    }
    
    override func scrollViewDidScroll(_ scrollView: NSScrollView) {
        super.scrollViewDidScroll(scrollView)
        
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
    
    let scrollView = NSScrollView()
    let contentView = NSView()
    var translationMagnitude: Int = 1000
    var transformAnchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var didResetTransform: Bool = false
    
    private var translationAccumulated: CGPoint = .zero
    var translation: CGPoint = .zero
    
    
    lazy var startpnt = CGPoint(x: magnitude() * transformAnchorPoint.x, y: magnitude() * transformAnchorPoint.y)
    
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
        
        scrollViewDidScroll(scrollView)
    }
    
    @objc
    func scrollViewDidStartScrolling(notification: NSNotification) {
        if notification.object as? NSObject != scrollView {
            return
        }
        
        scrollView.contentView.bounds.origin = .zero
        
        let off = scrollView.contentView.bounds.origin
        startpnt = off
        translationAccumulated = translation
    }
    
    func scrollViewDidScroll(_ scrollView: NSScrollView) {
        
        if didResetTransform {
            didResetTransform = false
            return
        }
        
        let off = scrollView.contentView.bounds.origin
        
        if off == startpnt { translationAccumulated = .zero; return }
        
        let deltaOffset = CGPoint(x: off.x - startpnt.x, y: off.y - startpnt.y)
        
        translation = CGPoint(x: translationAccumulated.x + deltaOffset.x, y: translationAccumulated.y + deltaOffset.y)
    }
    
}
