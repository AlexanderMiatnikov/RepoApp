//
//  RepoListViewController.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import UIKit
import SnapKit

protocol RepoListViewProtocol: AnyObject {
    func reloadTableData()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func displayAlert(title: String, message: String, actions: [UIAlertAction])
}

 enum DataSource {
    case all
    case bitbucket
    case github
}

final class RepoListViewController: UIViewController, RepoListViewProtocol{

    private enum Constants {
        static let offset = 16
        static let cellHeight: CGFloat = 70
        static let vcTitle = "Repositories"
    }

    private var presenter: RepoListPresenterProtocol
    private var currentDataSource: DataSource = .all

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClasses: RepoListCell.self)
        tableView.backgroundColor = .white
        return tableView
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["All", "Bitbucket", "Github"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        segmentedControl.backgroundColor = .yellow
        return segmentedControl
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()

    private lazy var sortingButton = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.up.and.down.text.horizontal"), style: .plain, target: self, action: #selector(sortingButtonTapped))
        button.tintColor = .black
        return button
    }()

    private lazy var filterButton = {
        let button = UIBarButtonItem(image: UIImage(systemName: "binoculars.fill"), style: .plain, target: self, action: #selector(filterButtonTapped))
        button.tintColor = .black
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Сортировка", message: "Выберите тип сортировки", preferredStyle: .actionSheet)

        let noSortingAction = UIAlertAction(title: "Без сортировки", style: .default) { [weak self] _ in
            self?.presenter.repository = self?.presenter.sortedByName(.none, array: self?.presenter.repository ?? []) ?? []
            self?.reloadTableData()
        }
        alertController.addAction(noSortingAction)

        let sortByAlphabetAction = UIAlertAction(title: "По алфавиту (A-Z)", style: .default) { [weak self] _ in
            self?.presenter.repository = self?.presenter.sortedByName(.alphabeticalAscending, array: self?.presenter.repository ?? []) ?? []
            self?.reloadTableData()
        }
        alertController.addAction(sortByAlphabetAction)

        let sortByAlphabetReverseAction = UIAlertAction(title: "По алфавиту (Z-A)", style: .default) { [weak self] _ in
            self?.presenter.repository = self?.presenter.sortedByName(.alphabeticalDescending, array: self?.presenter.repository ?? []) ?? []
            self?.reloadTableData()
        }
        alertController.addAction(sortByAlphabetReverseAction)

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }()

    init(presenter: RepoListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.fetchFromBitBucket()
        presenter.fetchFromGitHub()
        showLoadingIndicator()

        presenter.waitForData { [weak self] in
            self?.hideLoadingIndicator()
        }
    }

    private func setupUI() {

        title = Constants.vcTitle
        view.addSubview(tableView)
        view.addSubview(segmentedControl)
        tableView.addSubview(activityIndicator)
        tableView.addSubview(refreshControl)
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.rightBarButtonItem = sortingButton
        navigationItem.leftBarButtonItem = filterButton
        view.backgroundColor = .white
        makeConstraints()
    }

    private func makeConstraints() {

        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(Constants.offset)
            $0.left.right.bottom.equalToSuperview()
        }

        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.offset)
            $0.left.equalToSuperview().offset(Constants.offset)
            $0.right.equalToSuperview().inset(Constants.offset)
        }
    }

    func reloadTableData() {
        self.tableView.reloadData()
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    // MARK: objc methods

    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        switch currentDataSource {
        case .all:
                        presenter.waitForData {
                            self.reloadTableData()
                        }
        case .bitbucket:
            presenter.fetchFromBitBucket()
            
        case .github:
            presenter.fetchFromGitHub()
        }
        tableView.reloadData()
        refreshControl.endRefreshing()

    }

    @objc private func sortingButtonTapped() {
        present(alertController, animated: true, completion: nil)
    }

    @objc private func filterButtonTapped() {
    }

    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentDataSource = .all
        case 1:
            currentDataSource = .bitbucket
        case 2:
            currentDataSource = .github
        default:
            break
        }
        tableView.reloadData()
    }
}

extension RepoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentDataSource {
        case .bitbucket:
            return presenter.bitbucketRepos.count
        case .github:
            return presenter.githubRepos.count
        case .all:
            return presenter.repository.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: RepoListCell = tableView.dequeueReusableCell(for: indexPath) {
            switch currentDataSource {
            case .all:
                let repoData = presenter.sortedBySource(.all, array: presenter.repository)[indexPath.row]
                presenter.imageForCell(repoData.image) { image in
                    cell.configure(data: repoData, image: image)
                }
            case .bitbucket:
                let repoData = presenter.sortedBySource(.bitbucket, array: presenter.repository)[indexPath.row]
                presenter.imageForCell(repoData.image) { image in
                    cell.configure(data: repoData, image: image)
                }
            case .github:
                let repoData = presenter.sortedBySource(.github, array: presenter.repository)[indexPath.row]
                presenter.imageForCell(repoData.image) { image in
                    cell.configure(data: repoData, image: image)
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var selectData: Repository
        switch currentDataSource {
        case .all:
             selectData = presenter.sortedBySource(.all, array: presenter.repository)[indexPath.row]
        case .bitbucket:
             selectData = presenter.sortedBySource(.bitbucket, array: presenter.repository)[indexPath.row]
        case .github:
             selectData = presenter.sortedBySource(.github, array: presenter.repository)[indexPath.row]
        }
        let nextVC = InfoViewController(presenter: InfoPresenter(data: selectData, imageLoader: ImageLoader()))
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
