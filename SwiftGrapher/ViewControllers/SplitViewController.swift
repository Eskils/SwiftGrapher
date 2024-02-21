//
//  SplitViewController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 30/01/2024.
//

import AppKit

final class SplitViewController: NSSplitViewController {
    
    let compilerService: SwiftCompilerService
    let equationManagementService: EquationManagementService
    
    lazy var sidebarController = makeSidebarViewController()
    lazy var detailController = makeDetailViewController()
    
    init(compilerService: SwiftCompilerService, equationManagementService: EquationManagementService) {
        self.compilerService = compilerService
        self.equationManagementService = equationManagementService
        super.init(nibName: nil, bundle: nil)
        
        self.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebarController))
        self.addSplitViewItem(NSSplitViewItem(viewController: detailController))
        
        sidebarController.delegate = detailController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeSidebarViewController() -> SidebarViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateController(identifier: "SidebarViewController") { coder in
            SidebarViewController(coder: coder, equationManagementService: self.equationManagementService)
        }
        return viewController
    }
    
    private func makeDetailViewController() -> ViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateController(identifier: "DetailViewController") { coder in
            ViewController(coder: coder, compilerService: self.compilerService, equationManagementService: self.equationManagementService)
        }
        return viewController
    }
    
    override var representedObject: Any? {
        didSet {
            guard let graphCollection = representedObject as? GraphCollection else {
                return
            }
            
            self.equationManagementService.setGraphCollection(graphCollection)
        }
    }
    
}
