//
//  ProfilePageView.swift
//  Final project
//
//  Created by BOLT on 07/05/2022.
//

import SwiftUI
import Firebase

struct ProfilePageView: View {
    @State var goal = "N/A"
    @GestureState var isDragging: Bool = false
    @State var offset: CGFloat = 0
    @State var currentDownloadId = ""
    @State var showingGraph = false
    
    @EnvironmentObject var viewModel: AppViewModel
    let auth = Auth.auth()
    
    var body: some View {
        NavigationView{
            VStack{
                
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 120))
                        .padding()
                    Spacer()
                    VStack {
                        Text(auth.currentUser?.email ?? "test@gmail.com")
                            .font(.system(size: 23,weight: .heavy))
                            .foregroundColor(.textColor)
                            .padding(.top, -50)
                        
                        Text("Goal: \(goal)")
                            .font(.system(size: 18,weight: .heavy))
                            .foregroundColor(.textColor)
                    }
                    Spacer()
                    
                }
                
                
                Divider()
                Spacer()
                HStack{
                    Spacer()
                    if showingGraph {
                        DownloadStats()
                    }
                    Spacer()
                }
                
                Spacer()
                
                Button {
                    viewModel.signOut()
                } label: {
                    HStack {
                        Text("Sign out")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.textColor)
                            .frame(width: 120, height: 50, alignment: .center)
                            .background(Color.backgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                            .shadow(color: Color.shadowColor.opacity(0.2), radius: 5, x: 0, y: 5)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 50)

            }
            .navigationTitle("Profile")
        }
        .onAppear{
            load_profile()
            withAnimation{
                showingGraph = true
            }
        }
    }
    
    func load_profile() {
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot else {
                print("No documents")
                return
            }
            self.goal =  documents.get("Goal") as! String
        }
    }
    
    @ViewBuilder
    func DownloadStats()->some View{
        
        VStack(spacing: 15){
            
            HStack{
                
                VStack(alignment: .leading, spacing: 13) {
                    
                    Text("Statistics")
                        .font(.title)
                        .fontWeight(.semibold)
                        .colorInvert()
                    
                    Menu {
                        
                    } label: {
                        
                        Label {
                            Image(systemName: "chevron.down")
                        } icon: {
                            Text("Last 7 Days")
                        }
                        .font(.callout)
                        .foregroundColor(.gray)

                    }

                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "arrow.up.forward")
                        .font(.title2.bold())
                }
                .foregroundColor(.white)
                .offset(y: -10)

            }
            
            // Bar Graph With Gestures...
            BarGraph(calories: weeklyCalories)
                .padding(.top,25)
        }
        .padding(15)
        .background(
        
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
        )
        .padding(.vertical,20)
    }
}

struct Calories: Identifiable{
    var id = UUID().uuidString
    var calories: CGFloat
    var day: String
    var color: Color
}

var weeklyCalories: [Calories] = [

    Calories(calories: 450, day: "M", color: Color.purple),
    Calories(calories: 600, day: "T", color: Color.green),
    Calories(calories: 900, day: "W", color: Color.green),
    Calories(calories: 400, day: "T", color: Color.purple),
    Calories(calories: 500, day: "F", color: Color.green),
    Calories(calories: 200, day: "S", color: Color.purple),
    Calories(calories: 500, day: "S", color: Color.purple)
]

struct ProfilePageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePageView()
    }
}
