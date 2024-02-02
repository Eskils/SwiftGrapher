//
//  GraphCollectionDocument.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 30/01/2024.
//

import AppKit
import MessagePacker

final class GraphCollectionDocument: NSDocument {
    
    static let typeIdentifier = "com.skillbreak.SwiftGrapher.GraphCollection"
    
    private var graphCollection: GraphCollection = .newWithSingleEquation()
    
    private let encoder = MessagePackEncoder()
    
    private let decoder = MessagePackDecoder()
    
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
        self.graphCollection = try decoder.decode(GraphCollection.self, from: data)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        try encoder.encode(graphCollection)
    }
    
}
