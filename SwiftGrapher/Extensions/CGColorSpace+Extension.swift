//
//  CGColorSpace+Extension.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation
import CoreGraphics

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
