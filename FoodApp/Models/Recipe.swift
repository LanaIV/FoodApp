//
//  Recipe.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import Unbox

typealias RecipesArrayType = Array<Recipe>

struct Recipe {
    let id: String

    let imageUrl: String
    let publisher: String
    let sourceUrl: String
    let title: String

    let rank: Float

    let ingredients: Array<String>?
}

extension Recipe: Unboxable {
    init() {
        id = ""
        imageUrl = ""
        publisher = ""
        sourceUrl = ""
        title = ""
        rank = 0.0
        ingredients = []
    }

    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "recipe_id")
        self.imageUrl = try unboxer.unbox(key: "image_url")
        self.publisher = try unboxer.unbox(key: "publisher")
        self.sourceUrl = try unboxer.unbox(key: "source_url")
        self.title = try unboxer.unbox(key: "title")
        self.rank = try unboxer.unbox(key: "social_rank")

        self.ingredients = unboxer.unbox(key: "ingredients")
    }
}
