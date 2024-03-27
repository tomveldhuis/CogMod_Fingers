import Foundation

protocol BotModelProtocol {
    var name: String { get set }
    var playerCount: Int { get set }
    var traceText: String { get set }
    var breakTime: Double { get set }
    var model: Model {get set }
    var modelText: String { get set }
    var dmContent: [PublicChunk] { get set }
    var waitingForAction: Bool { get set }
    var feedback: String { get set }
    mutating func run(isActive: Bool)
    func modifyLastAction(slot: String, value: String) -> Bool
    mutating func update()
}

extension BotModelProtocol {
    /// Update the representation of the model in the struct. If the struct changes,
    /// the View is automatically updated, but this does not work for classes.
    mutating func update() {
        self.traceText = model.trace
        self.modelText = model.modelText
        dmContent = []
        var count = 0
        for (_,chunk) in model.dm.chunks {
            var slots: [(slot: String,val: String)] = []
            for slot in chunk.printOrder {
                if let val = chunk.slotvals[slot] {
                    slots.append((slot:slot, val:val.description))
                }
            }
            dmContent.append(PublicChunk(name: chunk.name, slots: slots, activation: chunk.activation(),id: count))
            count += 1
        }
        dmContent.sort { $0.activation > $1.activation }
        waitingForAction = true
    }
}
