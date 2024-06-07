import UIKit
import SnapKit
import Perception

class VideoView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 40)
    }
    private weak var source: VideoDataSource?
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
    private let hasSoundView: UIImageView = {
        let image = UIImage(systemName: "music.note")
        let view = UIImageView(image: image)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ video: VideoDataSource) {
        guard video !== source else { return }
        source = video
        observe { [weak self, weak video] in
            guard let self, let video else { return }
            titleLabel.text = video.name
            hasSoundView.isHidden = !video.hasSound
        }
    }
    
    func setupUI() {
        backgroundColor = .red.withAlphaComponent(0.2)
        [borderView, titleLabel, hasSoundView].forEach(addSubview)
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(5)
        }
        hasSoundView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    @objc func tapped() {
        source?.tapped()
    }
}
