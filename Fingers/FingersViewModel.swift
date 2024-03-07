//
//  FingersViewModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import SwiftUI

class FingersViewModel: ObservableObject {
    private var model: FingersModel
    
    
    init() {
        model = FingersModel()
    }
}
