//
//  AddCalorieSheet.swift
//  Final project
//
//  Created by BOLT on 28/04/2022.
//

import SwiftUI


struct AddCalorieSheet: View {
    
    @State var nutritions = [Nutrition]()
    @StateObject var globalString = GlobalString()
    @State private var searchText: String = ""
    
    @Binding var progress: Float
    @Binding var foodEaten_name: [String]
    @Binding var foodEaten_calorie: [Double]
    @Binding var foodEaten_image: [String]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            List {
                ForEach(nutritions, id: \.self) {nutrition in
                    
                    Button(action: {
                        progress += (Float(nutrition.nf_calories) / Float(globalString.totalCalory))
                        presentationMode.wrappedValue.dismiss()
                        foodEaten_calorie.append(nutrition.nf_calories)
                        foodEaten_image.append(nutrition.photo.thumb)
                        foodEaten_name.append(nutrition.food_name)
                    }, label: {
                        HStack{
                            let photo_url = URL(string: nutrition.photo.thumb)
                            AsyncImage(url: photo_url, content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 60)
                            }, placeholder: {
                                ProgressView()
                            })
                            VStack {
                                HStack {
                                    Text(nutrition.food_name)
                                    Spacer()
                                }
                                HStack {
                                    Text("\(nutrition.serving_qty, specifier: "%.2f") \(nutrition.serving_unit)")
                                    Spacer()
                                }
                            }
                            Spacer()
                            Text("\(nutrition.nf_calories, specifier: "%.2f") kcal")
                            
                        }
                    })
                    
                }
            }
            .navigationTitle("Add Food")
            .listStyle(.plain)
            .searchable(text: $searchText)
            .onChange(of: searchText) { value in
                async {
                    if !value.isEmpty && value.count > 3 {
                        await fetch(searchTerm: value)
                    } else {
                        nutritions.removeAll()
                    }
                }
            }
        }
    }
    
    func fetch(searchTerm: String){
        
        let url = URL(string: "https://trackapi.nutritionix.com/v2/search/instant?query=\(searchTerm)")

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("48c5d2b3", forHTTPHeaderField:"x-app-id")
        request.setValue("274757a70dbb78be6611d630f168f4fe", forHTTPHeaderField:"x-app-key")
        request.setValue("0", forHTTPHeaderField:"x-remote-user-id")
        request.timeoutInterval = 60.0
        
        let task = URLSession.shared.dataTask(with: request) { data, _,
            error in
            guard let data = data, error == nil else{
                return
            }
            
            do {
                let nutritions = try JSONDecoder().decode(NutritionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.nutritions = nutritions.branded
                }
            }
            catch {
                print(error)
            }
            
        }
        
        task.resume()
    }
    func search_item(nix_id: String){
        
        let url = URL(string: "https://trackapi.nutritionix.com/v2/search/item?nix_item_id=\(nix_id)")

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("48c5d2b3", forHTTPHeaderField:"x-app-id")
        request.setValue("274757a70dbb78be6611d630f168f4fe", forHTTPHeaderField:"x-app-key")
        request.setValue("0", forHTTPHeaderField:"x-remote-user-id")
        request.timeoutInterval = 60.0
        
        let task = URLSession.shared.dataTask(with: request) { data, _,
            error in
            guard let data = data, error == nil else{
                return
            }
            
            do {
                let nutritions = try JSONDecoder().decode(NutritionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.nutritions = nutritions.branded
                }
            }
            catch {
                print(error)
            }
            
        }
        
        task.resume()
    }
}
