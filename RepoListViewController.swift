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
    func searchControllerState() -> Bool
    func displayAlert(title: String, message: String, actions: [UIAlertAction])
}

final class RepoListViewController: UIViewController, RepoListViewProtocol {

    // MARK: - Nested Types

    private enum Constants {
        static let offset = 16
        static let cellHeight: CGFloat = 70
        static let vcTitle = "Repositories"
    }

    // MARK: - Private Properties
    
    private var presenter: RepoListPresenterProtocol
    private var currentDataSource: DataSource = .all

    // MARK: - UI Properties

    private var searchBarButtonItem: UIBarButtonItem?
    private let searchController = UISearchController(searchResultsController: nil)

    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = .minimal
        return search
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.vcTitle
        return label
    }()

    private lazy var sortInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Author name filter"
        label.isHidden = true
        return label
    }()

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
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.up.and.down.text.horizontal"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(sortingButtonTapped))
        button.tintColor = .black
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var alertController: UIAlertController = {
        return configureSortingAlertController()
    }()

    // MARK: - Lifecycle

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
        showLoadingIndicator()
        setupUI()
        presenter.fetchFromBitBucket()
        presenter.fetchFromGitHub()
        presenter.waitForData { [weak self] in
            self?.presenter.originalRepository = self?.presenter.repositoryArray ?? []
            self?.hideLoadingIndicator()
            self?.reloadTableData()
        }
        presenter.selectedSearchType = .author
        presenter.isFiltering = searchController.isActive
        configureSearchController()
    }

    // MARK: - Methods

    func reloadTableData() {
        self.tableView.reloadData()
    }

    func searchControllerState() -> Bool {
        return searchController.isActive
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(segmentedControl)
        view.addSubview(sortInfoLabel)
        tableView.addSubview(activityIndicator)
        tableView.addSubview(refreshControl)
        view.backgroundColor = .white
        setFilterButtonMenu()
        makeConstraints()
        configureNavigationController()
    }

    private func configureNavigationController() {
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.rightBarButtonItem = sortingButton
        navigationItem.titleView = titleLabel
        searchBarButtonItem = navigationItem.rightBarButtonItem
    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Author"
        searchController.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
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

        sortInfoLabel.snp.makeConstraints {
            $0.center.equalTo(segmentedControl)
        }
    }

    private func configureSortingAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Sorting", message: "Choose sorting type", preferredStyle: .actionSheet)

        let noSortingAction = UIAlertAction(title: "No sorting", style: .default) { [weak self] _ in
            self?.presenter.repositoryArray = self?.presenter.originalRepository ?? []
            self?.reloadTableData()
        }
        alertController.addAction(noSortingAction)

        let sortByAlphabetAction = UIAlertAction(title: "(A-Z)", style: .default) { [weak self] _ in
            self?.presenter.repositoryArray = self?.presenter.sortedByName(.alphabeticalAscending, array: self?.presenter.repositoryArray ?? []) ?? []
            self?.reloadTableData()
        }
        alertController.addAction(sortByAlphabetAction)

        let sortByAlphabetReverseAction = UIAlertAction(title: "(Z-A)", style: .default) { [weak self] _ in
            self?.presenter.repositoryArray = self?.presenter.sortedByName(.alphabeticalDescending, array: self?.presenter.repositoryArray ?? []) ?? []
            self?.reloadTableData()
        }
        alertController.addAction(sortByAlphabetReverseAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        return alertController
    }

    private func setFilterButtonMenu() {
        let actionShare = UIAction(title: "Author", image: nil) { action in
            self.searchController.searchBar.placeholder = "Search by Author"
            self.presenter.selectedSearchType = .author
            self.sortInfoLabel.text = "Enter author name"
        }
        let actionAdd = UIAction(title: "Repository", image: nil) { action in
            self.searchController.searchBar.placeholder = "Search by Repository"
            self.presenter.selectedSearchType = .repository
            self.sortInfoLabel.text = "Enter repository name"

        }
        let menu = UIMenu(title: "Choose filter", children: [actionShare, actionAdd])
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil,
                                                           image: UIImage(systemName: "magnifyingglass"),
                                                           primaryAction: nil,
                                                           menu: menu)
        navigationItem.leftBarButtonItem?.tintColor = .black

    }

    // MARK: Private objc methods

    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        switch currentDataSource {
        case .all:
            presenter.waitForData {
                self.reloadTableData()
            }
        case .bitbucket:
            presenter.waitForData { [weak self] in
                self?.reloadTableData()
            }
            
        case .github:
            presenter.waitForData { [weak self] in
                self?.reloadTableData()
            }
        }
        refreshControl.endRefreshing()
    }


    @objc private func sortingButtonTapped() {
        present(alertController, animated: true, completion: nil)
    }

    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
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

     // MARK: - Extension With UITableView Configuration

extension RepoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if presenter.isFiltering{
            return presenter.filteredData.count
        } else {
            switch currentDataSource {
            case .all:
                return presenter.sortedBySource(.all, array: presenter.repositoryArray).count
            case .bitbucket:
                return presenter.sortedBySource(.bitbucket, array: presenter.repositoryArray).count
            case .github:
                return presenter.sortedBySource(.github, array: presenter.repositoryArray).count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: RepoListCell = tableView.dequeueReusableCell(for: indexPath) {
            if presenter.isFiltering{
                let repoData = presenter.filteredData[indexPath.row]
                presenter.imageForCell(repoData.image) { image in
                    cell.configure(data: repoData, image: image)
                }
            } else {
                switch currentDataSource {
                case .all:
                    let repoData = presenter.sortedBySource(.all, array: presenter.repositoryArray)[indexPath.row]
                    presenter.imageForCell(repoData.image) { image in
                        cell.configure(data: repoData, image: image)
                    }
                case .bitbucket:
                    let repoData = presenter.sortedBySource(.bitbucket, array: presenter.repositoryArray)[indexPath.row]
                    presenter.imageForCell(repoData.image) { image in
                        cell.configure(data: repoData, image: image)
                    }
                case .github:
                    let repoData = presenter.sortedBySource(.github, array: presenter.repositoryArray)[indexPath.row]
                    presenter.imageForCell(repoData.image) { image in
                        cell.configure(data: repoData, image: image)
                    }
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var selectData: Repository
        if presenter.isFiltering{
            selectData = presenter.filteredData[indexPath.row]
        } else {
            switch currentDataSource {
            case .all:
                selectData = presenter.sortedBySource(.all, array: presenter.repositoryArray)[indexPath.row]
            case .bitbucket:
                selectData = presenter.sortedBySource(.bitbucket, array: presenter.repositoryArray)[indexPath.row]
            case .github:
                selectData = presenter.sortedBySource(.github, array: presenter.repositoryArray)[indexPath.row]
            }
        }
        let nextVC = InfoViewController(presenter: InfoPresenter(data: selectData, imageLoader: ImageLoader()))
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

     //MARK:  Extension With UISearchBarDelegate Configuration

extension RepoListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        segmentedControl.isHidden = true
        sortInfoLabel.isHidden = false
        if let searchText = searchController.searchBar.text {
            self.presenter.isFiltering = true
            presenter.filterRepositoriesBySearchText(presenter.selectedSearchType, searchText: searchText)
        }
    }
}

extension RepoListViewController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        presenter.isFiltering = false
        reloadTableData()
        segmentedControl.isHidden = false
        sortInfoLabel.isHidden = true
    }
}
