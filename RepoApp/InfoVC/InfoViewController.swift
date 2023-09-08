//
//  InfoViewController.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 8.09.23.
//

import UIKit
import SnapKit

class InfoViewController: UIViewController {

    private var presenter: InfoPresenterProtocol

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()

    private lazy var repositoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    private lazy var sourceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.italicSystemFont(ofSize: 16)
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

        view.addSubview(imageView)
        view.addSubview(repositoryLabel)
        view.addSubview(authorLabel)
        view.addSubview(sourceLabel)
        makeConstraints()

      view.backgroundColor = .white
    }

    func setData() {
        presenter.setImage(presenter.repository.image) { image in
            if let imageData = image {
                self.imageView.image = UIImage(data: imageData)
            } else {
                self.imageView.image = UIImage(named: "gitavatar")
            }
        }

        repositoryLabel.text = presenter.repository.description
          authorLabel.text = presenter.repository.name
        sourceLabel.text = presenter.repository.source.rawValue
    }

    private func makeConstraints() {

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.width.height.equalTo(200)
        }

        repositoryLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.top.equalTo(imageView.snp.bottom).offset(20)
        }

        authorLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.top.equalTo(repositoryLabel.snp.bottom).offset(10)
        }

        sourceLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-50)
        }
    }
}
