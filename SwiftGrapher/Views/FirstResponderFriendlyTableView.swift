//
//  FirstResponderFriendlyTableView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 13/02/2024.
//

import AppKit

final class FirstResponderFriendlyTableView: NSTableView {
    
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        guard
            self.selectedRow >= 0,
            let cellView = self.view(atColumn: 0, row: self.selectedRow, makeIfNecessary: false)
        else {
            return false
        }
        
        if let responderView = responder as? NSView {
            return responderView.isDescendant(of: cellView)
        }
        
        return true
    }
    
}
