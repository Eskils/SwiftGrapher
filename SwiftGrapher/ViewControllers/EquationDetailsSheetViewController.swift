//
//  EquationDetailsSheetViewController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 14/02/2024.
//

import AppKit

final class EquationDetailsSheetViewController: NSViewController {
    
    let equation: Equation
    
    var defaultName: String
    
    var didChangeHandler: (Equation) -> Void
    
    private let nameTextField = NSTextField()
    
    private let colorPicker = NSColorWell(style: .default)
    
    private let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
    
    private let doneButton = NSButton(title: "Save", target: nil, action: nil)
    
    private let graphVisualizationView = {
        let graphView = GraphView()
        graphView.functionLineWidth = 3
        graphView.showAxes = false
        graphView.isScrollEnabled = false
        return graphView
    }()
    
    init(equation: Equation, defaultName: String, didChangeHandler: @escaping (Equation) -> Void) {
        self.equation = equation
        self.defaultName = defaultName
        self.didChangeHandler = didChangeHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        graphVisualizationView.dataSource = self
        
        nameTextField.stringValue = equation.name ?? defaultName
        colorPicker.color = NSColor(cgColor: equation.color) ?? .accent
        
        cancelButton.target = self
        cancelButton.action = #selector(didPressCancel)
        
        doneButton.keyEquivalent = "\r"
        doneButton.target = self
        doneButton.action = #selector(didPressSave)
        
        colorPicker.target = self
        colorPicker.action = #selector(didChangeColor)
        
        configureView()
    }
    
    private func configureView() {
        let nameLabel = NSTextField(labelWithString: "Name")
        nameLabel.textColor = .secondaryLabelColor
        
        let colorLabel = NSTextField(labelWithString: "Color")
        colorLabel.textColor = .secondaryLabelColor
        
        let nameStackView = NSStackView(views: [
            nameLabel,
            nameTextField,
        ])
        nameStackView.spacing = 8
        nameStackView.distribution = .fillProportionally
        
        let colorStackView = NSStackView(views: [
            colorLabel,
            colorPicker,
        ])
        colorStackView.spacing = 8
        colorStackView.distribution = .fillProportionally
        
        let formStackView = NSStackView(views: [
            nameStackView,
            colorStackView,
        ])
        formStackView.orientation = .vertical
        formStackView.spacing = 8
        formStackView.distribution = .fill
        formStackView.alignment = .leading
        
        let titleLabel = NSTextField(labelWithString: "Edit equation")
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        let buttonStackView = NSStackView(views: [
            cancelButton,
            NSView(),
            doneButton
        ])
        buttonStackView.distribution = .fillProportionally
        
        
        let formVizStackView = NSStackView(views: [
            formStackView,
            NSView(),
            graphVisualizationView,
        ])
        formVizStackView.distribution = .fillProportionally
        
        let stackView = NSStackView(views: [
            titleLabel,
            formVizStackView,
            NSView(),
            buttonStackView
        ])
        stackView.orientation = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .leading
        
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            
            nameTextField.widthAnchor.constraint(equalToConstant: 200),
            graphVisualizationView.widthAnchor.constraint(equalToConstant: 100),
            graphVisualizationView.heightAnchor.constraint(equalTo: graphVisualizationView.widthAnchor),
        ])
    }
    
    @objc
    private func didPressSave() {
        if nameTextField.stringValue != defaultName {
            equation.name = nameTextField.stringValue
        }
        
        equation.color = colorPicker.color.cgColor
        
        didChangeHandler(equation)
        
        self.dismiss(self)
    }
    
    @objc
    private func didPressCancel() {
        self.dismiss(self)
    }
    
    @objc
    private func didChangeColor() {
        graphVisualizationView.display()
    }
    
}

extension EquationDetailsSheetViewController: GraphViewDataSource {
    
    func numberOfGraphs(in graphView: GraphView) -> Int {
        return 1
    }
    
    func graph(_ graphView: GraphView, valueForGraph graphIndex: Int, x: Double) -> Double {
        let amplitude = graphView.frame.height / 2
        return amplitude * sin(2 * .pi * x / amplitude * 8)
    }
    
    func graph(_ graphView: GraphView, colorForGraph graphIndex: Int) -> CGColor {
        return colorPicker.color.cgColor
    }
    
    func graph(_ graphView: GraphView, showGraph graphIndex: Int) -> Bool {
        return true
    }
    
}
