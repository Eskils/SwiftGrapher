//
//  ViewController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import Cocoa

class ViewController: NSViewController {
    
    let compilerService = SwiftCompilerServiceImpl()

    @IBOutlet var textView: NSTextView!
    
    @IBOutlet var compileButton: NSButtonCell!
    
    @IBOutlet var graphViewContainer: GraphView!
    
    var dylibHandler: DynamicLibraryHandler?
    
    var calculationHandler: (@convention(c)(Double) -> Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.string = """
        import Foundation
        
        @_cdecl("calculation")
        public func calculation(x: Double) -> Double {
            return 100 * sin(x)
        }
        """

        compileButton.target = self
        compileButton.action = #selector(compile)
        
        graphViewContainer.dataSource = self
        graphViewContainer.clipsToBounds = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc
    private func compile() {
        let text = textView.string
        do {
            let libraryURL = try compilerService.compile(text: text)
            execute(libraryURL: libraryURL)
            graphViewContainer.display()
        } catch {
            print("Could not compile: \(error)")
        }
    }
    
    private func execute(libraryURL: URL) {
        self.calculationHandler = nil
        self.dylibHandler?.close()
        self.dylibHandler = nil
        
        let dylibHandler = DynamicLibraryHandler(libraryURL: libraryURL)
        guard let symbol = dylibHandler.symbol(named: "calculation") else {
            Logger.log("Could not find required symbol.")
            return
        }
        
        typealias CalculationSignature = @convention(c)(Double) -> Double
        let handler = unsafeBitCast(symbol, to: CalculationSignature.self)
        
        Logger.log("Found calculation symbol")
        
        self.dylibHandler = dylibHandler
        self.calculationHandler = handler
    }

}

extension ViewController: GraphViewDataSource {
    
    func graph(_ graphView: GraphView, valueForX x: Double) -> Double {
        guard let calculationHandler else {
            return 0
        }
        
        return calculationHandler(x)
    }
    
}
