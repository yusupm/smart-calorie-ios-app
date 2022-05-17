//
//  Final_projectApp.swift
//  Final project
//
//  Created by Yusup on 16/04/2022.
//

import SwiftUI
import Firebase

@main
struct Final_projectApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            let viewModel = AppViewModel()
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
