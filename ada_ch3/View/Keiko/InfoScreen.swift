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
                .frame(width: 500, height: 200)
                .padding(.bottom, 600)
            
            VStack{
                HStack{
                    Button(action: {
                       //action
                    }){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial)
                            .background(Color.black.opacity(1.0))
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                    
                    
                    Text("Noise Information")
                        .foregroundStyle(Color.white.opacity(0.8))
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(.trailing, 50)
                }
                .padding()
                
                Spacer()
                
                //scrollable noises
                Circle()
                    .fill(
                        RadialGradient(colors: [.white, .clear], center: .center, startRadius: 0, endRadius: 100)
                        
                    )
                    .frame(width: 200, height: 200)
                
                VStack{
                    
                    Text("White Noise")
                        .font(Font.system(size: 35, weight: .bold, design: .default))
                        .foregroundStyle(Color.white)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .frame(width: 350)
                    
                    VStack{
                        Text("What is Pink Noise?")
                            .font(Font.system(size: 23, weight: .bold, design: .default))
                            .foregroundStyle(Color.white.opacity(0.5))
                            .padding(.trailing, 80)
                            .padding(.top, 20)
                        
                        Text("Consistent sound that helps mask sudden\ninteractions.")
                            .font(Font.system(size: 15, design: .default))
                            .foregroundStyle(Color.white)
                            .padding(.top, 0.5)
                            .padding(.leading, 1)
                    }
                    VStack{
                        Text("What is it Best For?")
                            .font(Font.system(size: 23, weight: .bold, design: .default))
                            .foregroundStyle(Color.white.opacity(0.5))
                            .padding(.trailing, 80)
                            .padding(.top, 20)
                        
                        Text("- Study Spaces: masking disruptive sounds.\n- Crowded Public Spaces:\n- Sleep: helps improve sleep quality.")
                            .font(Font.system(size: 15, design: .default))
                            .foregroundStyle(Color.white)
                            .padding(.top, 0.5)
                            .padding(.leading, 1)
                        
                        Spacer()
                        
                        Text("[App Name]")
                            .font(Font.system(size: 15, design: .default))
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                }
                
            }
            
                
        }
        .navigationBarBackButtonHidden(true) //so the default iOS button stays hidden
    }

}


#Preview{
    InfoScreen()
}
