//
//  Logger.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import Foundation

struct Logger {
    
    static func log(_ message: @autoclosure @escaping () -> Any?) {
        #if DEBUG
        print(message() ?? "")
        #endif
    }
    
}
