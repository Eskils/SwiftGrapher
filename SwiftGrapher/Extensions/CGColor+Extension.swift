//
//  CGColor+Extension.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation
import CoreGraphics

protocol StaticallyDecodable {
    static func from(decoder: Decoder) throws -> Self
}

extension CGColorSpace: Encodable, StaticallyDecodable {
    
    enum CodingKeys: String, CodingKey {
        case iccData, name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = self.copyICCData() as? Data
        
        try container.encodeIfPresent(data, forKey: .iccData)
        try container.encodeIfPresent(name as? String , forKey: .name)
    }
    
    static func from(decoder: Decoder) throws -> Self {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let iccData = try container.decodeIfPresent(Data.self, forKey: .iccData),
           let cfData = Optional(iccData as CFData),
           let colorSpace = CGColorSpace(iccData: cfData) as? Self {
            return colorSpace
        } else if let name = try container.decodeIfPresent(String.self, forKey: .name),
                  let colorSpace = CGColorSpace(name: name as CFString) as? Self {
            return colorSpace
        }
        
        throw DecodeError.cannotDecodeColorSpaceFromICCDataNorName
    }
    
    enum DecodeError: Error {
        case cannotDecodeColorSpaceFromICCDataNorName
    }
    
}

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

extension KeyedDecodingContainer {
    
    func decodeStatically<T>(_ type: T.Type, forKey key: Self.Key) throws -> T where T: StaticallyDecodable {
        let decoder = try superDecoder(forKey: key)
        return try type.from(decoder: decoder)
    }
    
}
