//
//  SearchViewController.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import NVActivityIndicatorView

fileprivate enum Constants {
    static let cellIdentifier = "SearchTableViewCell"
    static let defaultCellHeight = 44.0
}

class SearchViewController: UIViewController {

    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    var recipes = Variable<RecipesArrayType>([])

    let query = Variable<String>("")

    override func viewDidLoad() {
        super.viewDidLoad()
        query.asObservable()
            .subscribe(onNext: { [weak self] (query) in
                self?.retrieveData(query: query)
            })
            .disposed(by: disposeBag)
        setupView()
    }

    fileprivate func retrieveData(query: String) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        NetworkManager.searchRecipes(query: query)
            .subscribe(onNext: { [weak self] (recipes) in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self?.recipes.value = recipes
                self?.tableView.reloadData()
                if recipes.count > 0 {
                    self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupView() {
        setupNoResultsLabel()
        setupSearchBar()
        setupTableView()
    }

    private func setupNoResultsLabel() {
        recipes.asObservable()
            .map { $0.count != 0 }
            .bind(to: noResultsLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }

    private func setupSearchBar() {
        searchBar.rx
            .text.orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .bind(to: query)
            .disposed(by: disposeBag)

        searchBar.rx
            .searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: Constants.cellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: Constants.cellIdentifier)

        tableView.estimatedRowHeight = CGFloat(Constants.defaultCellHeight)
        tableView.rowHeight = UITableViewAutomaticDimension

        recipes.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: Constants.cellIdentifier, cellType: SearchTableViewCell.self)) { index, recipe, cell in
                cell.configure(recipe: recipe)
            }
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(Recipe.self)
            .subscribe(onNext: { [weak self] (recipe) in
                let detailViewController = DetailViewController(recipe: recipe)
                self?.navigationController?.show(detailViewController, sender: self)
            })
            .disposed(by: disposeBag)
    }
}
