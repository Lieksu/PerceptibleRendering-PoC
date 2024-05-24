struct Timeline: Hashable {
    var videos: [Video]
    var audios: [Audio]
    var effects: [Effect]
}

struct Video: Hashable {
    var name: String
    let hasSound: Bool
}

struct Audio: Hashable {
    let name: String
    let artist: String
    let volume: Double
}

struct Effect: Hashable {
    var name: String
    let iconName: String
}

extension Timeline {
    static var initial: Timeline {
        Timeline(
            videos: [
                Video(name: "The Godfather", hasSound: true),
                Video(name: "The Artist", hasSound: false),
                Video(name: "Mr. Nobody", hasSound: true),
                Video(name: "City Lights", hasSound: false)
            ],
            audios: [
                Audio(name: "The Times They Are A-Changin'",
                      artist: "Bob Dylan",
                      volume: 0.2),
                Audio(name: "Sound of Silence",
                      artist: "Simon & Garfunkel",
                      volume: 0.5)
            ],
            effects: [
                Effect(name: "Sparkles", iconName: "sparkles"),
                Effect(name: "Moon", iconName: "moon.fill"),
            ])
    }
    
    static var random: Timeline {
        var timeline = Timeline(videos: [], audios: [], effects: [])
        for _ in 0..<Int.random(in: 0...4) {
            timeline.videos.append(.random)
        }
        for _ in 0..<Int.random(in: 0...2) {
            timeline.audios.append(.random)
        }
        for _ in 0..<Int.random(in: 0...3) {
            timeline.effects.append(.random)
        }
        return timeline
    }
}

extension Video {
    static var random: Video {
        Video(name: .random(), hasSound: .random())
    }
}

extension Audio {
    static var random: Audio {
        Audio(name: .random(), artist: .random(), volume: .random(in: 0...1))
    }
}

extension Effect {
    static var random: Effect {
        Effect(name: .random(), iconName: "questionmark")
    }
}

extension String {
    static func random() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<5).map { _ in letters.randomElement()! })
    }
}
