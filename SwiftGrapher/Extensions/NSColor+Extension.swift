//
//  NSColor+Extension.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 07/02/2024.
//

import AppKit

extension NSColor {
    
    convenience init(hex: Int, alpha: CGFloat) {
        let red = hex >> 16 & 0xFF
        let green = hex >> 8 & 0xFF
        let blue = hex >> 0 & 0xFF
        
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
    }
    
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1)
    }
    
    convenience init(light: Int, dark: Int) {
        self.init(light: NSColor(hex: light), dark: NSColor(hex: dark))
    }
    
    convenience init(light: NSColor, dark: NSColor) {
        self.init(name: nil) { appearance in
            if appearance.name == .darkAqua || appearance.name == .vibrantDark {
                return dark
            } else {
                return light
            }
        }
    }
    
}
