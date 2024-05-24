import Perception
import Foundation

@Perceptible
@MainActor
class TimelineDataSource {
    private var currentTimeline: Timeline
    private(set) var videos: [VideoDataSource]
    private(set) var audios: [AudioDataSource]
    private(set) var effects: [EffectDataSource]
    
    init(timeline: Timeline) {
        self.currentTimeline = timeline
        self.videos = timeline.videos.map(VideoDataSource.init)
        self.audios = timeline.audios.map(AudioDataSource.init)
        self.effects = timeline.effects.map(EffectDataSource.init)
        
        audios.forEach {
            $0.delegate = self
        }
        effects.forEach {
            $0.delegate = self
        }
    }
    
    func update(with timeline: Timeline) {
        guard currentTimeline != timeline else {
            return
        }
        
        let videoDiff = timeline.videos.difference(from: currentTimeline.videos)
        apply(videoDiff)
        
        let audioDiff = timeline.audios.difference(from: currentTimeline.audios)
        apply(audioDiff)
        
        let effectDiff = timeline.effects.difference(from: currentTimeline.effects)
        apply(effectDiff)
        
        currentTimeline = timeline
            
        audios.forEach {
            $0.delegate = self
        }
        effects.forEach {
            $0.delegate = self
        }
    }

    let numberOfSections: Int = 3
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            videos.count
        case 1:
            audios.count
        case 2:
            effects.count
        default:
            fatalError()
        }
    }
    
    func delete(_ audio: AudioDataSource) {
        audios.removeAll(where: { $0 === audio })
    }
    
    func addAudio(name: String) {
        let audio = Audio(name: name, artist: "AI", volume: Double.random(in: 0...1))
        let source = AudioDataSource(audio)
        source.delegate = self
        audios.insert(source, at: 0)
    }
    
    func effectTapped(_ source: EffectDataSource) {
        let index = currentTimeline.effects.firstIndex(where: { $0.name == source.name })!
        let newName = source.name + "!"
        var timeline = currentTimeline
        timeline.effects[index].name = newName
        update(with: timeline)
    }
    
    func apply(_ diff: CollectionDifference<Video>) {
        for change in diff.inferringModifications() {
            switch change {
            case let .insert(offset, element):
                let newSource = VideoDataSource(element)
                print("insert video at \(offset)")
                videos.insert(newSource, at: offset)
            case let .remove(offset, _):
                print("remove video at \(offset)")
                videos.remove(at: offset)
            case let .update(offset, _, newElement):
                print("update video at \(offset)")
                videos[offset].update(with: newElement)
            case let .move(_, fromOffset, toOffset):
                print("move video to \(toOffset)")
                videos.move(
                    fromOffsets: IndexSet(integer: fromOffset),
                    toOffset: toOffset
                )
            }
        }
    }
    
    func apply(_ diff: CollectionDifference<Audio>) {
        for change in diff.inferringModifications() {
            switch change {
            case let .insert(offset, element):
                let newSource = AudioDataSource(element)
                print("insert audio at \(offset)")
                audios.insert(newSource, at: offset)
            case let .remove(offset, _):
                print("remove audio at \(offset)")
                audios.remove(at: offset)
            case let .update(offset, _, newElement):
                print("update audio at \(offset)")
                audios[offset].update(with: newElement)
            case let .move(_, fromOffset, toOffset):
                print("move audio to \(toOffset)")
                audios.move(
                    fromOffsets: IndexSet(integer: fromOffset),
                    toOffset: toOffset
                )
            }
        }
    }
    
    func apply(_ diff: CollectionDifference<Effect>) {
        for change in diff.inferringModifications() {
            switch change {
            case let .insert(offset, element):
                let newSource = EffectDataSource(element)
                print("insert effect at \(offset)")
                effects.insert(newSource, at: offset)
            case let .remove(offset, _):
                print("remove effect at \(offset)")
                effects.remove(at: offset)
            case let .update(offset, _, newElement):
                print("update effect at \(offset)")
                effects[offset].update(with: newElement)
            case let .move(_, fromOffset, toOffset):
                print("move effect to \(toOffset)")
                effects.move(
                    fromOffsets: IndexSet(integer: fromOffset),
                    toOffset: toOffset
                )
            }
        }
    }
}

protocol ElementDataSource: AnyObject {
    func tapped() async
}

@Perceptible
@MainActor
class VideoDataSource: ElementDataSource {
    
    required init(_ video: Video) {
        self.name = video.name
        self.hasSound = video.hasSound
    }
    
    var name: String
    var hasSound: Bool
    
    func update(with video: Video) {
        if name != video.name {
            name = video.name
        }
        if hasSound != video.hasSound {
            hasSound = video.hasSound
        }
    }
    
    func tapped() {
        name += "!"
    }
}

@Perceptible
@MainActor
class AudioDataSource: ElementDataSource {
    init(_ audio: Audio) {
        self.name = audio.name
        self.artist = audio.artist
        self.volume = audio.volume
    }
    weak var delegate: TimelineDataSource?
    
    var name: String
    var artist: String
    var volume: Double
    
    func update(with audio: Audio) {
        if name != audio.name {
            name = audio.name
        }
        if artist != audio.artist {
            artist = audio.artist
        }
        if volume != audio.volume {
            volume = audio.volume
        }
    }
    
    func tapped() {
        delegate?.delete(self)
    }
}

@Perceptible
@MainActor
class EffectDataSource: ElementDataSource {
    init(_ effect: Effect) {
        self.name = effect.name
        self.iconName = effect.iconName
    }
    
    var name: String
    var iconName: String
    weak var delegate: TimelineDataSource?
    
    func update(with effect: Effect) {
        if name != effect.name {
            name = effect.name
        }
        if iconName != effect.iconName {
            iconName = effect.iconName
        }
    }
    
    func tapped() {
        delegate?.effectTapped(self)
//        delegate?.addAudio(name: self.name)
    }
}

private extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
