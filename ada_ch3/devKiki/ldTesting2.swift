//
//  ldTesting2.swift
//  ada_ch3
//
//  Created by kiki on 02/06/26.
//

import SwiftUI

struct ldView2: View {
    // Optional: Call AppStorage here too if you need to do specific logic based on the theme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Form {
            Section(header: Text("Theme Status")) {
                HStack {
                    Text("Current Mode:")
                    Spacer()
                    Text(isDarkMode ? "Dark Mode 🌙" : "Light Mode ☀️")
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .purple : .orange)
                }
            }
            
            Section(header: Text("System Elements")) {
                Text("Notice how the Form background, rows, and text automatically flipped colors without writing extra code.")
                    .font(.subheadline)
                    .foregroundColor(Color("ColorText"))
            }
        }
        .navigationTitle("Second Page")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ldView2()
}
