//
//  SwiftCompilerService.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import Foundation

@objc
protocol SwiftCompilerService: AnyObject {
    func compile(text: String) throws -> URL
}

final class SwiftCompilerServiceImpl: SwiftCompilerService {
    
    private let fileManager = FileManager.default
    
    func compile(text: String) throws -> URL {
        let temporaryDirectoryURL = fileManager.temporaryDirectory
        let outputID = UUID().uuidString
        let fileNameInput = "Content.swift"
        let fileNameOutput = "Content-\(outputID).dylib"
        let inputPath = pathForFile(inDirectory: temporaryDirectoryURL, withName: fileNameInput)
        let outputPath = pathForFile(inDirectory: temporaryDirectoryURL, withName: fileNameOutput)
        
        try writeTextToSwiftFile(text: text, path: inputPath)
        
        Logger.log("Starting compiling \(inputPath)")
        
        let (errorPipe, outPipe) = try invokeSwiftCompiler(inputPath: inputPath, outputPath: outputPath)
        
        Logger.log("Finished compiling \(inputPath)")
        
        let errorData = try errorPipe.fileHandleForReading.readToEnd()
        let outputData = try outPipe.fileHandleForReading.readToEnd()
        
        if let error = errorData.flatMap({ String(data: $0, encoding: .utf8) }) {
            var lines = error.split(separator: "\n")
            print("Error occured when compiling: \(lines)")
            lines.removeFirst() // Toolchain version
            lines.removeFirst() // Target arch
            if !lines.isEmpty {
                let errorDescriptions = lines.compactMap(CompilationErrorDescription.fromCompilerOutput(text:))
                throw ServiceError.compilationError(errorDescriptions)
            }
        }
        
        if let output = outputData.flatMap({ String(data: $0, encoding: .utf8) }) {
            print("Compiler output: \(output)")
        }
        
        return URL(filePath: outputPath)
    }
    
    private func writeTextToSwiftFile(text: String, path: String) throws {
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
        
        let data = text.data(using: .utf8)
        
        fileManager.createFile(atPath: path, contents: data)
    }
    
    private func pathForFile(inDirectory url: URL, withName name: String) -> String {
        url.appending(component: name).path()
    }
    
    private func invokeSwiftCompiler(inputPath: String, outputPath: String) throws -> (error: Pipe, output: Pipe){
        // swiftc -emit-library ContentsTest.swift -o ContentsTest.dylib
        let directory = URL(filePath: inputPath).deletingLastPathComponent()
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/swiftc")
        process.currentDirectoryURL = directory
        process.arguments = [
            "-emit-library",
            inputPath,
            "-o\(outputPath)",
            "-v",
        ]
        
        let stdError = Pipe()
        process.standardError = stdError.fileHandleForWriting
        
        let stdOut = Pipe()
        process.standardOutput = stdOut.fileHandleForWriting
        
        try process.run()
        
        process.waitUntilExit()
        
        try stdOut.fileHandleForWriting.close()
        try stdError.fileHandleForWriting.close()
        
        return (stdError, stdOut)
    }
    
    enum ServiceError: Error {
        case compilationError([CompilationErrorDescription])
    }
}
