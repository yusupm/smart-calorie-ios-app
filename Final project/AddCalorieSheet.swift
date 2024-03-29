//
//  AddCalorieSheet.swift
//  Final project
//
//  Created by Yusup on 28/04/2022.
//

import SwiftUI
import Firebase
import CodeScanner

struct AddCalorieSheet: View {
    
//    @State var nutritions = [Nutrition]()
    @StateObject var globalString = GlobalString()
    @State private var searchText: String = ""
    @State var foods_eaten: [NSDictionary] = []
    @State var detailed_nutrition = [DetailedNutrition]()
    @State var group = DispatchGroup()
    
    @State private var isShowingScanner = false
    
    
    @EnvironmentObject var viewModel: AppViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
            NavigationView{
                VStack{
                    NavigationLink(destination: CodeScannerView(codeTypes: [.ean8, .ean13], completion: handleScan), isActive: $isShowingScanner) { // Barcode scanner
                        EmptyView()
                    }
                    NavigationLink(destination: CameraView(), isActive: $viewModel.isShowingCamera) { // Food Scanner
                        EmptyView()
                    }
                    
                    HStack{ // Search bar
                        Image(systemName: "magnifyingglass") // extra detail
                            .foregroundColor(Color.foregroundColor)
                        TextField("Search", text: $searchText)
                            .foregroundColor(Color.foregroundColor)
                            .disableAutocorrection(true)
                            .overlay(
                                Image(systemName: "xmark.circle.fill") // clear button
                                    .padding()
                                    .offset(x: 10)
                                    .foregroundColor(Color.foregroundColor)
                                    .opacity(searchText.isEmpty ? 0.0: 1.0) // only showed if text field is not empty
                                    .onTapGesture {
                                        searchText = "" // clears search
                                    }
                                ,alignment: .trailing
                            )
                        Button {
                            isShowingScanner = true // activates navigation link for barcode scanner
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.textColor)
                                .cornerRadius(30)
                        }
                        
                        Button {
                            viewModel.isShowingCamera = true // activates navigation link for food scanner
                        } label: {
                            Image(systemName: "camera.viewfinder")
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
                        RoundedRectangle(cornerRadius: 25) // frame
                            .fill(Color.backgroundColor)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                    )
                    .padding()
                    List { // list of foods
                        ForEach(viewModel.nutritions, id: \.self) {nutrition in
                            
                            Button(action: {
                                self.group.enter() // used to pause some process until finished
                                
                                search_item(nix_id: nutrition.nix_item_id) // more detail is searched for specific food
                                self.group.notify(queue: .main){ // waits for self.group.leave() call before executing the body, which is called in search_item function
                                    presentationMode.wrappedValue.dismiss()
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "dd.MM.yy"
                                    
                                    let db = Firestore.firestore()
                                    db.collection("users").document(Auth.auth().currentUser!.uid)
                                    db.collection("users").document(Auth.auth().currentUser!.uid).setData([ // the chose food gets added to the database
                                        "Foods Eaten": [
                                            formatter.string(from: Date()):[
                                                "Total Calories": viewModel.calorie_progress + Float(nutrition.nf_calories),
                                                "Total Weight": viewModel.total_weight + (self.detailed_nutrition[0].serving_weight_grams ?? 0.0),
                                                "Total Protein": viewModel.total_protein + (self.detailed_nutrition[0].nf_protein ?? 0.0),
                                                "Foods": [
                                                    nutrition.food_name : [
                                                        "Calorie":nutrition.nf_calories,
                                                        "Image": nutrition.photo.thumb,
                                                        "Protein": self.detailed_nutrition[0].nf_protein,
                                                        "Fat": self.detailed_nutrition[0].nf_total_fat,
                                                        "Carbs": self.detailed_nutrition[0].nf_total_carbohydrate,
                                                        "Sugar": self.detailed_nutrition[0].nf_sugars,
                                                        "Serving Weight": self.detailed_nutrition[0].serving_weight_grams,
                                                        "Date": formatter.string(from: Date())
                                                    ]
                                                ]
                                            ]
                                        ]
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
                    .onChange(of: searchText) { value in // checks if the text field is being typed
                        async {
                            if !value.isEmpty && value.count > 3 { // avoids fetching data if search bar is empty or has less than 3 characters
                                await fetch(searchTerm: value) // fetches list of foods
                            } else {
                                viewModel.nutritions.removeAll() // removes the list
                            }
                        }
                    }
                    
                }
            }
    }
    
    func fetch(searchTerm: String){ // fetch list of foods
        
        let url = URL(string: "https://trackapi.nutritionix.com/v2/search/instant?query=\(searchTerm)") // api url

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
                let nutritions = try JSONDecoder().decode(NutritionResponse.self, from: data) // decode response
                DispatchQueue.main.async {
                    viewModel.nutritions = nutritions.branded
                }
            }
            catch {
                print(error)
            }
            
        }
        
        task.resume()
    }
    func search_item(nix_id: String){ // get more details about a product
        
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
    
    func handleScan(result: Result<ScanResult, ScanError>){ // used for barcode scanner, searches for the barcode values
        isShowingScanner = false
        
        switch result { // error handling
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
                        self.detailed_nutrition = nutritions.foods
                        viewModel.nutritions = nutritions2.foods
                    }
                }
                catch {
                    print(error)
                }
                
            }
            task.resume()
            
            
        case .failure(let error): // error handling
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}
