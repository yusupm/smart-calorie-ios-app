//
//  ContentView.swift
//  Final project
//
//  Created by BOLT on 16/04/2022.
//

import SwiftUI
import Firebase

class GlobalString: ObservableObject {
    @Published var totalCalory = 2500
}


struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            if viewModel.signedIn{
                MainView()
            }
            else {
//                LoginRegisterView(email: "", password: "", confirmationPassword: "")
                RegisterView(email: "", password: "", confirmationPassword: "")
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
    
    @State var progress: Float = 0.0
    
    @State var foodEaten_name: [String] = []
    @State var foodEaten_calorie: [Double] = []
    @State var foodEaten_image: [String] = []

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
                    HomeView(progress: $progress, foodEaten_name: $foodEaten_name, foodEaten_calorie: $foodEaten_calorie, foodEaten_image: $foodEaten_image)
                    
                case 1:
                    NavigationView{
                        VStack{
                            Text("Screen")
                        }
                        .navigationTitle("Diary")
                    }
                    
                case 3:
                    NavigationView{
                        VStack{
                            Text("Progress")
                        }
                        .navigationTitle("Progress")
                    }
                default:
                    NavigationView{
                        VStack{
                            Button {
                                viewModel.signOut()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.rectangle.fill")
                                    Text("Sign out")
                                }
                                .padding(15.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15.0)
                                        .stroke(lineWidth: 2.0)
                                )
                            }

                        }
                        .navigationTitle("Profile")
                    }
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
            AddCalorieSheet(progress: $progress, foodEaten_name: $foodEaten_name, foodEaten_calorie: $foodEaten_calorie, foodEaten_image: $foodEaten_image)
        })
        .background(backgroundColor)
        
    }
}

struct HomeView: View {
    @Binding var progress: Float
    @Binding var foodEaten_name: [String]
    @Binding var foodEaten_calorie: [Double]
    @Binding var foodEaten_image: [String]
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View{
        
        NavigationView {

            ZStack {
                Color.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack {
                        ProgressBar(progress: $progress)
                            .frame(width: 250.0, height: 250.0)
                            .padding(40.0)
                        
                        Button(action: {
                            let randomValue = Float([0.012, 0.022, 0.034, 0.016, 0.11].randomElement()!)
                            progress += randomValue
                            print(Auth.auth().currentUser?.uid)
                        }) {
                            HStack {
                                Image(systemName: "plus.rectangle.fill")
                                Text("Increment")
                            }
                            .padding(15.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15.0)
                                    .stroke(lineWidth: 2.0)
                            )
                        }
                        
                        Spacer()
                            .padding(5)
                        
                        HStack {
                            Text("Today's meals")
                                .font(.system(size: 23,weight: .heavy))
                            .foregroundColor(.textColor)
                            Spacer()
                        }
                        
                        ForEach(0..<foodEaten_name.count, id: \.self) { number in
                            HStack {
                                let photo_url = URL(string: foodEaten_image[number])
                                AsyncImage(url: photo_url, content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 60)
                                }, placeholder: {
                                    ProgressView()
                                })
                                .padding()
                                Spacer()
                                Text(foodEaten_name[number])
                                    .bold()
                                    .foregroundColor(.textColor)
                                Spacer()
                                Text("\(foodEaten_calorie[number], specifier: "%.2f") kcal")
                                    .bold()
                                    .foregroundColor(Color.textColor)
                            }
                            .background(Rectangle().fill(Color.red).cornerRadius(10))
                        }
//                        }
                        
                        
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    @StateObject var globalString = GlobalString()
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 30.0)
                .opacity(0.3)
                .foregroundColor(Color.trackColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: self.progress)
            
            VStack {
                Text(String(format: "%.0f %", max(Float(globalString.totalCalory) - (self.progress * Float(globalString.totalCalory)), 0.0)))
                    .font(.system(size: 55))
                    .foregroundColor(.textColor)
                    .fontWeight(.heavy)
                    .bold()
                Text("KCAL LEFT")
                    .font(.system(size: 15))
                    .foregroundColor(.textColor1)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}

