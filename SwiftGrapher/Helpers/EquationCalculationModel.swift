//
//  EquationCalculationModel.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation
import CoreGraphics

final class EquationCalculationModel {
    
    private let compilerService: SwiftCompilerService
    private let equation: Equation
    
    init(compilerService: SwiftCompilerService, equation: Equation) {
        self.compilerService = compilerService
        self.equation = equation
    }
    
    private var dylibHandler: DynamicLibraryHandler?
    
    var calculationHandler: (@convention(c)(Double) -> Double)?
    
    var color: CGColor {
        equation.color
    }
    
    var id: String {
        equation.id
    }
    
    var contents: String {
        equation.contents
    }
    
    var name: String? {
        equation.name
    }
    
    var isEnabled: Bool {
        equation.isEnabled
    }
    
    var currentVersionIsCompiled = false
    
    var needsRecompilation: Bool {
        isEnabled && !currentVersionIsCompiled
    }
    
    func updateContents(contents: String) {
        equation.contents = contents
        currentVersionIsCompiled = false
    }
    
    func compile() throws {
        let text = equation.contents
        let libraryURL = try compilerService.compile(text: text)
        execute(libraryURL: libraryURL)
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
