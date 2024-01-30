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
    
}

final class EquationManagementServiceImpl: EquationManagementService {
    
    @Published
    private(set) var graphCollection: GraphCollection
    
//    var equations: [Equation] {
//        graphCollection.equations
//    }
//    
//    var equationsPublisher: Published<[Equation]>.Publisher { graphCollection.$equations
//    }
    
    @Published
    private(set) var equations: [Equation] = []
    var equationsPublisher: Published<[Equation]>.Publisher { $equations }
    
    @Published
    var selectedEquation: Equation
    var selectedEquationPublisher: Published<Equation>.Publisher { $selectedEquation }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let initialEquation = Equation.emptyWithRandomColor()
        
        self.graphCollection = GraphCollection(equations: [initialEquation])
        
        selectedEquation = initialEquation
        
        graphCollection.equationsPublisher.assign(to: &$equations)
        
        graphCollection.equationsPublisher
            .sink(receiveValue: didUpdate(equations:))
            .store(in: &cancellables)
        
        $graphCollection
            .sink(receiveValue: didUpdate(graphCollection:))
            .store(in: &cancellables)
    }
    
    private func didUpdate(equations: [Equation]) {
        print("Did update equations")
    }
    
    private func didUpdate(graphCollection: GraphCollection) {
        print("Did update graph collections")
    }
    
    func addEquation() {
        graphCollection.addEquation()
    }
    
    func setGraphCollection(_ graphCollection: GraphCollection) {
        self.graphCollection = graphCollection
    }
    
}
