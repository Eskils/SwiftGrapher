//
//  DisableableScrollView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 15/02/2024.
//

import AppKit

final class DisableableScrollView: NSScrollView {
    
    public var isScrollEnabled: Bool = true
    
    override func scrollWheel(with event: NSEvent) {
        if isScrollEnabled {
            super.scrollWheel(with: event)
        }
    }
    
}
