//
//  NutritionKeys.swift
//  Final project
//
//  Created by BOLT on 28/04/2022.
//

import SwiftUI


struct NutritionResponse: Hashable, Codable {
    let branded: [Nutrition]
}
struct Nutrition: Hashable, Codable {
    let food_name: String
    let nf_calories: Double
    let photo: PhotoJson
    let serving_unit: String
    let serving_qty: Double
    let nix_item_id: String
}

struct PhotoJson: Hashable, Codable {
    let thumb: String
}

struct DetailedNutrition: Hashable, Codable {
    let nf_total_fat: Double
    let nf_total_carbohydrate: Double
    let nf_protein: Double
    let nf_sugars: Double
}


struct DetailedResponse: Hashable, Codable{
    let foods: [DetailedNutrition]
}
