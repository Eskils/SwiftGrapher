//
//  GraphCollection.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 02/02/2024.
//

import Foundation
import Combine

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
    
    func addEquation() {
        equations.append(.emptyWithRandomColor())
    }
    
    static func newWithSingleEquation() -> GraphCollection {
        GraphCollection(equations: [.emptyWithRandomColor()])
    }
       
    enum CodingKeys: String, CodingKey {
        case equations
    }
}
