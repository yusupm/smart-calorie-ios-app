//
//  AddCalorieSheet.swift
//  Final project
//
//  Created by BOLT on 28/04/2022.
//

import SwiftUI
import Firebase
import CodeScanner

struct AddCalorieSheet: View {
    
    @State var nutritions = [Nutrition]()
    @StateObject var globalString = GlobalString()
    @State private var searchText: String = ""
    @State var foods_eaten: [NSDictionary] = []
    @State var detailed_nutrition = [DetailedNutrition]()
    @State var group = DispatchGroup()
    
    @State private var isShowingScanner = false
    
    @Binding var progress: Float
    
    @EnvironmentObject var viewModel: AppViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
            NavigationView{
                VStack{
                    NavigationLink(destination: CodeScannerView(codeTypes: [.ean8, .ean13],simulatedData: "5060245605397", completion: handleScan), isActive: $isShowingScanner) {
                        EmptyView()
                    }
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.foregroundColor)
                        TextField("Test", text: $searchText)
                            .foregroundColor(Color.foregroundColor)
                            .disableAutocorrection(true)
                            .overlay(
                                Image(systemName: "xmark.circle.fill")
                                    .padding()
                                    .offset(x: 10)
                                    .foregroundColor(Color.foregroundColor)
                                    .opacity(searchText.isEmpty ? 0.0: 1.0)
                                    .onTapGesture {
                                        searchText = ""
                                    }
                                ,alignment: .trailing
                            )
                        Button {
                            isShowingScanner = true
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.textColor)
                                .cornerRadius(30)
                        }
                    }
                    .font(.headline)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.backgroundColor)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                    )
                    .padding()
                    List {
                        ForEach(nutritions, id: \.self) {nutrition in
                            
                            Button(action: {
                                self.group.enter()
                                
                                search_item(nix_id: nutrition.nix_item_id)
                                self.group.notify(queue: .main){
                                    progress += (Float(nutrition.nf_calories) / Float(globalString.totalCalory))
                                    presentationMode.wrappedValue.dismiss()
                                    viewModel.foodEaten_calorie.append(nutrition.nf_calories)
                                    viewModel.foodEaten_image.append(nutrition.photo.thumb)
                                    viewModel.foodEaten_name.append(nutrition.food_name)
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "dd.MM.yy"
                                    viewModel.foodEaten_date.append(formatter.string(from: Date()))
                                    
                                    
                                    viewModel.save()
                                    
                                    viewModel.load()
                                    
                                    let db = Firestore.firestore()
                                    db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                                        "Foods Eaten": [ nutrition.food_name : [
                                            "Calorie":nutrition.nf_calories,
                                            "Image": nutrition.photo.thumb,
                                            "Protein": self.detailed_nutrition[0].nf_protein,
                                            "Fat": self.detailed_nutrition[0].nf_total_fat,
                                            "Carbs": self.detailed_nutrition[0].nf_total_carbohydrate,
                                            "Sugar": self.detailed_nutrition[0].nf_sugars
                                        ]]
                                    ], merge: true) { (err) in
                                        if err != nil{
                                            print(err!.localizedDescription)
                                        }
                                    }
                                }
                                
                                
                                
                                
                                
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
                let nutritions = try JSONDecoder().decode(DetailedResponse.self, from: data)
                DispatchQueue.main.async {
                    self.detailed_nutrition = nutritions.foods
                    self.group.leave()
                }
            }
            catch {
                print(error)
            }
            
        }
        
        task.resume()
    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let url = URL(string: "https://trackapi.nutritionix.com/v2/search/item?upc=\(result.string)")
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
                    let nutritions = try JSONDecoder().decode(DetailedResponse.self, from: data)
                    let nutritions2 = try JSONDecoder().decode(NutritionResponse2.self, from: data)
                    DispatchQueue.main.async {
                        print(nutritions.foods)
                        self.detailed_nutrition = nutritions.foods
                        self.nutritions = nutritions2.foods
                    }
                }
                catch {
                    print(error)
                }
                
            }
            task.resume()
            
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}
