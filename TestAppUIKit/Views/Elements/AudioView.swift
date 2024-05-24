import UIKit
import SnapKit
import Perception

class AudioView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 40)
    }
    private weak var source: AudioDataSource?
    private let borderView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ audio: AudioDataSource) {
        guard audio !== source else { return }
        source = audio
        observe()
    }
    
    func observe() {
        guard let source else { return }
        print("redraw audio with name: \(source.name)")
        withPerceptionTracking {
            titleLabel.text = source.name
            artistLabel.text = source.artist
            volumeLabel.text = "\(source.volume)"
        } onChange: {
            Task { @MainActor in
                self.observe()
            }
        }
    }

    func setupUI() {
        backgroundColor = .blue.withAlphaComponent(0.2)
        [borderView, titleLabel, artistLabel, volumeLabel].forEach(addSubview)
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(5)
        }
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(5)
        }
        volumeLabel.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    @objc func tapped() {
        source?.tapped()
    }
}
