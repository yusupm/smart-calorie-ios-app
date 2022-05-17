//
//  ProggressPageView.swift
//  Final project
//
//  Created by BOLT on 12/05/2022.
//

import SwiftUI

struct ProggressPageView: View {
    var body: some View {
        NavigationView{
            VStack{
                DownloadStats()
            }
            .navigationTitle("Progress")
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

