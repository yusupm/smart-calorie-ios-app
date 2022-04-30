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
    
    var color1 = Color(#colorLiteral(red: 0.3544496118, green: 0.3544496118, blue: 0.3544496118, alpha: 1))
    var color2 = Color(#colorLiteral(red: 0.1647058824, green: 0.1882352941, blue: 0.3882352941, alpha: 1))
    var color3 = Color(#colorLiteral(red: 0.974566576, green: 0.974566576, blue: 0.974566576, alpha: 1))
    var color4 = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    
    
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
                            .foregroundColor(color1)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: color2.opacity(0.1), radius: 5, x: 0, y: 5)
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
                            .foregroundColor(color1)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: color2.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        Picker("WEIGHT", selection: $weight) {
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
                            .foregroundColor(color1)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: color2.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        Picker("HEIGHT", selection: $height) {
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
                            .foregroundColor(color1)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: color2.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        Picker("GOAL", selection: $goal) {
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
                            .foregroundColor(color1)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: color2.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        Picker("GENDER", selection: $gender) {
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
                .background(color3)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: color2.opacity(0.2), radius: 20, x: 0, y: 20)
                .padding(.horizontal, 16)
                
                Button(action: {
                    viewModel.saveDetails(age: age, height: height, weight: weight, gender: gender, goal: goal)
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(color4)
                        .frame(width: 120, height: 50, alignment: .center)
                        .background(color3)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                        .shadow(color: color2.opacity(0.2), radius: 5, x: 0, y: 5)
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

