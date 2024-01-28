//
//  EquationCellView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import AppKit

final class EquationCellView: NSView {
    
    var equation: Equation? {
        didSet {
            configureData()
        }
    }
    
    var index: Int?
    
    private let isEnabledCheckbox = {
        let button = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        return button
    }()
    
    private let nameLabel = {
        let label = NSTextField(wrappingLabelWithString: "")
        return label
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureView() {
        let stackView = NSStackView(views: [
            isEnabledCheckbox,
            nameLabel,
        ])
        stackView.orientation = .horizontal
        stackView.spacing = 8
        
        isEnabledCheckbox.target = self
        isEnabledCheckbox.action = #selector(didChangeIsEnabled)
        
        nameLabel.target = self
        nameLabel.action = #selector(didTapLabel)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nameDidEndEdit(notification:)),
            name: NSTextField.textDidEndEditingNotification,
            object: nameLabel
        )
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    private func configureData() {
        guard let equation else {
            return
        }
        
        isEnabledCheckbox.contentTintColor = NSColor(cgColor: equation.color)
        isEnabledCheckbox.state = equation.isEnabled ? .on : .off
        
        nameLabel.stringValue = equation.name ?? "Equation \(index.map { String($0 + 1) } ?? "")"
    }
    
    @objc
    private func didChangeIsEnabled() {
        equation?.isEnabled = isEnabledCheckbox.state == .on
    }
    
    @objc
    private func didTapLabel() {
        nameLabel.isEditable = true
        nameLabel.becomeFirstResponder()
    }
    
    @objc
    private func nameDidEndEdit(notification: NSNotification) {
        equation?.name = nameLabel.stringValue
        nameLabel.isEditable = false
    }
    
}
