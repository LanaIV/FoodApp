//
//  IngredientsTableViewCellViewModel.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

struct IngredientsTableViewCellViewModel {

    let ingredientsLabel: String

    init(ingredients: Array<String>) {
        self.ingredientsLabel = ingredients.reduce("", { (prev, next) -> String in
            return "\(prev)➣ \(next)\n"
        })
    }
}
