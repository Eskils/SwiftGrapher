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
    
    required init?(coder: NSCoder) {
        guard let delegate = NSApp.delegate as? AppDelegate else {
            assertionFailure()
            return nil
        }
        
        self.equationManagementService = delegate.equationManagementService
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
