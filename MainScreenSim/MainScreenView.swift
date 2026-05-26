
//
//  Untitled.swift
//  AcademyEats
//
//  Created by Beatrice Deviana on 26/05/26.
//

//
//  MainScreenView.swift
//  ada_ch3
//
//  Created by Beatrice Deviana on 26/05/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct MainScreenView: View {
    
    @State private var showPlayingView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1916")
                    .ignoresSafeArea()
                if !showPlayingView {
                    ZStack {
                        Text("Tap to start listening").foregroundColor(.white)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture{
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showPlayingView = true
                        }
                    }
                    
                }
                
                else {
//                    PlayingView()
//                        .transition(.opacity)
                }
                
                VStack {
                    Spacer()
                    
                    Circle()
                        .fill(RadialGradient(
                            gradient: Gradient(colors: [.pink.opacity(0.5), .red.opacity(0)]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 100
                        ))
                        .frame(width: 200, height: 200)
                    
                    
                }
            }
            
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button() {
                    } label: {
                        Image(systemName: "questionmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button() {
                    } label: {
                        Image(systemName: "timer")
                    }
                }
            }
        }
    }
}

#Preview {
    MainScreenView()
}


//if !showPlayingView {
//    Color(hex: "1A1916")
//        .ignoresSafeArea()
//        .overlay(
//            Text("Tap to start listening")).foregroundColor(.white)
//        .transition(.opacity)
//        .onTapGesture{
//            withAnimation(.easeInOut(duration: 0.25)) {
//                showPlayingView.toggle()
//            }
//        }
//
//}
