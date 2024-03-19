import Foundation

// Struct to use mutating functions
struct BotModel : BotModelProtocol {
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
    /// The ACT-R model
    internal var model = Model()
    
    /// Function that loads in a text file that is interpreted as the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
    func loadModel(filename: String) {
        model.loadModel(fileName: filename)
    }
    
    /// Run the model until done, or until it reaches a +action>
    mutating func run() {
        model.run()
    }
    
    /// Reset the model
    mutating func reset() {
        model.reset()
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
