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
                
                HStack{
                    Text("This week")
                    Spacer()
                }
                .frame(height: 150)
                .animation(.easeOut, value: isDragging)
                .gesture(DragGesture().updating($isDragging, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    offset = isDragging ? value.location.x : 0
                    let draggingSpace = UIScreen.main.bounds.width - 60
                    let eachBlock = draggingSpace / CGFloat(7)
                    let temp = Int(offset / eachBlock)
                    let index = max(min(temp, 7-1), 0)
                    
                }).onEnded({ value in
                    withAnimation{
                        offset = .zero
                        currentDownloadId = ""
                    }
                }))
                
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
//        .onAppear(perform: load_profile)
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
}

struct ProfilePageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePageView()
    }
}
