//
//  GraphCollection.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 02/02/2024.
//

import Foundation
import Combine
import CoreGraphics.CGColor

final class GraphCollection: Encodable, Decodable {
    
    var equations: [Equation] {
        didSet {
            equationsPublisher.send(equations)
        }
    }
    
    var equationsPublisher = CurrentValueSubject<[Equation], Never>([])
    
    init(equations: [Equation]) {
        self.equations = equations
    }
    
    func addEquation(color: CGColor? = nil) {
        equations.append(.empty(withColor: color))
    }
    
    func removeEquation(atIndex index: Int) {
        equations.remove(at: index)
    }
    
    static func newWithSingleEquation() -> GraphCollection {
        let equation = Equation.empty(withColor: Constants.defaultEquationColors.first?.cgColor)
        return GraphCollection(equations: [equation])
    }
       
    enum CodingKeys: String, CodingKey {
        case equations
    }
}
