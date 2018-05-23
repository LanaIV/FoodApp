//
//  SearchViewController.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import UIKit

import NVActivityIndicatorView

fileprivate enum Constants {
    static let cellIdentifier = "SearchTableViewCell"
    static let defaultCellHeight = 44.0
}

class SearchViewController: UIViewController {

    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!


    var recipes: RecipesArrayType = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        retrieveData()
    }

    fileprivate func retrieveData(query: String = "") {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        NetworkManager.searchRecipes(query: query) { [weak self] recipes, error in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            guard error == nil else {
                return
            }
            self?.recipes = recipes
            self?.tableView.reloadData()
            self?.noResultsLabel.isHidden = !recipes.isEmpty
            if recipes.count > 0 {
                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    private func setupView() {
        setupNoResultsLabel()
        setupSearchBar()
        setupTableView()
    }

    private func setupNoResultsLabel() {
        noResultsLabel.isHidden = true
    }

    private func setupSearchBar() {
        searchBar.delegate = self
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.cellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: Constants.cellIdentifier)

        tableView.estimatedRowHeight = CGFloat(Constants.defaultCellHeight)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        retrieveData(query: searchText)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(recipe: recipes[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController(recipe: recipes[indexPath.row])
        navigationController?.show(detailViewController, sender: self)
    }
}
