//
//  IngredientsTableViewCell.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {
    typealias ViewModelType = IngredientsTableViewCellViewModel

    @IBOutlet weak var ingredientsLabel: UILabel!

    func configure(viewModel: ViewModelType) {
        ingredientsLabel.text = viewModel.ingredientsLabel
    }

}
