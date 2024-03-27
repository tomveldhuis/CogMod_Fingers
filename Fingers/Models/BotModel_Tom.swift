import Foundation

// Struct to use mutating functions
struct BotModel_Tom : BotModelProtocol {
    /// Total amount of players in the current game
    var playerCount: Int
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
        if model.buffers["goal"] == nil {
            // Set initial goal buffer
            let chunk = Chunk(s: model.generateName(string: "goal"), m: model)
            chunk.setSlot(slot: "isa", value: "goal")
            chunk.setSlot(slot: "state", value: "start")
            if isActive {
                chunk.setSlot(slot: "isActive", value: "yes")
            } else {
                chunk.setSlot(slot: "isActive", value: "no")
            }
            model.buffers["goal"] = chunk
        } else {
            // Ensure that the goal buffer contains
            // information about the current player
            let goal = model.buffers["goal"]!
            if isActive {
                goal.setSlot(slot: "isActive", value: "yes")
            } else {
                goal.setSlot(slot: "isActive", value: "no")
            }
        }
        let goal = model.buffers["goal"]!
        var done = false
        while !done {
            // Switch between states in the goal buffer
            switch (goal.slotvals["state"]!.description) {
                case "start":
                    // Initially, make a random decision
                    // and put it in the imaginal buffer
                    let imaginal = Chunk(s: model.generateName(string: "imaginal"), m: model)
                    if actrNoise(noise: 1.0) > 0 {
                        imaginal.setSlot(slot: "decision", value: "stay")
                        model.addToTrace(string: "Start with random decision: stay")
                    } else {
                        imaginal.setSlot(slot: "decision", value: "pull")
                        model.addToTrace(string: "Start with random decision: pull")
                    }
                    model.buffers["imaginal"] = imaginal
                    model.time += 0.05
                
                    // Check if the BotModel is the current player
                    if goal.slotvals["isActive"]!.description == "yes" {
                        // If yes, then retrieve a prediction value
                        goal.setSlot(slot: "state", value: "predicting")
                    } else {
                        // If no, then make an action chunk
                        // and wait for the game to finish the round
                        let action = Chunk(s: "action", m: model)
                        action.setSlot(slot: "isa", value: "decision")
                        action.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
                        model.buffers["action"] = action
                        model.time += 0.05
                        model.addToTrace(string: "Created an action chunk")
                        
                        goal.setSlot(slot: "state", value: "waiting")
                        done = true
                        model.waitingForAction = true
                        model.addToTrace(string: "Waiting for the round to finish...")
                    }
                case "deciding":
                    model.addToTrace(string: "Retrieving decision from memory...")
                
                    // Use regular retrieval for decision ("stay" or "pull")
                    let retrieval = Chunk(s: "retrieval", m: model)
                    retrieval.setSlot(slot: "isa", value: "lastDecision")
                    let (latency, result) = model.dm.retrieve(chunk: retrieval)
                    model.time += 0.05 + latency
                
                    let imaginal = model.buffers["imaginal"]!
                    if let retrievedChunk = result {
                        // Put retrieved decision in the imaginal buffer
                        imaginal.setSlot(slot: "decision", value: retrievedChunk.slotvals["decision"]!)
                        model.addToTrace(string: "Found decision chunk: \(retrievedChunk.slotvals["decision"]!)")
                    } else {
                        // Retrieval failure: make a random decision ("stay" or "pull")
                        model.addToTrace(string: "No decision chunk found")
                        if actrNoise(noise: 1.0) > 0 {
                            imaginal.setSlot(slot: "decision", value: "stay")
                            model.addToTrace(string: "Random decision is made instead: stay")
                        } else {
                            imaginal.setSlot(slot: "decision", value: "pull")
                            model.addToTrace(string: "Random decision is made instead: pull")
                        }
                        model.time += 0.05
                    }
                    
                    // Check if the BotModel is the current player
                    if goal.slotvals["isActive"]!.description == "yes" {
                        // If yes, then retrieve a prediction value
                        goal.setSlot(slot: "state", value: "predicting")
                    } else {
                        // If no, then make an action chunk
                        // and wait for the game to finish the round
                        let action = Chunk(s: "action", m: model)
                        action.setSlot(slot: "isa", value: "decision")
                        action.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
                        model.buffers["action"] = action
                        model.time += 0.05
                        model.addToTrace(string: "Created an action chunk")
                        
                        goal.setSlot(slot: "state", value: "waiting")
                        done = true
                        model.waitingForAction = true
                        model.addToTrace(string: "Waiting for the round to finish...")
                    }
                case "predicting":
                    model.addToTrace(string: "Retrieving prediction from memory...")
                
                    // Use blended retrieval for prediction value
                    let pattern = Chunk(s: "retrieval", m: model)
                    pattern.setSlot(slot: "isa", value: "lastPrediction")
                    let (latency, result) = model.dm.blendedRetrieve(chunk: pattern)
                    model.time += 0.05 + latency
                    
                    let imaginal = model.buffers["imaginal"]!
                    if let retrievedChunk = result {
                        // Put retrieved prediction in the imaginal buffer
                        imaginal.setSlot(slot: "prediction", value: retrievedChunk.slotvals["prediction"]!)
                        model.addToTrace(string: "Found prediction chunk: \(retrievedChunk.slotvals["prediction"]!.description)")
                    } else {
                        // Retrieval failure: make a random prediction (value between 0 and playerCount)
                        model.addToTrace(string: "No prediction chunk found")
                        let randomPrediction = Double(Int.random(in: 0...playerCount))
                        imaginal.setSlot(slot: "prediction", value: randomPrediction)
                        model.addToTrace(string: "Random prediction is made instead: \(randomPrediction.description)")
                        model.time += 0.05
                    }
                    
                    // Make an action chunk and wait for the
                    // game to finish the round
                    let action = Chunk(s: "action", m: model)
                    action.setSlot(slot: "isa", value: "decision_prediction")
                    action.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
                    action.setSlot(slot: "prediction", value: imaginal.slotvals["prediction"]!)
                    model.buffers["action"] = action
                    model.time += 0.05
                    model.addToTrace(string: "Created an action chunk")
                
                    goal.setSlot(slot: "", value: "waiting")
                    done = true
                    model.waitingForAction = true
                    model.addToTrace(string: "Waiting for the round to finish...")
                case "waiting":
                    model.time += 0.05
                default: done = true
            }
        update()
        }
    }
    
    /// Reset the model
    mutating func reset() {
        model.reset()
        decision = nil
        prediction = nil
        feedback = ""
        //run()
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
