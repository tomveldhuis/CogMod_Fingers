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
    var model: FingersViewModel
    @State var playerName: String = ""
    
    init(model: FingersViewModel, buttons: [NumberButton]) {
        self.buttons = buttons
        self.columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        self.model = model
    }
    
    var body: some View {
        VStack {
            // Text updates when current player changes
            Text("Player \(self.playerName):")
                .font(.system(size: 28))
                .onReceive(self.model.model.$currentPlayerIdx) { newIdx in
                    self.playerName = self.model.currentPlayer().name
                }
            Text("Predict the remaining number of fingers")
                .font(.system(size: 18))
            Divider()
            // Input buttons
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
