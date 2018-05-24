//
//  DetailViewController.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

fileprivate enum Constants {
    static let defaultCellHeight = 44.0
    static let mainInfoCellIdentifier = "MainInfoTableViewCell"
    static let ingredientsCellIdentifier = "IngredientsTableViewCell"
}

class DetailViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    var disposeBag = DisposeBag()

    var recipe: Variable<Recipe>

    var recipeDetailsItems: Variable<Array<CustomItem>> = Variable([])

    init(recipe: Recipe) {
        self.recipe = Variable(recipe)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.recipe = Variable(Recipe())
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recipe.asObservable()
            .map { [weak self] (recipe) in
                return self?.computeRecipeDetailsViewModels(recipe: recipe) ?? []
            }
            .bind(to: recipeDetailsItems)
            .disposed(by: disposeBag)

        recipe.asObservable()
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }
            .disposed(by: disposeBag)

        setupView()
        retrieveData()
    }

    private func computeRecipeDetailsViewModels(recipe: Recipe) -> Array<CustomItem> {
        let mainInfoViewModel = MainInfoTableViewCellViewModel(rank: recipe.rank, title: recipe.title, publisher: recipe.publisher)
        var customItems = [CustomItem.MainInfoItem(viewModel: mainInfoViewModel)]
        if let ingredients = recipe.ingredients {
            let ingredientsViewModel = IngredientsTableViewCellViewModel(ingredients: ingredients)
            customItems.append(CustomItem.IngredientsItem(viewModel: ingredientsViewModel))
        }
        return customItems
    }

    private func retrieveData() {
        NetworkManager.retrieveRecipeDetail(id: recipe.value.id)
            .subscribe(onNext: { [weak self] (recipe, error) in
                guard let recipe = recipe else {
                    return
                }
                self?.recipe.value = recipe
            })
            .disposed(by: disposeBag)
    }

    private func setupView() {
        setupPhotoImageView()
        setupTableView()
    }

    private func setupPhotoImageView() {
        NetworkManager.retrieveRecipePhoto(imageUrl: recipe.value.imageUrl)
            .subscribe(onNext: { [weak self] (data) in
                self?.photoImageView.image = UIImage(data: data)
            })
            .disposed(by: disposeBag)
        }

    private func setupTableView() {
        tableView.register(UINib(nibName: Constants.mainInfoCellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: Constants.mainInfoCellIdentifier)
        tableView.register(UINib(nibName: Constants.ingredientsCellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: Constants.ingredientsCellIdentifier)

        tableView.estimatedRowHeight = CGFloat(Constants.defaultCellHeight)
        tableView.rowHeight = UITableViewAutomaticDimension

        let dataSource = RxTableViewSectionedReloadDataSource<CustomSectionModel>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case .MainInfoItem(let viewModel):
                let cell: MainInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.mainInfoCellIdentifier, for: indexPath) as! MainInfoTableViewCell
                cell.configure(viewModel: viewModel)
                return cell
            case .IngredientsItem(let viewModel):
                let cell: IngredientsTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.ingredientsCellIdentifier, for: indexPath) as! IngredientsTableViewCell
                cell.configure(viewModel: viewModel)
                return cell
            }
        })

        recipeDetailsItems.asObservable()
            .map({ (items) -> Array<CustomSectionModel> in
                return [CustomSectionModel.DefaultSection(title: "", items: items)]
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

enum CustomSectionModel {
    case DefaultSection(title: String, items: Array<CustomItem>)
}

extension CustomSectionModel: SectionModelType {
    typealias Item = CustomItem

    var items: [CustomItem] {
        switch self {
        case .DefaultSection(_, let items):
            return items
        }
    }

    init(original: CustomSectionModel, items: [CustomItem]) {
        switch original {
        case .DefaultSection(let title, _):
            self = .DefaultSection(title: title, items: items)
        }
    }

}

enum CustomItem {
    case MainInfoItem(viewModel: MainInfoTableViewCellViewModel)
    case IngredientsItem(viewModel: IngredientsTableViewCellViewModel)
}
