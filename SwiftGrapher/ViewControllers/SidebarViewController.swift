//
//  SidebarViewController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 27/01/2024.
//

import AppKit
import Combine

final class SidebarViewController: NSViewController {
    
    let equationManagementService: EquationManagementService
    
    private var cancellables = Set<AnyCancellable>()
    
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
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(didPressDeleteEquation(sender:)), keyEquivalent: String(Unicode.Scalar(NSBackspaceCharacter)!)))
        
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
