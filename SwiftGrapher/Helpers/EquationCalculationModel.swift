//
//  EquationCalculationModel.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation
import CoreGraphics

final class DynamicLibraryService {
    
    var connection: NSXPCConnection
    var proxy: DynamicLibraryServiceProtocol?
    
    init(libraryURL: URL) {
        let interface = NSXPCInterface(with: DynamicLibraryServiceProtocol.self)
        let connection = NSXPCConnection(serviceName: "com.skillbreak.DynamicLibraryService")
        connection.remoteObjectInterface = interface
        
        self.connection = connection
        
        guard let proxy = connection.remoteObjectProxy as? DynamicLibraryServiceProtocol else {
            assertionFailure()
            return
        }
        self.proxy = proxy
        
        connection.interruptionHandler = {
            print("Did interrupt")
        }
        
        connection.resume()
        
        print("XPC PID: ", connection.processIdentifier)
        
        proxy.openLibrary(withURL: libraryURL)
    }
    
    deinit {
        connection.invalidate()
    }
    
    func symbol(named name: String) async -> UnsafeMutableRawPointer? {
        await withCheckedContinuation { continuation in
            proxy?.symbol(named: name, reply: { result in
                continuation.resume(returning: UnsafeMutableRawPointer(bitPattern: result))
            })
        }
    }
    
    func calculation(x: Double) async -> Double {
        await withCheckedContinuation { continuation in
            proxy?.calculation(x: x, reply: { result in
                continuation.resume(returning: result)
            })
        }
    }
    
    func close() {
        connection.invalidate()
    }
    
}

final class EquationCalculationModel {
    
    private let compilerService: SwiftCompilerService
    private let equation: Equation
    
    init(compilerService: SwiftCompilerService, equation: Equation) {
        self.compilerService = compilerService
        self.equation = equation
    }
    
    private var dylibHandler: DynamicLibraryService?
    
    var calculationHandler: ((Double) async -> Double)?
    
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
    
    func compile() async throws {
        let text = equation.contents
        let libraryURL = try compilerService.compile(text: text)
        await execute(libraryURL: libraryURL)
    }
    
    private func execute(libraryURL: URL) async {
        self.calculationHandler = nil
        self.dylibHandler?.close()
        self.dylibHandler = nil
        
        let dylibHandler = DynamicLibraryService(libraryURL: libraryURL)
        
//        guard let symbol = await dylibHandler.symbol(named: "$s4main11calculation1xS2d_tF") else {
//            Logger.log("Could not find required symbol.")
//            return
//        }
//        
//        typealias CalculationSignature = @convention(c)(Double) -> Double
//        let handler = unsafeBitCast(symbol, to: CalculationSignature.self)
        
        Logger.log("Found calculation symbol")
        
        self.dylibHandler = dylibHandler
        self.calculationHandler = dylibHandler.calculation(x:)
    }
}
