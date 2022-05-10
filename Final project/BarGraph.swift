//
//  BarGraph.swift
//  BarGraphGestures (iOS)
//
//  Created by Balaji on 02/11/21.
//

import SwiftUI

struct BarGraph: View {
    var calories: [Calories]
    
    // Gesture Properties...
    @GestureState var isDragging: Bool = false
    @State var offset: CGFloat = 0
    
    @State var currentDayID: String = ""
    
    var body: some View {
        
        HStack(spacing: 10){
            
            ForEach(calories){daily in
                CardView(daily: daily)
            }
        }
        .frame(height: 150)
        .animation(.easeOut, value: isDragging)
        // Gesutre...
        .gesture(
        
            DragGesture()
                .updating($isDragging, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    // Only updating if dragging...
                    offset = isDragging ? value.location.x : 0
                    
                    // dragging space removing the padding added to the view...
                    // total padding = 60
                    // 2 * 15 Horizontal
                    let draggingSpace = UIScreen.main.bounds.width - 60
                    
                    // Each block...
                    let eachBlock = draggingSpace / CGFloat(calories.count)
                    
                    // getting index...
                    let temp = Int(offset / eachBlock)
                    
                    // safe Wrapping index...
                    let index = max(min(temp, calories.count - 1), 0)
                    
                    // updating ID
                    self.currentDayID = calories[index].id
                })
                .onEnded({ value in
                    
                    withAnimation{
                        offset = .zero
                        currentDayID = ""
                    }
                })
        )
    }
    
    @ViewBuilder
    func CardView(daily: Calories)->some View{
        
        VStack(spacing: 20){
            
            GeometryReader{proxy in
                
                let size = proxy.size
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(daily.color)
                    .opacity(isDragging ? (currentDayID == daily.id ? 1 : 0.35) : 1)
                    .frame(height: (daily.calories / getMax()) * (size.height))
                    .overlay(
                    
                        Text("\(Int(daily.calories))")
                            .font(.callout)
                            .foregroundColor(daily.color)
                            .opacity(isDragging && currentDayID == daily.id ? 1 : 0)
                            .offset(y: -30)
                        
                        ,alignment: .top
                    )
                    .frame(maxHeight: .infinity,alignment: .bottom)
            }
            
            Text(daily.day)
                .font(.callout)
                .foregroundColor(isDragging && currentDayID == daily.id ? daily.color : .gray)
        }
    }
    
    func getMax()->CGFloat{
        let max = calories.max { first, second in
            return second.calories > first.calories
        }
        
        return max?.calories ?? 0
    }
}
