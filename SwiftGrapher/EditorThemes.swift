//
//  EditorThemes.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 07/02/2024.
//

import Foundation
import CodeEditSourceEditor
import AppKit

func DefaultSourceEditorTheme() -> EditorTheme {
    EditorTheme(
        text: .labelColor,
        insertionPoint: .labelColor,
        invisibles: .systemGray,
        background: .textBackgroundColor,
        lineHighlight: .secondarySystemFill,
        selection: .selectedTextBackgroundColor,
        keywords: NSColor(light: 0x9B2393, dark: 0xFC5FA3),
        commands: NSColor(light: 0x3900A0, dark: 0xD0A8FF),
        types: NSColor(light: 0x1C464A, dark: 0x9EF1DD),
        attributes: NSColor(light: 0x815F03, dark: 0xBF8555),
        variables: NSColor(light: 0x0F68A0, dark: 0x41A1C0),
        values: NSColor(light: 0x1C464A, dark: 0x9EF1DD),
        numbers: NSColor(light: 0x1C00CF, dark: 0xD0BF69),
        strings: NSColor(light: 0xC41A16, dark: 0xFC6A5D),
        characters: NSColor(light: 0x1C00CF, dark: 0xD0BF69),
        comments: NSColor(light: 0x5D6C79, dark: 0x6C7986)
    )
}
