import Foundation
import Perception

class ViewModel {
    var timeline: Timeline
    @MainActor lazy private(set) var dataSource = TimelineDataSource(timeline: self.timeline)
    
    init() {
        timeline = .initial
    }
    
    func itemTapped(at indexPath: IndexPath) {
        print(indexPath)
    }
    
    func buttonTapped() {
        Task { @MainActor in
            timeline = .random
            dataSource.update(with: timeline)
        }
    }
}

@Perceptible
class Object {
    let id: UUID
    var text: String
    var isPremium: Bool
    
    init(id: UUID, text: String, isPremium: Bool) {
        self.id = id
        self.text = text
        self.isPremium = isPremium
    }
    
    static var mock: Object {
        Object(id: UUID(),
               text: UUID().uuidString,
               isPremium: Bool.random())
    }
}

extension Array where Element == Object {
    static var mocks: [Object] {
        let i = Int.random(in: 10...20)
        var result: [Object] = []
        for _ in 0..<i {
            result.append(.mock)
        }
        return result
    }
}
