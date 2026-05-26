//
//  infoScreen.swift
//  ada_ch3
//
//  Created by Keiko Serah on 26/05/26.
//

import SwiftUI
import SwiftData


struct InfoScreen: View{
    var body: some View{
        ZStack{
            Color.black
                .opacity(0.9)
                .ignoresSafeArea()
            
            Rectangle()
                .fill(
                    LinearGradient(colors: [.white, .clear], startPoint: .topLeading, endPoint: .bottomLeading)
                )
                .opacity(0.2)
                .ignoresSafeArea()
                .frame(width: 500, height: 500)
                .padding(.bottom, 300)
                        
            VStack{
                HStack{
                    
                    
                    Text("Noise Information")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(50)
                }
                
                Spacer()
            }
        }
    }
    
    
}

#Preview{
    InfoScreen()
}
