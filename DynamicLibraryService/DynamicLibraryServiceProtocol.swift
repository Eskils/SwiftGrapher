//
//  DynamicLibraryServiceProtocol.swift
//  DynamicLibraryService
//
//  Created by Eskil Gjerde Sviggum on 12/02/2024.
//

import Foundation

@objc protocol DynamicLibraryServiceProtocol {
    
    @objc
    func openLibrary(withURL libraryURL: URL)
    
    @objc
    func symbol(named name: String, reply: @escaping (Int) -> Void)
    
    @objc
    func calculation(x: Double, reply: @escaping (Double) -> Void)
}
