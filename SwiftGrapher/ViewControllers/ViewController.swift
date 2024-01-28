//
//  ViewController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import Cocoa
import Combine

class ViewController: NSViewController {
    
    let compilerService: SwiftCompilerService
    let equationManagementService: EquationManagementService
    
    var cancellables = Set<AnyCancellable>()

    @IBOutlet var textView: NSTextView!
    
    @IBOutlet var compileButton: NSButtonCell!
    
    @IBOutlet var graphViewContainer: GraphView!
    
    var equationCalculationModels = [EquationCalculationModel]()
    
    required init?(coder: NSCoder) {
        guard let delegate = NSApp.delegate as? AppDelegate else {
            assertionFailure()
            return nil
        }
        
        self.compilerService = delegate.compilerService
        self.equationManagementService = delegate.equationManagementService
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.string = ""
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeText),
            name: NSTextView.didChangeNotification,
            object: textView
        )

        compileButton.target = self
        compileButton.action = #selector(compile)
        
        graphViewContainer.dataSource = self
        graphViewContainer.clipsToBounds = true
        
        equationManagementService.equationsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: didUpdate(equations:))
            .store(in: &cancellables)
        
        equationManagementService.selectedEquationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: didUpdate(selectedEquation:))
            .store(in: &cancellables)
    }
    
    private func didUpdate(equations: [Equation]) {
        let addedEquations = equations
            .filter { equation in
                !equationCalculationModels.contains(where: { model in model.id == equation.id })
            }
        
        self.equationCalculationModels += addedEquations
            .map { EquationCalculationModel(compilerService: compilerService, equation: $0) }
    }
    
    private func didUpdate(selectedEquation: Equation) {
        textView.string = selectedEquation.contents
    }
    
    private func updateCurrentEquationContents(checkIsSameFirst: Bool = false) {
        let selectedID = equationManagementService.selectedEquation.id
        guard let calculationModel = equationCalculationModels.first(where: { $0.id == selectedID }) else {
            return
        }
        
        if checkIsSameFirst, calculationModel.contents == textView.string {
            return
        }
        
        calculationModel.updateContents(contents: textView.string)
    }
    
    @objc
    private func compile() {
        do {
            let needsRecompilation = equationCalculationModels
                .filter { $0.needsRecompilation }
            
            for equation in needsRecompilation {
                try equation.compile()
            }
            
            graphViewContainer.display()
        } catch {
            print("Could not compile: \(error)")
        }
    }
    
    @objc
    private func didChangeText() {
        updateCurrentEquationContents()
    }
    
}

extension ViewController: GraphViewDataSource {
    func numberOfGraphs(in graphView: GraphView) -> Int {
        return equationCalculationModels.count
    }
    
    func graph(_ graphView: GraphView, showGraph graphIndex: Int) -> Bool {
        guard
            equationCalculationModels.indices.contains(graphIndex),
            let model = Optional(equationCalculationModels[graphIndex]),
            model.calculationHandler != nil
        else {
            return false
        }
        
        return model.isEnabled
    }
    
    func graph(_ graphView: GraphView, valueForGraph graphIndex: Int, x: Double) -> Double {
        guard 
            equationCalculationModels.indices.contains(graphIndex),
            let model = Optional(equationCalculationModels[graphIndex]),
            let calculationHandler = model.calculationHandler
        else {
            return 0
        }
        
        return calculationHandler(x)
    }
    
    func graph(_ graphView: GraphView, colorForGraph graphIndex: Int) -> CGColor {
        guard equationCalculationModels.indices.contains(graphIndex) else {
            return .black
        }
        
        let model = equationCalculationModels[graphIndex]
        return model.color
    }
    
    
}
