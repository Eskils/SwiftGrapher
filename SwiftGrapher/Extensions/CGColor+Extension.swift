//
//  CGColor+Extension.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation
import CoreGraphics

extension CGColor: Encodable, StaticallyDecodable {
    enum CodingKeys: String, CodingKey {
        case colorSpace, components
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(colorSpace, forKey: .colorSpace)
        try container.encodeIfPresent(components, forKey: .components)
    }
    
    static func from(decoder: Decoder) throws -> Self {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let colorSpace = try container.decodeStatically(CGColorSpace.self, forKey: .colorSpace)
        let components = try container.decode([CGFloat].self, forKey: .components)
        
        let color = try components.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress else {
                throw DecodeError.componentsDoesNotHaveABaseAddress
            }
            return CGColor(colorSpace: colorSpace, components: baseAddress.assumingMemoryBound(to: CGFloat.self))
        }
        
        guard let color = color as? Self else {
            throw DecodeError.cannotCreateColorFromColorSpaceAndComponents
        }
        
        return color
    }
    
    enum DecodeError: Error {
        case componentsDoesNotHaveABaseAddress
        case cannotCreateColorFromColorSpaceAndComponents
    }
    
}
