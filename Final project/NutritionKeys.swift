//
//  NutritionKeys.swift
//  Final project
//
//  Created by Yusup on 28/04/2022.
//

import SwiftUI
import AuthenticationServices

// MARK: - Instant nutrition resposne

struct NutritionResponse: Hashable, Codable {
    let branded: [Nutrition]
}
struct NutritionResponse2: Hashable, Codable {
    let foods: [Nutrition]
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

// MARK: - Detailed Nutritionix resposne

struct DetailedNutrition: Hashable, Codable {
    let nf_total_fat: Double?
    let nf_total_carbohydrate: Double?
    let nf_protein: Float?
    let nf_sugars: Double?
    let serving_weight_grams: Float?
}


struct DetailedResponse: Hashable, Codable{
    let foods: [DetailedNutrition]
}


// MARK: - Recipe

struct RecipeResponse: Hashable, Codable {
    let hits: [Recipe]
}

struct Recipe: Hashable, Codable {
    let recipe: RecipeDetails
}

struct RecipeDetails: Hashable, Codable {
    let label: String
    let image: String
    let url: String
    let ingredientLines: [String]
    let calories: Double
    let totalTime: Double
    let yield: Double
}




// MARK: - Clarifai

struct ClarifaiResponse: Hashable, Codable {
    let status: Clarifai
    let outputs: [ClarifaiOutputs]
    
}

struct ClarifaiOutputs: Hashable, Codable{
    let data: ClarifaiData
}


struct ClarifaiData: Hashable, Codable{
    let concepts: [ClarifaiConcepts]
}

struct ClarifaiConcepts: Hashable, Codable{
    let name: String
    let value: Double
}


struct Clarifai: Hashable, Codable {
    let code: Int
    let description: String
}


struct Request: Codable {
    let inputs: [CInput]
}


struct CInput: Codable {
    let data: CDataClass
}


struct CDataClass: Codable {
    let image: CImage
}

struct CImage: Codable {
    let base64: String
}
