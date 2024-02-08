//
//  EditorThemes.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 07/02/2024.
//

import Foundation
import AppKit
import NeonPlugin

func DefaultSourceEditorTheme() -> Theme {
    Theme(
        [
            "string": Theme.Value(nsColor: NSColor(light: 0xC41A16, dark: 0xFC6A5D)),
            "number": Theme.Value(nsColor: NSColor(light: 0x1C00CF, dark: 0xD0BF69),
                                  font: .monospacedDigitSystemFont(ofSize: 14, weight: .regular)),

            "keyword": Theme.Value(nsColor: NSColor(light: 0x9B2393, dark: 0xFC5FA3),
                                   font: .monospacedSystemFont(ofSize: 14, weight: .bold)),
            "include": Theme.Value(nsColor: NSColor(light: 0x9B2393, dark: 0xFC5FA3)),
            "constructor": Theme.Value(nsColor: NSColor(light: 0x9B2393, dark: 0xFC5FA3),
                                       font: .monospacedSystemFont(ofSize: 14, weight: .bold)),
            "keyword.function": Theme.Value(nsColor: NSColor(light: 0x9B2393, dark: 0xFC5FA3),
                                            font: .monospacedSystemFont(ofSize: 14, weight: .bold)),
            "keyword.return": Theme.Value(nsColor: NSColor(light: 0x9B2393, dark: 0xFC5FA3),
                                          font: .monospacedSystemFont(ofSize: 14, weight: .bold)),
            "variable.builtin": Theme.Value(nsColor: NSColor(light: 0x3900A0, dark: 0xD0A8FF)),
            "boolean": Theme.Value(nsColor: NSColor(light: 0x1C464A, dark: 0x9EF1DD),
                                   font: .monospacedSystemFont(ofSize: 14, weight: .bold)),

            "type": Theme.Value(nsColor: NSColor(light: 0x1C464A, dark: 0x9EF1DD)),

            "function.call": Theme.Value(nsColor: NSColor(light: 0x0F68A0, dark: 0x41A1C0)),

            "variable": Theme.Value(nsColor: NSColor(light: 0x0F68A0, dark: 0x41A1C0)),
            "property": Theme.Value(nsColor: NSColor(light: 0x0F68A0, dark: 0x41A1C0)),
            "method": Theme.Value(nsColor: NSColor(light: 0x0F68A0, dark: 0x41A1C0)),
            "parameter": Theme.Value(nsColor: NSColor(light: 0x0F68A0, dark: 0x41A1C0)),
            "comment": Theme.Value(nsColor: NSColor(light: 0x5D6C79, dark: 0x6C7986)),
            "operator": Theme.Value(nsColor: .labelColor),

                .default: Theme.Value(nsColor: .labelColor, 
                                      font: .monospacedSystemFont(ofSize: 14, weight: .regular))
        ]
    )
}

extension Theme.Value {
    
    init(nsColor: NSColor, font: NSFont? = nil) {
        self.init(color: Theme.Color(nsColor), font: font.map { Theme.Font($0) })
    }
    
}
