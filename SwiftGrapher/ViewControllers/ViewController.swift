//
//  ViewController.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import Cocoa
import Combine
import STTextView
import STAnnotationsPlugin
import NeonPlugin
import TextFormation
import TextFormationPlugin
import SwiftUI

class ViewController: NSViewController {
    
    let compilerService: SwiftCompilerService
    let equationManagementService: EquationManagementService
    
    var cancellables = Set<AnyCancellable>()

    @IBOutlet var textViewContainer: NSView!
    
    let textView: STTextView
    
    let textScrollView: NSScrollView
    
    @IBOutlet var compileButton: NSButtonCell!
    
    @IBOutlet var graphViewContainer: GraphView!
    
    var equationCalculationModels = [EquationCalculationModel]()
    
    private var compilationErrors = [Int: CompilationErrorDescription]()
    
    lazy var annotationManager = STAnnotationsPlugin(dataSource: self)
    
    private var appearanceObserver: NSKeyValueObservation?
    
    required init?(coder: NSCoder, compilerService: SwiftCompilerService, equationManagementService: EquationManagementService) {
        self.compilerService = compilerService
        self.equationManagementService = equationManagementService
        self.textScrollView = STTextView.scrollableTextView()
        self.textView = textScrollView.documentView as? STTextView ?? STTextView()
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        appearanceObserver = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.addPlugin(
            NeonPlugin(theme: DefaultSourceEditorTheme(), language: .swift)
        )
        
        textView.addPlugin(annotationManager)
        
        let filters = [
            StandardOpenPairFilter(open: "{", close: "}"),
            NewlineWithinPairFilter(open: "{", close: "}"),
            NewlineProcessingFilter(),
        ] as [Filter]
        
        let indenter = TextualIndenter()

        let providers = WhitespaceProviders(
            leadingWhitespace: indenter.substitionProvider(indentationUnit: "    ", width: 4),
            trailingWhitespace: { _, _ in return "" }
        )

        textView.addPlugin(
            TextFormationPlugin(filters: filters, whitespaceProviders: providers)
        )
        
        textView.backgroundColor = .textBackgroundColor
        
        appearanceObserver = self.view.observe(\.effectiveAppearance) { [weak self] _, change in
            self?.view.effectiveAppearance.performAsCurrentDrawingAppearance {
                self?.textView.backgroundColor = .textBackgroundColor
            }
        }
        
        let rulerView = STLineNumberRulerView(textView: textView)
        rulerView.highlightSelectedLine = true
        textScrollView.verticalRulerView = rulerView
        textScrollView.rulersVisible = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeText),
            name: STTextView.textDidChangeNotification,
            object: textView
        )
        
        textViewContainer.addSubview(textScrollView)
        textScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textScrollView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            textScrollView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),
            textScrollView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor),
            textScrollView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),
        ])

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
            
            var errors = [CompilationErrorDescription]()
            
            for equation in needsRecompilation {
                do {
                    try equation.compile()
                } catch {
                    if let error = error as? SwiftCompilerServiceImpl.ServiceError,
                       case .compilationError(let compileErrors) = error {
                        errors += compileErrors
                        continue
                    }
                    
                    throw error
                }
            }
            
            updateCompilationErrors(errors: errors)
            
            graphViewContainer.display()
        } catch {
            print("Could not compile: \(error)")
        }
    }
    
    private func updateCompilationErrors(errors: [CompilationErrorDescription]) {
        self.compilationErrors = errors.reduce(into: [Int: CompilationErrorDescription]()) { partialResult, error in
            if let previousResult = partialResult[error.lineNumberIndex], previousResult.errorKind == "error" {
                return
            }
            
            partialResult[error.lineNumberIndex] = error
        }
        self.annotationManager.reloadAnnotations()
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

extension ViewController: STAnnotationsDataSource {
    
    func textView(_ textView: STTextView, viewForLineAnnotation lineAnnotation: any STLineAnnotation, textLineFragment: NSTextLineFragment, proposedViewFrame: CGRect) -> NSView? {
        guard let annotation = lineAnnotation as? InlineAnnotation else {
            return nil
        }
        
        return STAnnotationView(frame: proposedViewFrame) {
            InlineAnnotationView(annotation: annotation, proposedViewFrame: proposedViewFrame)
        }
    }
    
    func textViewAnnotations() -> [any STLineAnnotation] {
        let annotations = compilationErrors.compactMap { (lineIndex, error) in
            let location = textView.textContentManager.location(line: error.lineNumber, character: -1) ?? textView.textLayoutManager.location(textView.textLayoutManager.documentRange.endLocation, offsetBy: -1) ?? textView.textLayoutManager.documentRange.location
            
            return InlineAnnotation(
                message: error.errorDescription,
                kind: InlineAnnotationKind(rawValue: error.errorKind) ?? .error,
                location: location
            )
        }
        
        return annotations
    }
    
    
}
