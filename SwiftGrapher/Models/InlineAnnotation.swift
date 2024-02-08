//
//  InlineAnnotation.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 08/02/2024.
//

import AppKit
import STAnnotationsPlugin

final class InlineAnnotation: NSObject, STLineAnnotation {
    var location: NSTextLocation
    let message: String
    let kind: InlineAnnotationKind

    init(message: String, kind: InlineAnnotationKind, location: NSTextLocation) {
        self.message = message
        self.kind = kind
        self.location = location
    }
}
