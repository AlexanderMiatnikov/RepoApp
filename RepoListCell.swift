//
//  RepoListCell.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import UIKit
import SnapKit

final class RepoListCell: UITableViewCell {

    // MARK: - Nested Types

    private enum Constants {
        static let fontSize: CGFloat = 14
        static let boldFontSize: CGFloat = 15
        static let padding: CGFloat = 8
        static let labelTopOffset = 4
        static let imageCornerRadius: CGFloat = 20
    }

    // MARK: - UI Properties

    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Constants.boldFontSize)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.fontSize)
        return label
    }()

    private lazy var sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.fontSize)
        return label
    }()


    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = "no info"
        descriptionLabel.text = "no info"
        userImage.image = UIImage(named: "gitavatar")
    }

    // MARK: - Methods

    func configure(data: Repository, image: Data?) {
        titleLabel.text = data.name
        descriptionLabel.text = data.description
        sourceLabel.text = data.source.rawValue
        if let imageData = image {
            userImage.image = UIImage(data: imageData)
        } else {
            userImage.image = UIImage(named: "gitavatar")
        }
    }

    // MARK: - Private Methods

    private func setupUI() {

        contentView.addSubview(userImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(sourceLabel)
        backgroundColor = .white
        makeConstraints()
    }

    private func makeConstraints() {

        userImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.padding)
            $0.left.equalToSuperview().offset(Constants.padding)
            $0.bottom.equalToSuperview().inset(Constants.padding)
            $0.width.equalTo(userImage.snp.height)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(userImage)
            $0.left.equalTo(userImage.snp.right).offset(Constants.padding)
            $0.right.equalToSuperview().offset(-Constants.padding)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.labelTopOffset)
            $0.left.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-Constants.padding)
        }

        sourceLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-Constants.padding)
            $0.right.equalToSuperview().offset(-Constants.padding)
        }
    }
}
