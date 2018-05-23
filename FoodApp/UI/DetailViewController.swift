//
//  DetailViewController.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let defaultCellHeight = 44.0
    static let mainInfoCellIdentifier = "MainInfoTableViewCell"
    static let ingredientsCellIdentifier = "IngredientsTableViewCell"
}

class DetailViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    var recipe: Recipe

    var recipeDetailsViewModels: Array<Any> = []

    init(recipe: Recipe) {
        self.recipe = recipe
        super.init(nibName: nil, bundle: nil)
        self.recipeDetailsViewModels = computeRecipeDetailsViewModels(recipe: recipe)
    }

    required init?(coder aDecoder: NSCoder) {
        self.recipe = Recipe()
        super.init(coder: aDecoder)
        self.recipeDetailsViewModels = computeRecipeDetailsViewModels(recipe: recipe)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        retrieveData()
    }

    private func computeRecipeDetailsViewModels(recipe: Recipe) -> Array<Any> {
        var viewModels = [MainInfoTableViewCellViewModel(rank: recipe.rank, title: recipe.title, publisher: recipe.publisher)] as Array<Any>
        if let ingredients = recipe.ingredients {
             viewModels.append(IngredientsTableViewCellViewModel(ingredients: ingredients))
        }
        return viewModels as [Any]
    }

    private func retrieveData() {
        NetworkManager.retrieveRecipeDetail(id: recipe.id) { (recipe, error) in
            guard error == nil else {
                return
            }
            self.recipe = recipe
            self.recipeDetailsViewModels = self.computeRecipeDetailsViewModels(recipe: recipe)
            self.tableView.reloadData()
        }
    }

    private func setupView() {
        setupPhotoImageView()
        setupTableView()
    }

    private func setupPhotoImageView() {
        NetworkManager.retrieveRecipePhoto(imageUrl: recipe.imageUrl) { [weak self] data,  error in
            guard error == nil else {
                return
            }
            self?.photoImageView.image = UIImage(data: data)
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.mainInfoCellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: Constants.mainInfoCellIdentifier)
        tableView.register(UINib(nibName: Constants.ingredientsCellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: Constants.ingredientsCellIdentifier)

        tableView.estimatedRowHeight = CGFloat(Constants.defaultCellHeight)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDetailsViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch recipeDetailsViewModels[indexPath.row] {
        case let viewModel as MainInfoTableViewCellViewModel:
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.mainInfoCellIdentifier) as? MainInfoTableViewCell {
                cell.configure(viewModel: viewModel)
                return cell
            }
        case let viewModel as IngredientsTableViewCellViewModel:
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ingredientsCellIdentifier) as? IngredientsTableViewCell {
                cell.configure(viewModel: viewModel)
                return cell
            }
        default:
            break
        }

        return UITableViewCell()
    }
}

