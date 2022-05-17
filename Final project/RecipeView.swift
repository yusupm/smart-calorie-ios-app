//
//  RecipieVeiw.swift
//  Final project
//
//  Created by Yusup on 09/05/2022.
//

import SwiftUI

struct RecipeVeiw: View {
    @State var recipes = [Recipe]()
    @State private var searchText: String = ""
    
    var body: some View {
        List { // list of recipes
            ForEach(recipes, id: \.self) {recipe in
                NavigationLink {
                    ForEach(recipe.recipe.ingredientLines, id: \.self) {ingredient in
                        Text(ingredient)
                            .padding()
                    }
                } label: {
                    HStack {
                        let photo_url = URL(string: recipe.recipe.image)
                        AsyncImage(url: photo_url, content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 60)
                        }, placeholder: {
                            ProgressView()
                        })
                        Text(recipe.recipe.label)
                        Spacer()
                        
                        VStack {
                            Text("\(recipe.recipe.calories / recipe.recipe.yield, specifier: "%.2f") kcal")
                            Text("\(recipe.recipe.yield) servings")
                        }
                    }
                }

                
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { value in
            async {
                if !value.isEmpty && value.count > 3 {
                    await get_recipes(keyword: value)
                } else {
                    recipes.removeAll()
                }
            }
        }
    }
    
    func get_recipes(keyword: String) { // api request to fetch recipes
        
        let url = URL(string: "https://api.edamam.com/api/recipes/v2?app_id=6ea5c8b8&app_key=a5a0fe66dd5531f967a4c604e491b3c6&type=public&q=\(keyword)")

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.timeoutInterval = 60.0
        let task = URLSession.shared.dataTask(with: request) { data, _,
            error in
            guard let data = data, error == nil else{
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
                DispatchQueue.main.async {
                    self.recipes = response.hits
                }
            }
            catch {
                print(error)
            }
            
        }
        
        task.resume()
    }
    
}

struct RecipieVeiw_Previews: PreviewProvider {
    static var previews: some View {
        RecipeVeiw()
    }
}
