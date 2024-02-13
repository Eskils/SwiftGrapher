//
//  DynamicLibraryHandler.swift
//  DynamicLibraryService
//
//  Created by Eskil Gjerde Sviggum on 12/02/2024.
//

import Foundation

final class DynamicLibraryHandler {
    
    let libraryURL: URL
    let libraryAddress: UnsafeMutableRawPointer?
    
    private var isClosed: Bool = false
    
    init(libraryURL: URL) {
        self.libraryURL = libraryURL
        
        Logger.log("Opening library at \(libraryURL.path())")
        
        libraryAddress = libraryURL.path().withCString { libraryPath in
            if let address = dlopen(libraryPath, RTLD_GLOBAL) {
                return address
            } else {
                if let error = dlerror() {
                    Logger.log("Could not open library with error: \(String(cString: error))")
                }
                return nil
            }
        }
        
        if libraryAddress == nil {
            isClosed = true
        }
    }
    
    deinit {
        Logger.log("Closing library at \(libraryURL.path())")
        close()
    }
    
    func symbol(named name: String) -> UnsafeMutableRawPointer? {
        if isClosed {
            return nil
        }
        
        return name.withCString { symbolName in
            if let symbol = dlsym(libraryAddress, symbolName){
                return symbol
            } else {
                if let error = dlerror() {
                    Logger.log("Could not find symbol with error: \(String(cString: error))")
                }
                return nil
            }
        }
    }
    
    func close() {
        if isClosed {
            return
        }
        
        let result = dlclose(libraryAddress)
        if result == 0 {
            isClosed = true
            return
        }
        
        var error: String = ""
        let dlerror = dlerror()
        if dlerror != nil {
            error = String(cString: dlerror!)
        }
        
        Logger.log("Could not close dynamic library: \(error)")
    }
    
    
}
