//
//  CompilationErrorDescription.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 07/02/2024.
//

import Foundation

struct CompilationErrorDescription {
    
    let filePath: String
    let lineNumber: Int
    let column: Int
    let errorKind: String
    let errorDescription: String
    
    var lineNumberIndex: Int {
        lineNumber - 1
    }
    
    var fileName: String {
        URL(filePath: filePath).lastPathComponent
    }
    
    static func fromCompilerOutput(text: any StringProtocol) -> Self? {
        let pattern = /([\w.\/]+):(\d+):(\d+): (\w+): (.+)/
        do {
            guard let match = try pattern.wholeMatch(in: String(text)) else {
                return nil
            }
            let (_, file, lineNumberString, columnString, errorKind, errorDescription) = match.output
            
            guard
                let lineNumber = Int(lineNumberString),
                let column = Int(columnString)
            else {
                return nil
            }
            
            return CompilationErrorDescription(
                filePath: String(file),
                lineNumber: lineNumber,
                column: column,
                errorKind: String(errorKind),
                errorDescription: String(errorDescription)
            )
        } catch {
            print("Cannot match pattern: \(pattern)")
            return nil
        }
    }
    
}

extension CompilationErrorDescription: CustomStringConvertible {
    
    var description: String {
        "CompilationErrorDescription: \(fileName):\(lineNumber):\(column): \(errorKind): \(errorDescription)"
    }
    
}
