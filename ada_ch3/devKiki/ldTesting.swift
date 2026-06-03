//
//  ldTesting.swift
//  ada_ch3
//
//  Created by kiki on 02/06/26.
//

import SwiftUI

struct ldView: View {
    // Persist the user's theme choice
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Your main app content goes here
                Text("Main App Content")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                // 👉 1. Added NavigationLink to go to the second page
                NavigationLink(destination: ldView2()) {
                    Text("Go to Second Page")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }
            }
            .navigationTitle("Home") // Optional title
            // Add the toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Top Right
                    Button {
                        // Toggle the boolean state smoothly
                        withAnimation(.easeInOut) {
                            isDarkMode.toggle()
                        }
                    } label: {
                        // Dynamically change the icon based on the state
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .font(.title3) // Adjust size if needed
                            .foregroundColor(isDarkMode ? .purple : .orange)
                    }
                }
            }
        }
        // Apply the color scheme app-wide
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ldView()
}
