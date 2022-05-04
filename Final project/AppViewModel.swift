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
    @Published var alert = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var registerStageTwo = false
    
    @Published var foodEaten_name: [String] = []
    @Published var foodEaten_calorie: [Double] = []
    @Published var foodEaten_image: [String] = []
    
    private let defaults = UserDefaults.standard
    
    var isSignedIn : Bool {
    return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String){
        isLoading.toggle()
        auth.signIn(withEmail: email, password: password) { [weak self] (result, error) in
            self?.isLoading.toggle()
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "")")
                self?.errorMessage = error!.localizedDescription
                self?.alert.toggle()
                return
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
        isLoading.toggle()
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            self?.isLoading.toggle()
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "")")
                self?.alert.toggle()
                self?.errorMessage = error!.localizedDescription
                //Self.showAlert = true
            } else {
                //self.isSuccessful = true
                print("Registered")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    self?.signedIn = true
                    self?.registerStageTwo.toggle()
                }
                
            }
        }
    }
    
    func saveDetails(age : String, height : String, weight : String, gender : String, goal : String) {
        isLoading.toggle()
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).setData([
            "Age": age,
            "Height":height,
            "Weight":weight,
            "Gender":gender,
            "Goal":goal
        ]) { (err) in
            if err != nil{
                self.isLoading.toggle()
                self.errorMessage = err!.localizedDescription
                self.alert.toggle()
                return
            }
            self.isLoading.toggle()
            self.signedIn = true
            self.registerStageTwo.toggle()
        }
    }
    
    func signOut() {
        isLoading.toggle()
        withAnimation {
            do {
                try Auth.auth().signOut()
                self.signedIn = false
                self.isLoading.toggle()
            }
            catch {
                
            }
        }
    }
    
    func save() {
        
        defaults.set(foodEaten_calorie, forKey: "foodEaten_calorie")
        defaults.set(foodEaten_image, forKey: "foodEaten_image")
        defaults.set(foodEaten_name, forKey: "foodEaten_name")
    }
    
    func load(){
        if defaults.value(forKey: "foodEaten_calorie") != nil{
            foodEaten_calorie = defaults.value(forKey: "foodEaten_calorie") as! [Double]
            foodEaten_name = defaults.value(forKey: "foodEaten_name") as! [String]
            foodEaten_image = defaults.value(forKey: "foodEaten_image") as! [String]
        }
        
    }
}
