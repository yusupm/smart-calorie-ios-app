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
    
    @State var gender = ""
    @State var height = ""
    @State var weight = ""
    @State var age = ""
    
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
                    Text(auth.currentUser?.email ?? "test@gmail.com")
                        .font(.system(size: 23,weight: .heavy))
                        .foregroundColor(.textColor)
                        .padding(.top, -50)
                    Spacer()
                    
                }
                
                
                Divider()
                
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(Color.foregroundColor)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        TextField("AGE", text: $age)
                            .keyboardType(.numberPad)
                            .font(.subheadline)
                            .padding(.leading)
                            .frame(height: 44)
                        
                    }
                    Divider().padding(.leading, 80)
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundColor(Color.foregroundColor)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        Picker("WEIGHT", selection: $weight) {
                            Text("Choose")
                            ForEach(40 ..< 100) {
                                Text("\($0) kg").tag("\($0) kg")
                                }
                            }
                        
                        .keyboardType(.default)
                        .font(.subheadline)
                        .padding(.leading)
                        .frame(height: 44)
                        Spacer()
                        
                    }
                    Divider().padding(.leading, 80)
                    HStack {
                        Image(systemName: "ruler.fill")
                            .foregroundColor(Color.foregroundColor)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        Picker("HEIGHT", selection: $height) {
                            Text("Choose")
                            ForEach(140 ..< 200) {
                                    Text("\($0) cm").tag("\($0) cm")
                                }
                            }
                        
                        .keyboardType(.default)
                        .font(.subheadline)
                        .padding(.leading)
                        .frame(height: 44)
                        
                        Spacer()
                    }
                    Divider().padding(.leading, 80)
                    HStack {
                        Image(systemName: "ruler.fill")
                            .foregroundColor(Color.foregroundColor)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        Picker("GOAL", selection: $goal) {
                            Text("Choose")
                            Text("GAIN WEIGHT").tag("GAIN WEIGHT")
                            Text("MAINTAIN WEIGHT").tag("MAINTAIN WEIGHT")
                            Text("LOOSE WEIGHT").tag("LOOSE WEIGHT")
                            }
                        
                        .keyboardType(.default)
                        .font(.subheadline)
                        .padding(.leading)
                        .frame(height: 44)
                        
                        Spacer()
                    }
                    
                    Divider().padding(.leading, 80)
                    HStack {
                        Image(systemName: "ruler.fill")
                            .foregroundColor(Color.foregroundColor)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        Picker("GENDER", selection: $gender) {
                            Text("Choose")
                            Text("MALE").tag("MALE")
                            Text("FEMALE").tag("FEMALE")
                            }
                        .keyboardType(.default)
                        .font(.subheadline)
                        .padding(.leading)
                        .frame(height: 44)
                        
                        Spacer()
                    }
                }
                .frame(height: 325)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color.shadowColor.opacity(0.2), radius: 20, x: 0, y: 20)
                .padding(.horizontal, 16)
                
                Spacer()
                
                
                Button {
                    viewModel.saveDetails(age: age, height: height, weight: weight, gender: gender, goal: goal)
                } label: {
                    HStack {
                        Text("Save Details")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.textColor)
                            .frame(width: 120, height: 50, alignment: .center)
                            .background(Color.backgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                            .shadow(color: Color.shadowColor.opacity(0.2), radius: 5, x: 0, y: 5)
                            .padding(.horizontal, 16)
                    }
                }
                
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
            self.gender = documents.get("Gender") as! String
            self.height = documents.get("Height") as! String
            self.weight = documents.get("Weight") as! String
            self.age = documents.get("Age") as! String
        }
    }
}


struct ProfilePageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePageView()
    }
}
