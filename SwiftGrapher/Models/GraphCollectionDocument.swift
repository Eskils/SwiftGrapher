//
//  GraphCollectionDocument.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 30/01/2024.
//

import AppKit
import MessagePacker
import Compression

final class GraphCollectionDocument: NSDocument {
    
    static let typeIdentifier = "com.skillbreak.SwiftGrapher.GraphCollection"
    
    private var graphCollection: GraphCollection = .newWithSingleEquation()
    
    private let encoder = MessagePackEncoder()
    
    private let decoder = MessagePackDecoder()
    
    private let compressionPageSize = 1024
    
    override init() {
        super.init()
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    
    
    override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
        return true
    }
    
    override class func canConcurrentlyReadDocuments(ofType: String) -> Bool {
        return ofType == Self.typeIdentifier
    }
    
    override class var readableTypes: [String] {
        return [typeIdentifier]
    }
    
    override func makeWindowControllers() {
        // Returns the storyboard that contains your document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let windowController =
            storyboard.instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier("Window Controller")) as? NSWindowController {
            self.addWindowController(windowController)
            
            windowController.contentViewController?.representedObject = graphCollection
        }
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        let uncompressed = try decompress(data: data)
        self.graphCollection = try decoder.decode(GraphCollection.self, from: uncompressed)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        let encoded = try encoder.encode(graphCollection)
        let compressed = try compress(data: encoded)
        return compressed
    }
    
    func compress(data input: Data) throws -> Data {
            var dest = Data()
            let outputFilter = try OutputFilter(.compress, using: .lzfse, writingTo: { data in
                if let data = data { dest.append(data) }
            })
            
            var index = 0
            let inputSize = input.count
            let pageSize = self.compressionPageSize
            
            while true {
                let readLength = min(pageSize, inputSize - index)
                
                let subdata = input.subdata(in: index..<index + readLength)
                try outputFilter.write(subdata)
                
                index += readLength
                if readLength == 0 { break }
            }
            
            return dest
        }
        
        func decompress(data input: Data) throws -> Data {
            var dest = Data()
            
            var index = 0
            let inputSize = input.count
            let pageSize = self.compressionPageSize
            
            let inputFilter = try InputFilter<Data>(.decompress, using: .lzfse, readingFrom: { length in
                let readLength = min(length, inputSize - index)
                let subdata = input.subdata(in: index..<index + readLength)
                
                index += readLength
                return subdata
            })
            
            while let page = try inputFilter.readData(ofLength: pageSize) {
                dest.append(page)
            }
            
            return dest
        }
    
}
