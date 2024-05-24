import UIKit
import SnapKit

class ViewController: UIViewController {

    let scrollView = UIScrollView()
    let videoSectionView = SectionView<VideoDataSource>()
    let audioSectionView = SectionView<AudioDataSource>()
    let effectSectionView = SectionView<EffectDataSource>()
    let setRandomTimelineButton: UIButton = {
        let button = UIButton()
        button.setTitle("Set random timeline", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    let viewModel: ViewModel
    
    required init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    func setupUI() {
        view.backgroundColor = .white
        [scrollView, setRandomTimelineButton].forEach(view.addSubview)
        
        [videoSectionView, audioSectionView, effectSectionView].forEach(scrollView.addSubview)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(200)
        }
        videoSectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        audioSectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(videoSectionView.snp.bottom).offset(5)
        }
        effectSectionView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.top.equalTo(audioSectionView.snp.bottom).offset(5)
        }
        setRandomTimelineButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.top.equalTo(scrollView.snp.bottom).inset(10)
        }
    }
    
    func bind() {
        videoSectionView.setup(dataSource: viewModel.dataSource, keyPath: \.videos)
        audioSectionView.setup(dataSource: viewModel.dataSource, keyPath: \.audios)
        effectSectionView.setup(dataSource: viewModel.dataSource, keyPath: \.effects)
        
        setRandomTimelineButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        viewModel.buttonTapped()
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.itemTapped(at: indexPath)
    }
}
