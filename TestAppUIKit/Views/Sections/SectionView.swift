import UIKit
import Perception

class SectionView<T: ElementDataSource>: UIView {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5
        view.distribution = .fillEqually
        return view
    }()
    private weak var source: TimelineDataSource?
    private var currentKeyPath: KeyPath<TimelineDataSource, [T]>?
    private var elementViews: [ObjectIdentifier: UIView] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        stackView.intrinsicContentSize
    }
    
    func setup(dataSource: TimelineDataSource, keyPath: KeyPath<TimelineDataSource, [T]>) {
        guard dataSource !== source && keyPath != currentKeyPath else {
            return
        }
        source = dataSource
        currentKeyPath = keyPath
        draw(dataSource[keyPath: keyPath])
        observe()
    }
    
    func observe() {
        guard let source, let currentKeyPath else { return }
        print("redraw section view for \(T.self).")
        withPerceptionTracking {
            _ = source[keyPath: currentKeyPath].count
        } onChange: {
            Task { @MainActor in
                self.draw(source[keyPath: currentKeyPath])
                self.observe()
            }
        }
    }
    
    func draw(_ elements: [T]) {
        let newElementIds = elements.map(ObjectIdentifier.init)
        for (id, element) in zip(newElementIds, elements) {
            if elementViews.keys.contains(id) {
                continue
            } else {
                switch element {
                case let video as VideoDataSource:
                    let view = VideoView()
                    view.setup(video)
                    elementViews[id] = view
                    stackView.addArrangedSubview(view)
                case let audio as AudioDataSource:
                    let view = AudioView()
                    view.setup(audio)
                    elementViews[id] = view
                    stackView.addArrangedSubview(view)
                case let effect as EffectDataSource:
                    let view = EffectView()
                    view.setup(effect)
                    elementViews[id] = view
                    stackView.addArrangedSubview(view)
                default:
                    fatalError()
                }
            }
        }
        for (id, view) in elementViews where newElementIds.doesNotContain(element: id) {
            elementViews[id] = nil
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

private extension SectionView {
    
    func setupUI() {
        backgroundColor = .gray.withAlphaComponent(0.1)
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
}

extension Sequence where Element: Equatable {
    func doesNotContain(element: Element) -> Bool {
        !contains(element)
    }
}
