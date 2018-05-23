//
//  SearchTableViewCell.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!

    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        photoImageView.image = #imageLiteral(resourceName: "no-recipe")
    }

    func configure(recipe: Recipe) {
        titleLabel.text = recipe.title
        publisherLabel.text = recipe.publisher
        rankLabel.text = "Rank: \(recipe.rank)"

        NetworkManager.retrieveRecipePhoto(imageUrl: recipe.imageUrl) { [weak self] data, error in
            self?.photoImageView.image = UIImage(data: data)
        }
    }
}
