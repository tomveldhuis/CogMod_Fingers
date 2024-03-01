//
//  PredictView.swift
//  Fingers
//
//  Created by UsabilityLab on 3/1/24.
//

import SwiftUI

struct NumberButton {
    var label: String
    var action: () -> Void
}

struct PredictView: View {
    var buttons: [NumberButton]
    let columns: [GridItem]
    
    init(buttons: [NumberButton]) {
        self.buttons = buttons
        self.columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var body: some View {
        VStack {
            Text("Predict the number of fingers remaining")
                .font(.title)
                .padding()
            Divider()
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(buttons.indices) {index in
                    Button(action: {
                        self.buttons[index].action()
                    }) {
                        Text(self.buttons[index].label)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color.white)
        .cornerRadius(20)
    }
}
