//
//  LoginView2.swift
//  Final project
//
//  Created by BOLT on 26/04/2022.
//

import SwiftUI
import Firebase


struct RegisterView: View {
    
    @State var age = ""
    @State private var weight = ""
    @State var height = ""
    @State var goal = ""
    @State var gender = ""
    @State var isFocused: Bool = false
    
    
    @EnvironmentObject var viewModel: AppViewModel
    
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        Background {
            VStack {
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
                            .onTapGesture {
                                isFocused = true
                            }
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
                        .onTapGesture {
                            isFocused = true
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
                        .onTapGesture {
                            isFocused = true
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
                        .onTapGesture {
                            isFocused = true
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
                        .onTapGesture {
                            isFocused = true
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
                
                Button(action: {
                    viewModel.saveDetails(age: age, height: height, weight: weight, gender: gender, goal: goal)
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.textColor)
                        .frame(width: 120, height: 50, alignment: .center)
                        .background(Color.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                        .shadow(color: Color.shadowColor.opacity(0.2), radius: 5, x: 0, y: 5)
                        .padding(.horizontal, 16)
                }

                
            }
            .autocapitalization(.none)
        }.onTapGesture {
            isFocused = false
            UIApplication.shared.endEditing()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

