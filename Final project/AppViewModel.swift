//
//  AppViewModel.swift
//  Final project
//
//  Created by BOLT on 28/04/2022.
//

import SwiftUI
import Firebase

class AppViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn : Bool {
    return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String){
        auth.signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "")")
                //Self.showAlert = true
            } else {
                //self.isSuccessful = true
                print("Logged in!")
//                authentication.updateValidation(success: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(Animation.spring()) {
                        self?.signedIn = true
                    }
                }
                
            }
        }
    }
    
    func signUp(email: String, password: String){
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "")")
                //Self.showAlert = true
            } else {
                //self.isSuccessful = true
                print("Registered")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.signedIn = true
                }
                
            }
        }
    }
    
    func signOut() {
        withAnimation {
            do {
                try Auth.auth().signOut()
                self.signedIn = false
            }
            catch {
                
            }
        }
    }
}
