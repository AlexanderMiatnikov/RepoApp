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
}

final class RepoListViewController: UIViewController, RepoListViewProtocol{

    private enum Constants {
        static let offset = 16
        static let cellHeight: CGFloat = 70
        static let vcTitle = "Repositories"
    }

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
        let button = UIBarButtonItem(image: UIImage(systemName: "binoculars.fill"), style: .plain, target: self, action: #selector(sortingButtonTapped))
        button.tintColor = .black
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {

        title = Constants.vcTitle
        view.addSubview(tableView)
        view.addSubview(segmentedControl)
        tableView.addSubview(refreshControl)
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.rightBarButtonItem = sortingButton
        navigationItem.leftBarButtonItem = filterButton
        view.backgroundColor = .white
        makeConstraints()
    }

    private func makeConstraints() {

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

    // MARK: objc methods

    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    @objc private func sortingButtonTapped() {

    }

    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
        }
        else if sender.selectedSegmentIndex == 1 {
        }
        else {
            
        }
    }
}

extension RepoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: RepoListCell = tableView.dequeueReusableCell(for: indexPath) {


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

    }
}
