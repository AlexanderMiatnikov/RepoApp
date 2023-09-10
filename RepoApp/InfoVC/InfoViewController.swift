//
//  InfoViewController.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 8.09.23.
//

import UIKit
import SnapKit

final class InfoViewController: UIViewController {

    private enum Constants {
        static let imageCornerRadius: CGFloat = 20
        static let repositoryLabelFontSize: CGFloat = 20
        static let authorLabelFontSize: CGFloat = 18
        static let sourceLabelFontSize: CGFloat = 16
        static let imageSide: CGFloat = 200
        static let imageYOffset: CGFloat = 100
        static let labelsSideOffset: CGFloat = 20
        static let authorLabelTop: CGFloat = 10
        static let sourceLabelBottomOffset: CGFloat = 50
    }

    private var presenter: InfoPresenterProtocol

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        return imageView
    }()

    private lazy var repositoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: Constants.repositoryLabelFontSize)
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Constants.authorLabelFontSize)
        return label
    }()

    private lazy var sourceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.italicSystemFont(ofSize: Constants.sourceLabelFontSize)
        return label
    }()

    init(presenter: InfoPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
    }

    private func setupUI() {
        navigationController?.navigationBar.tintColor = .black
        view.addSubview(imageView)
        view.addSubview(repositoryLabel)
        view.addSubview(authorLabel)
        view.addSubview(sourceLabel)
        makeConstraints()
        view.backgroundColor = .white
    }

    private func setData() {
        presenter.setImage(presenter.repository.image) { image in
            if let imageData = image {
                self.imageView.image = UIImage(data: imageData)
            } else {
                self.imageView.image = UIImage(named: Asset.gitavatar.name)
            }
        }

        repositoryLabel.text = presenter.repository.description
        authorLabel.text = presenter.repository.name
        sourceLabel.text = presenter.repository.source.rawValue
    }

    private func makeConstraints() {

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-Constants.imageYOffset)
            $0.width.height.equalTo(Constants.imageSide)
        }
        
        repositoryLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.labelsSideOffset)
            $0.top.equalTo(imageView.snp.bottom).offset(Constants.labelsSideOffset)
        }

        authorLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.labelsSideOffset)
            $0.top.equalTo(repositoryLabel.snp.bottom).offset(Constants.authorLabelTop)
        }

        sourceLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Constants.sourceLabelBottomOffset)
        }
    }
}
