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
            viewModel.signedIn = viewModel.isSignedIn // refreshes sign in status every app opening
        }
    }
}

struct MainView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var backgroundColor = Color(#colorLiteral(red: 0.974566576, green: 0.974566576, blue: 0.974566576, alpha: 1))
    
    
    @State var selectedIndex = 0 // used to determine screen number
    @State var presented = false // for AddCalorieSheet view
    

    let icons = [ // For navigation bar
        "house",
        "book.closed.circle.fill",
        "plus",
        "chart.bar.fill",
        "person.circle.fill"
    ]
    
    let titles = [ // For navigation bar
        "Home",
        "Diary",
        "",
        "Progress",
        "Profile",
    ]
    
    var body: some View {
        VStack{
            
            ZStack{
                switch selectedIndex{ // Sitch of screens depending on the index
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

            HStack{ // Navigation Bar
                
                ForEach(0..<5, id: \.self) { number in
                    Spacer()
                    Button(action: {
                        if number == 2{ // if Plus button is pressed
                            presented.toggle() // Displays sheet view
                        }
                        else{
                            self.selectedIndex = number // changes index number to change view
                        }
                    }, label: {
                        if number == 2 {
                            Image(systemName: icons[number]) // Plus button
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
                
                ScrollView { // Makes it scrollable for easy navigation
                    VStack {
                        ProgressBar()
                            .frame(width: 250.0, height: 250.0)
                            .padding(40.0)
                        HStack { // Label indicator for progress bar
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
                        if self.foods_eaten[formatter.string(from: Date())] != nil{ // checks to see if it was initiated
                            let all_keys = todays_foods.allKeys
                            ForEach(0..<all_keys.count, id: \.self){number in // list of foods returned from api
                                
                                let food = todays_foods[all_keys[number]] as! NSDictionary
                                HStack {
                                    let photo_url = URL(string: food["Image"] as! String)
                                    AsyncImage(url: photo_url, content: { image in //Display image
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 60)
                                    }, placeholder: {
                                        ProgressView()
                                    })
                                    .padding()
                                    Spacer()
                                    Text(todays_foods.allKeys[number] as! String) // Name of the food
                                        .bold()
                                        .foregroundColor(.textColor)
                                    Spacer()
                                    Text("\(food["Calorie"] as! Double, specifier: "%.2f") kcal") // specifier is used to avoid many numbers after .
                                        .bold()
                                        .foregroundColor(Color.textColor)
                                }
                                .font(.headline)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 25) // Creates a nice frame
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
                fetchData() // refreshes data every time page is viewed
                formatter.dateFormat = "dd.MM.yy"
            }
        }
    }
    func fetchData() { // fetches data from the database about the signed in user
        let db = Firestore.firestore() // initiated database
        db.collection("users").document(Auth.auth().currentUser!.uid).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot else { // error handling
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
            Circle() // complete circle in grey shows total
                .stroke(lineWidth: 30.0)
                .opacity(0.3)
                .foregroundColor(Color.trackColor)
            
            Circle() // Represents calorie progress
                .trim(from: 0.0, to: CGFloat(min(viewModel.calorie_progress / globalString.totalCalorie, 1.0))) // decimal percentage of calorie proggress is calculated
                .stroke(style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: viewModel.calorie_progress / globalString.totalCalorie)
            
            
        
            Circle() // represents protein progress
                .trim(from: 0.0, to: CGFloat(min((viewModel.total_protein / viewModel.total_weight), 1.0))) // decimal percentage of protein proggress from total weight is calculated
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

struct LoadingScreen: View { // Simple loading screen view 
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

