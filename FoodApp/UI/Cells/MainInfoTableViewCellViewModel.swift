//
//  MainInfoTableViewCellViewModel.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

struct MainInfoTableViewCellViewModel {
    
    let rankLabel: String
    let titleLabel: String
    let publisherLabel: String

    init(rank: Float, title: String, publisher: String) {
        self.rankLabel = "Rank: \(rank)"
        self.titleLabel = title
        self.publisherLabel = "Published by \(publisher)"
    }
}
