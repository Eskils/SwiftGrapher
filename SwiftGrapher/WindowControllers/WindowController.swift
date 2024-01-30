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
        self.contentViewController = makeSplitViewController()
    }
    
    private func makeSplitViewController() -> NSViewController {
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            return NSViewController()
        }
        
        let splitViewController = SplitViewController(compilerService: appDelegate.compilerService, equationManagementService: equationManagementService)
        return splitViewController
    }
}
