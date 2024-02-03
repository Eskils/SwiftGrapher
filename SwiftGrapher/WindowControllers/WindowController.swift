//
//  WindowController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 30/01/2024.
//

import AppKit

final class WindowController: NSWindowController {
    
    let equationManagementService: EquationManagementService = EquationManagementServiceImpl()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        self.shouldCascadeWindows = true
        self.contentViewController = makeSplitViewController()
        
        if let screenFrame = window?.screen?.frame {
            let windowFrame = screenFrame.insetBy(dx: 50, dy: 100)
            self.window?.setFrame(windowFrame, display: true)
        }
    }
    
    private func makeSplitViewController() -> NSViewController {
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            return NSViewController()
        }
        
        let splitViewController = SplitViewController(compilerService: appDelegate.compilerService, equationManagementService: equationManagementService)
        return splitViewController
    }
}
