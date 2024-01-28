//
//  StaticallyDecodable.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation

protocol StaticallyDecodable {
    static func from(decoder: Decoder) throws -> Self
}

extension KeyedDecodingContainer {
    
    func decodeStatically<T>(_ type: T.Type, forKey key: Self.Key) throws -> T where T: StaticallyDecodable {
        let decoder = try superDecoder(forKey: key)
        return try type.from(decoder: decoder)
    }
    
}
