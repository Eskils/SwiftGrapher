//
//  HorizontalColorSelectView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 13/02/2024.
//

import AppKit
import SwiftUI

struct HorizontalColorSelectView: View {
    
    private let colors = Constants.defaultEquationColors[0..<Constants.defaultEquationColors.endIndex - 1]
    
    @State
    var hoveredColorIndex = 0
    
    let didChangeColorHandler: ((CGColor) -> Void)?
    
    init(didChangeColorHandler: ((CGColor) -> Void)?) {
        self.didChangeColorHandler = didChangeColorHandler
    }
    
    var body: some View {
        HStack {
            ForEach(0..<colors.count, id: \.self) { i in
                let color = colors[i]
                let isSelected = hoveredColorIndex == i
                Color(nsColor: color)
                    .frame(width: 15, height: 15)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .scale(1.2)
                            .stroke(lineWidth: isSelected ? 2 : 0)
                            .foregroundColor(.white)
                    )
                    .onHover(perform: { isHovering in
                        if isHovering {
                            hoveredColorIndex = i
                        }
                    })
                    .onTapGesture {
                        didChangeColorHandler?(color.cgColor)
                    }
            }
        }
        .onHover(perform: { isHovering in
            if !isHovering {
                hoveredColorIndex = -1
            }
        })
        .padding(4)
    }
    
}
