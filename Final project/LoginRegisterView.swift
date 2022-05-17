//
//  LoginView2.swift
//  Final project
//
//  Created by Yusup on 26/04/2022.
//

import SwiftUI
import Firebase


struct LoginRegisterView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmationPassword: String = ""
    @State var registerMode: Bool = false
    @State var isFocused: Bool = false
    @State var loggedIn: Bool = false
    
    
    @EnvironmentObject var viewModel: AppViewModel
    
    func hideKeyboard(){ // function to dissmiss keyboard when clicked on screen
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        NavigationView{
            Background {
                VStack {
                    NavigationLink(destination: RegisterView(), isActive: $viewModel.registerStageTwo) { // directs to register stage 2
                        EmptyView()
                    }
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(Color.foregroundColor)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
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
                                .foregroundColor(Color.foregroundColor)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
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
                                    .foregroundColor(Color.foregroundColor)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Color.shadowColor.opacity(0.1), radius: 5, x: 0, y: 5)
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
                    .background(Color.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: Color.shadowColor.opacity(0.2), radius: 20, x: 0, y: 20)
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
                                .foregroundColor(Color.textColor)
                                .frame(width: 120, height: 50, alignment: .center)
                                .background(Color.backgroundColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                                .shadow(color: Color.shadowColor.opacity(0.2), radius: 5, x: 0, y: 5)
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
                                .foregroundColor(Color.textColor)
                                .frame(width: 120, height: 50, alignment: .center)
                                .background(Color.backgroundColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                                .shadow(color: Color.shadowColor.opacity(0.2), radius: 5, x: 0, y: 5)
                                .padding(.horizontal, 16)
                        }
                    }
                    
                    
                }
                .autocapitalization(.none) // disables auto capital
                .offset(y: (isFocused && registerMode) ? -29 : 0).animation(.easeInOut)
            }
        }.onTapGesture { // to dismiss keyboard
            isFocused = false
            UIApplication.shared.endEditing()
        }
        .alert(isPresented: $viewModel.alert) { // for errors
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Ok")))
        }
    }
}

struct LoginRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        LoginRegisterView(email: "", password: "", confirmationPassword: "")
    }
}

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .overlay(content)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
