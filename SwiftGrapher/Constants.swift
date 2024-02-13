//
//  Constants.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation
import AppKit

struct Constants {
    
    private init() {}
    
    static let defaultEquationImplementation = {
        guard
            let url = Bundle.main.url(forResource: "DefaultEquation", withExtension: "txt"),
            let data = try? Data(contentsOf: url),
            let text = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        
        return text
    }()
    
    static let defaultEquationColors = [
        NSColor.EquationColors.aOrange,
        NSColor.EquationColors.bLemon,
        NSColor.EquationColors.cLime,
        NSColor.EquationColors.dMoss,
        NSColor.EquationColors.eCyan,
        NSColor.EquationColors.fBlue,
        NSColor.EquationColors.gLavender,
        NSColor.EquationColors.hStrawberry,
    ]
    
}
