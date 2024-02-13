//
//  EquationManagementService.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation
import Combine

protocol EquationManagementService: AnyObject {
    
    var equations: [Equation] { get }
    var equationsPublisher: Published<[Equation]>.Publisher { get }
    
    var selectedEquation: Equation { get set }
    var selectedEquationPublisher: Published<Equation>.Publisher { get }
    
    func addEquation()
    func setGraphCollection(_ graphCollection: GraphCollection)
    
    func remove(equation: Equation)
    func removeEquation(atIndex index: Int)
    
}

final class EquationManagementServiceImpl: EquationManagementService {
    
    private(set) var graphCollection: GraphCollection {
        didSet {
            graphCollection.equationsPublisher.assign(to: &$equations)
            self.equations = graphCollection.equations
            
            if !graphCollection.equations.contains(self.selectedEquation),
               let firstEquation = graphCollection.equations.first {
                selectedEquation = firstEquation
            }
        }
    }
    
    @Published
    private(set) var equations: [Equation] = []
    var equationsPublisher: Published<[Equation]>.Publisher { $equations }
    
    @Published
    var selectedEquation: Equation
    var selectedEquationPublisher: Published<Equation>.Publisher { $selectedEquation }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let initialEquation = Equation.empty(withColor: Constants.defaultEquationColors.first?.cgColor)
        
        self.graphCollection = GraphCollection(equations: [initialEquation])
        
        selectedEquation = initialEquation
    }
    
    func addEquation() {
        let colorIndex = equations.count % Constants.defaultEquationColors.count
        let color = Constants.defaultEquationColors[colorIndex].cgColor
        graphCollection.addEquation(color: color)
    }
    
    func remove(equation: Equation) {
        guard let index = equations.firstIndex(of: equation) else {
            return
        }
        
        graphCollection.removeEquation(atIndex: index)
    }
    
    func removeEquation(atIndex index: Int) {
        guard equations.indices.contains(index) else {
            return
        }
        
        graphCollection.removeEquation(atIndex: index)
    }
    
    func setGraphCollection(_ graphCollection: GraphCollection) {
        self.graphCollection = graphCollection
    }
    
}
