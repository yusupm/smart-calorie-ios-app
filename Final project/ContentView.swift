//
//  ContentView.swift
//  Final project
//
//  Created by Yusup on 16/04/2022.
//

import SwiftUI
import Firebase

class GlobalString: ObservableObject {
    @Published var totalCalorie: Float = 2500
}


struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            if viewModel.signedIn{
                MainView()
            }
            else {
                LoginRegisterView()
            }
            
            if viewModel.isLoading {
                LoadingScreen()
            }
        }
        .onAppear{
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}

struct MainView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var backgroundColor = Color(#colorLiteral(red: 0.974566576, green: 0.974566576, blue: 0.974566576, alpha: 1))
    
    
    @State var selectedIndex = 0
    @State var presented = false
    

    let icons = [
        "house",
        "book.closed.circle.fill",
        "plus",
        "chart.bar.fill",
        "person.circle.fill"
    ]
    
    let titles = [
        "Home",
        "Diary",
        "",
        "Progress",
        "Profile",
    ]
    
    var body: some View {
        VStack{
            
            ZStack{
                switch selectedIndex{
                case 0:
                    HomeView()
                    
                case 1:
                    NavigationView{
                        RecipeVeiw()
                        .navigationTitle("Recipes")
                    }
                    
                case 3:
                    ProggressPageView()
                default:
                    ProfilePageView()
                }
            }
            Spacer()
            Divider()

            HStack{
                
                ForEach(0..<5, id: \.self) { number in
                    Spacer()
                    Button(action: {
                        if number == 2{
                            presented.toggle()
                        }
                        else{
                            self.selectedIndex = number
                        }
                    }, label: {
                        if number == 2 {
                            Image(systemName: icons[number])
                                .font(.system(size: 25, weight: .regular, design: .default))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.textColor)
                                .cornerRadius(30)
                        }
                        else{
                            Image(systemName: icons[number])
                                .font(.system(size: 25, weight: .regular, design: .default))
                                .foregroundColor(selectedIndex == number ? .textColor : Color(UIColor.lightGray))
                        }
                    })
                    Spacer()
                }
            }

        }
        .sheet(isPresented: $presented, content: {
            AddCalorieSheet()
        })
        .background(backgroundColor)
        
    }
}

struct HomeView: View {
    
    
    @EnvironmentObject var viewModel: AppViewModel
    @State var foods_eaten: NSDictionary = [:]
    @State var todays_foods: NSDictionary = [:]
    @State var formatter = DateFormatter()
    
    var body: some View{
        
        NavigationView {

            ZStack {
                Color.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack {
                        ProgressBar()
                            .frame(width: 250.0, height: 250.0)
                            .padding(40.0)
                        HStack {
                            Spacer()
                            VStack {
                                Capsule()
                                    .fill(.red)
                                    .frame(width: 70, height: 15)
                                Text("Calorie")
                            }
                            Spacer()
                            VStack {
                                Capsule()
                                    .fill(.blue)
                                    .frame(width: 70, height: 15)
                                Text("Protein")
                            }
                            Spacer()
                        }
                        Spacer()
                            .padding(5)
                        
                        HStack {
                            Text("Today's meals")
                                .font(.system(size: 23,weight: .heavy))
                            .foregroundColor(.textColor)
                            Spacer()
                        }
                        if self.foods_eaten[formatter.string(from: Date())] != nil{
                            let all_keys = todays_foods.allKeys
                            ForEach(0..<all_keys.count, id: \.self){number in
                                
                                let food = todays_foods[all_keys[number]] as! NSDictionary
                                HStack {
                                    let photo_url = URL(string: food["Image"] as! String)
                                    AsyncImage(url: photo_url, content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 60)
                                    }, placeholder: {
                                        ProgressView()
                                    })
                                    .padding()
                                    Spacer()
                                    Text(todays_foods.allKeys[number] as! String)
                                        .bold()
                                        .foregroundColor(.textColor)
                                    Spacer()
                                    Text("\(food["Calorie"] as! Double, specifier: "%.2f") kcal")
                                        .bold()
                                        .foregroundColor(Color.textColor)
                                }
                                .font(.headline)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.backgroundColor)
                                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .onAppear{
                fetchData()
                formatter.dateFormat = "dd.MM.yy"
            }
        }
    }
    func fetchData() {
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot else {
                print("No documents")
                return
            }
            self.foods_eaten = documents.get("Foods Eaten") as! NSDictionary
            if self.foods_eaten[formatter.string(from: Date())] != nil{
                let today = self.foods_eaten[formatter.string(from: Date())] as! NSDictionary
                self.todays_foods = today["Foods"] as? NSDictionary ?? [:]
                viewModel.calorie_progress = today["Total Calories"] as! Float
                viewModel.total_weight = today["Total Weight"] as! Float
                viewModel.total_protein = today["Total Protein"] as! Float
            }
        }
    }
}

struct ProgressBar: View {
    @StateObject var globalString = GlobalString()
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 30.0)
                .opacity(0.3)
                .foregroundColor(Color.trackColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(viewModel.calorie_progress / globalString.totalCalorie, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: viewModel.calorie_progress / globalString.totalCalorie)
            
            
        
            Circle()
                .trim(from: 0.0, to: CGFloat(min((viewModel.total_protein / viewModel.total_weight), 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: viewModel.total_protein / viewModel.total_weight)
            
            
            VStack {
                Text(String(format: "%.0f %", max(globalString.totalCalorie - viewModel.calorie_progress, 0.0)))
                    .font(.system(size: 55))
                    .foregroundColor(.textColor)
                    .fontWeight(.heavy)
                    .bold()
                Text("KCAL LEFT")
                    .font(.system(size: 15))
                    .foregroundColor(Color.foregroundColor)
            }
        }
    }
}

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea(.all, edges: .all)
            
            
            ProgressView()
                .padding()
                .background(Color.backgroundColor)
                .cornerRadius(10)
        }
    }
}

