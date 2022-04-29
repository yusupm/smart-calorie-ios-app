//
//  LoginView2.swift
//  Final project
//
//  Created by BOLT on 26/04/2022.
//

import SwiftUI
import Firebase


struct RegisterView: View {
    
    @State var email: String
    @State var password: String
    @State var confirmationPassword: String
    @State var registerMode: Bool = false
    @State var isFocused: Bool = false
    @State var loggedIn: Bool = false
    
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
                        
                        TextField("Email".uppercased(), text: $email)
                            .onTapGesture {
                                isFocused = true
                            }
                            .keyboardType(.emailAddress)
                            .font(.subheadline)
                            .padding(.leading)
                            .frame(height: 44)
                        
                    }
                    Divider().padding(.leading, 80)
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(color1)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: color2.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.leading)
                        
                        SecureField("Password".uppercased(), text: $password) {
                            if !registerMode {
                                viewModel.signIn(email: email, password: password)
                                self.email = ""
                                self.password = ""
                            }
                        }
                        .onTapGesture {
                            isFocused = true
                        }
                        .keyboardType(.default)
                        .font(.subheadline)
                        .padding(.leading)
                        .frame(height: 44)
                        
                    }
                    
                    if registerMode {
                        Divider().padding(.leading, 80)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(color1)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: color2.opacity(0.1), radius: 5, x: 0, y: 5)
                                .padding(.leading)
                            
                            SecureField("repeat password".uppercased(), text: $confirmationPassword) {
                                viewModel.signIn(email: email, password: password)
                                self.email = ""
                                self.password = ""
                            }
                            .onTapGesture {
                                isFocused = true
                            }
                            .keyboardType(.default)
                            .font(.subheadline)
                            .padding(.leading)
                            .frame(height: 44)
                            
                            
                        }
                    }
                }
                .frame(height: registerMode ? 195 : 136)
                .frame(maxWidth: .infinity)
                .background(color3)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: color2.opacity(0.2), radius: 20, x: 0, y: 20)
                .padding(.horizontal, 16)
                
                HStack {
                    Button(action: {
                        if registerMode {
                            if password == confirmationPassword {
                                if (password != "") && (confirmationPassword != "") {
                                    viewModel.signUp(email: email, password: password)
                                    
                                    self.password = ""
                                    self.confirmationPassword = ""
                                } else {
                                    viewModel.alert.toggle()
                                    viewModel.errorMessage = "Please enter a password"
                                }
                            } else {
                                viewModel.alert.toggle()
                                viewModel.errorMessage = "Passwords don't match"
                                self.password = ""
                                self.confirmationPassword = ""
                            }
                        } else {
                            withAnimation() {
                                registerMode = true
                            }
                        }
                        
                    }) {
                        Text("Register")
                            .fontWeight(.semibold)
                            .foregroundColor(color4)
                            .frame(width: 120, height: 50, alignment: .center)
                            .background(color3)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                            .shadow(color: color2.opacity(0.2), radius: 5, x: 0, y: 5)
                            .padding(.horizontal, 16)
                    }
                    Spacer()
                    Button(action: {
                        if registerMode {
                            withAnimation() {
                                registerMode = false
                            }
                        } else {
                            viewModel.signIn(email: email, password: password)
                        }
                    }) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .foregroundColor(color4)
                            .frame(width: 120, height: 50, alignment: .center)
                            .background(color3)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                            .shadow(color: color2.opacity(0.2), radius: 5, x: 0, y: 5)
                            .padding(.horizontal, 16)
                    }
                    NavigationLink(destination: Text ("Test"), isActive: $loggedIn) {
                        EmptyView()
                    }
                }
                
                
            }
            .autocapitalization(.none)
            .offset(y: (isFocused && registerMode) ? -29 : 0).animation(.easeInOut)
        }.onTapGesture {
            isFocused = false
            UIApplication.shared.endEditing()
        }
        .alert(isPresented: $viewModel.alert) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Ok")))
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(email: "", password: "", confirmationPassword: "")
    }
}

