//
//  Equation.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 27/01/2024.
//

import Foundation
import CoreGraphics

class Equation: Encodable, Decodable {
    let id: String
    
    var name: String?
    
    var color: CGColor
    
    var isEnabled: Bool
    
    var contents: String
    
    private init(id: String, name: String?, color: CGColor, isEnabled: Bool, contents: String) {
        self.id = id
        self.name = name
        self.color = color
        self.isEnabled = isEnabled
        self.contents = contents
    }
    
    static func emptyWithRandomColor() -> Equation {
        let colorValues = SIMD4<Double>(SIMD4(x: UInt8.random(in: 20..<180), y: UInt8.random(in: 20..<180), z: UInt8.random(in: 20..<180), w: 255)) / 255
        let color = CGColor(red: colorValues.x, green: colorValues.y, blue: colorValues.z, alpha: colorValues.w)
        
        return Equation(
            id: UUID().uuidString,
            name: nil,
            color: color,
            isEnabled: true,
            contents: Constants.defaultEquationImplementation
        )
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.color = try container.decodeStatically(CGColor.self, forKey: .color)
        self.isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        self.contents = try container.decode(String.self, forKey: .contents)
    }
    
}
