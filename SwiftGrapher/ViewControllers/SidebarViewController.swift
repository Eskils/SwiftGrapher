//
//  SidebarViewController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 27/01/2024.
//

import AppKit
import Combine
import SwiftUI

final class SidebarViewController: NSViewController {
    
    let equationManagementService: EquationManagementService
    
    private var cancellables = Set<AnyCancellable>()
    
    var delegate: SidebarViewControllerDelegate?
    
    @IBAction func didPressAddEquation(_ sender: Any) {
        equationManagementService.addEquation()
    }
    
    @IBOutlet var tableView: NSTableView!
    
    required init?(coder: NSCoder, equationManagementService: EquationManagementService) {
        self.equationManagementService = equationManagementService
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.menu = makeMenu()
        
        equationManagementService.equationsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: didUpdate(equations:))
            .store(in: &cancellables)
    }
    
    private func didUpdate(equations: [Equation]) {
        if equationManagementService.equations.isEmpty {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
        
        tableView.reloadData()
    }
    
    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Rename", action: #selector(didPressRenameEquation(sender:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(didPressDeleteEquation(sender:)), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        let colorPickerView = HorizontalColorSelectView(didChangeColorHandler: didChangeColorOfEquation(color:))
        let hostingView = NSHostingView(rootView: colorPickerView)
        hostingView.frame = CGRect(x: 0, y: 0, width: 185, height: 30)
        let colorPickerItem = NSMenuItem()
        colorPickerItem.target = self
        colorPickerItem.view = hostingView
        menu.addItem(colorPickerItem)
        
        menu.addItem(NSMenuItem(title: "Choose custom color", action: #selector(didPressEditEquation(sender:)), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Edit details…", action: #selector(didPressEditEquation(sender:)), keyEquivalent: ""))
        
        return menu
    }
    
    @objc 
    private func didPressRenameEquation(sender: Any) {
        guard
            tableView.clickedRow >= 0,
            let cellView = tableView.view(atColumn: 0, row: tableView.clickedRow, makeIfNecessary: false) as? EquationCellView
        else {
            return
        }

        cellView.showRename()
    }
    
    @objc
    private func didPressDeleteEquation(sender: Any) {
        guard tableView.clickedRow >= 0 else {
            return
        }
        
        equationManagementService.removeEquation(atIndex: tableView.clickedRow)
    }
    
    private func didChangeColorOfEquation(color: CGColor) {
        guard tableView.clickedRow >= 0, equationManagementService.equations.indices.contains(tableView.clickedRow) else {
            return
        }
        
        let equation = equationManagementService.equations[tableView.clickedRow]
        equation.color = color
        tableView.reloadData(forRowIndexes: IndexSet(integer: tableView.clickedRow), columnIndexes: IndexSet(integer: 0))
        delegate?.sidebar(self, equationDidChange: equation)
    }
    
    @objc
    private func didPressEditEquation(sender: Any) {
        guard
            tableView.clickedRow >= 0,
            equationManagementService.equations.indices.contains(tableView.clickedRow)
        else {
            return
        }
        
        let clickedRow = tableView.clickedRow
        let equation = equationManagementService.equations[clickedRow]
        
        let detailsSheet = EquationDetailsSheetViewController(equation: equation, defaultName: "Equation \(tableView.clickedRow + 1)", didChangeHandler: {_ in 
            self.tableView.reloadData(forRowIndexes: IndexSet(integer: clickedRow), columnIndexes: IndexSet(integer: 0))
            self.delegate?.sidebar(self, equationDidChange: equation)
        })
        self.presentAsSheet(detailsSheet)
    }
}

extension SidebarViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return equationManagementService.equations.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard equationManagementService.equations.indices.contains(row) else {
            return nil
        }
        
        let equation = equationManagementService.equations[row]
        
        let cell = EquationCellView(frame: .zero)
        cell.index = row
        cell.equation = equation
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard equationManagementService.equations.indices.contains(tableView.selectedRow) else {
            return
        }
        
        equationManagementService.selectedEquation = equationManagementService.equations[tableView.selectedRow]
    }
    
}

protocol SidebarViewControllerDelegate {
    func sidebar(_ sidebar: SidebarViewController, equationDidChange equation: Equation)
}
