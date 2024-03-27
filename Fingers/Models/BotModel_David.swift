import Foundation

// Struct to use mutating functions
struct BotModel_David : BotModelProtocol {
    /// The trace from the model
    var traceText: String = ""
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = false
    /// String that is displayed to show the outcome of a round
    var feedback = ""
    /// Boolean that determines whether to stay or pull finger from the cup
    var decision: Bool? = nil
    /// Int that holds the models prediction on how many fingers are left on the cup
    var prediction: Int? = nil
    /// The ACT-R model
    internal var model = Model()
    
    /// Run the model until done, or until it reaches a +action>
    mutating func run(isActive: Bool) {
        // Init goal buffer
        let goal = createGoalBuffer(model: model, isActive: isActive)
        var done = false
        while !done {
            // Switch between states in the goal buffer
            switch (goal.slotvals["state"]!.description) {
            case "start":
                //model.time += 0.05
                model.addToTrace(string: "Starting round")
            case "retrieving-decision":
                if let imaginal = model.buffers["imaginal"] {
                    let retrieval = Chunk(s: "retrieval", m: model)
                    retrieval.setSlot(slot: "isa", value: "lastDecision")
                    retrieval.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
                    let (latency, result) = model.dm.retrieve(chunk: retrieval)
                    model.time += 0.05 + latency
                    if let retrievedChunk = result {
                        
                        model.addToTrace(string: "Retrieving \(retrievedChunk)")
                    } else {
                        // fail to retrieve
                        // random
                    }
                }
                
                
            case "retrieving-prediction":
                model.time += 0.05
            case "deciding":
                model.time += 0.05
            case "predicting":
                model.time += 0.05
            case "update-decisions":
                model.time += 0.05
            case "update-predictions":
                model.time += 0.05
            case "playing":
                model.time += 0.05
            case "waiting":
                model.time += 0.05
            default: done = true
            }
        update()
        }
        
        model.run()
    }
    
    /// Reset the model
    mutating func reset() {
        model.reset()
        decision = nil
        prediction = nil
        feedback = ""
    }
    
    /// Modify a slot in the action buffer
    /// - Parameters:
    ///   - slot: the slot to be modified
    ///   - value: the new value
    /// - Returns: whether successful
    func modifyLastAction(slot: String, value: String) -> Bool {
        if model.waitingForAction {
            model.modifyLastAction(slot: slot, value: value)
            return true
        } else {
            return false
        }
    }

    /// Function that is executed whenever the bot makes a choice.
    /// - Parameter fingerAction: "stay" or "pull"
    mutating func choose(playerAction: String) {
        model.run()
        update()
    }
}
