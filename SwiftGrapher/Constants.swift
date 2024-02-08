//
//  Constants.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation

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
    
}
