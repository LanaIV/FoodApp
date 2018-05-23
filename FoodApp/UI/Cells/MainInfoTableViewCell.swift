//
//  MainInfoTableViewCell.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import UIKit

class MainInfoTableViewCell: UITableViewCell {

    typealias ViewModelType = MainInfoTableViewCellViewModel

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(viewModel: ViewModelType) {
        rankLabel.text = viewModel.rankLabel
        titleLabel.text = viewModel.titleLabel
        publisherLabel.text = viewModel.publisherLabel
    }
}
