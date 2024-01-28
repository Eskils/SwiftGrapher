//
//  Constants.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation

struct Constants {
    
    private init() {}
    
    static let defaultEquationImplementation = 
    """
    import Foundation
    
    @_cdecl("calculation")
    public func calculation(x: Double) -> Double {
        return 100 * sin(x)
    }
    """
    
}
