//
//  InlineAnnotationKind.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 08/02/2024.
//

import AppKit

enum InlineAnnotationKind: String {
    case warning
    case error
    
    var backgroundColor: NSColor {
        switch self {
        case .warning:
            NSColor.warningBackground
        case .error:
            NSColor.errorBackground
        }
    }
    
    var image: NSImage? {
        switch self {
        case .warning:
            NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Warning")
        case .error:
            NSImage(systemSymbolName: "xmark.octagon", accessibilityDescription: "Error")
        }
    }
}
