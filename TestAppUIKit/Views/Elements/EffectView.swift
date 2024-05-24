import UIKit
import SnapKit
import Perception

class EffectView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 40)
    }
    private weak var source: EffectDataSource?
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
    private let iconView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ effect: EffectDataSource) {
        guard effect !== source else { return }
        source = effect
        observe()
    }
    
    func observe() {
        guard let source else { return }
        print("redraw effect with name: \(source.name)")
        withPerceptionTracking {
            titleLabel.text = source.name
            iconView.image = UIImage(systemName: source.iconName)
        } onChange: {
            Task { @MainActor in
                self.observe()
            }
        }
    }
    
    func setupUI() {
        backgroundColor = .green.withAlphaComponent(0.2)
        [borderView, titleLabel, iconView].forEach(addSubview)
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(5)
        }
        iconView.snp.makeConstraints { make in
            make.trailing.verticalEdges.equalToSuperview()
            make.width.equalTo(iconView.snp.height)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    @objc func tapped() {
        source?.tapped()
    }
}
