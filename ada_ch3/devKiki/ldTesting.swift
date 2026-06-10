//
//  ldTesting.swift
//  ada_ch3
//
//  Created by kiki on 02/06/26.
//

import SwiftUI

struct ldView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Main App Content")
                    .font(.title)
                    .foregroundColor(.secondary)
                
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
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            isDarkMode.toggle()
                        }
                    } label: {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .font(.title3)
                            .foregroundColor(isDarkMode ? .purple : .orange)
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ldView()
}
