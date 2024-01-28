//
//  EquationManagementService.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 28/01/2024.
//

import Foundation

protocol EquationManagementService: AnyObject {
    
    var equations: [Equation] { get }
    var equationsPublisher: Published<[Equation]>.Publisher { get }
    
    var selectedEquation: Equation { get set }
    var selectedEquationPublisher: Published<Equation>.Publisher { get }
    
    func addEquation()
    
}

final class EquationManagementServiceImpl: EquationManagementService {
    
    @Published
    private(set) var equations: [Equation]
    var equationsPublisher: Published<[Equation]>.Publisher { $equations }
    
    @Published
    var selectedEquation: Equation
    var selectedEquationPublisher: Published<Equation>.Publisher { $selectedEquation }
    
    init() {
        let initialEquation = Equation.emptyWithRandomColor()
        
        equations = [
            initialEquation
        ]
        
        selectedEquation = initialEquation
    }
    
    func addEquation() {
        equations.append(.emptyWithRandomColor())
    }
    
}
