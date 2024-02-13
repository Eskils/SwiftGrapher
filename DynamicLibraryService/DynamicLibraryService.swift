//
//  DynamicLibraryService.swift
//  DynamicLibraryService
//
//  Created by Eskil Gjerde Sviggum on 12/02/2024.
//

import Foundation

class DynamicLibraryService: NSObject, DynamicLibraryServiceProtocol {
    
    private var handler: DynamicLibraryHandler?
    private var calculationHandler: (@convention(c)(Double) -> Double)?
    
    func openLibrary(withURL libraryURL: URL) {
        handler = DynamicLibraryHandler(libraryURL: libraryURL)
        
        guard let symbol = handler?.symbol(named: "$s4main11calculation1xS2d_tF") else {
            Logger.log("Could not find required symbol.")
            return
        }
        
        typealias CalculationSignature = @convention(c)(Double) -> Double
        let handler = unsafeBitCast(symbol, to: CalculationSignature.self)
        
        self.calculationHandler = handler
    }
    
    func symbol(named name: String, reply: @escaping (Int) -> Void) {
        let address = handler?.symbol(named: name)
        reply(address.map { Int(bitPattern: $0) } ?? 0)
    }
    
    func calculation(x: Double, reply: @escaping (Double) -> Void) {
        reply(calculationHandler?(x) ?? 0)
    }
    
}
