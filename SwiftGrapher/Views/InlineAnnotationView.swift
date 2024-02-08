//
//  InlineAnnotationView.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 08/02/2024.
//

import SwiftUI

struct InlineAnnotationView: View {
    let annotation: InlineAnnotation
    let proposedViewFrame: CGRect
    
    var body: some View {
        HStack {
            if let image = annotation.kind.image {
                Image(nsImage: image)
                    .font(.system(size: 12))
            }
            
            Text(annotation.message)
                .font(.system(size: 12))
            
            Spacer()
        }
        .padding(.leading, 4)
        .frame(height: proposedViewFrame.height)
        .background(Color(annotation.kind.backgroundColor))
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4))
        .padding(.leading, 32)
    }
}
