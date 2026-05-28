//
//  InfoScreen2.swift
//  ada_ch3
//
//  Created by Keiko Serah on 28/05/26.
//

import SwiftUI

struct NoiseProfile: Identifiable {
    let id: Int
    let title: String
    let color: Color
    let definition: String
    let soundsLike: String
    let primaryUses: String
}

let noiseProfiles = [
    NoiseProfile(
        id: 0,
        title: "Brown Noise",
        color: Color(red: 0.35, green: 0.24, blue: 0.22),
        definition: "Brown noise lowers the high frequencies even more than pink noise. It emphasizes deep, low-frequency rumbles, sounding like a distant waterfall or heavy rainfall.",
        soundsLike: "A low rumble, distant thunder, or a heavy downpour.",
        primaryUses: "Excellent for deep relaxation, masking low-frequency environmental rumble, and blocking racing thoughts before sleep."
    ),
    NoiseProfile(
        id: 1,
        title: "White Noise",
        color: Color(red: 0.82, green: 0.82, blue: 0.82),
        definition: "White noise contains equal energy across all audible frequencies. Because human ears are more sensitive to higher frequencies, it sounds like a bright, constant hiss.",
        soundsLike: "A running ceiling fan, a static hum, or a vacuum cleaner.",
        primaryUses: "Ideal for masking sudden, disruptive environmental sounds because it flattens out sound variations. Highly effective for focused studying."
    ),
    NoiseProfile(
        id: 2,
        title: "Pink Noise",
        color: Color(red: 0.65, green: 0.48, blue: 0.51),
        definition: "Pink noise has deeper sounds than white noise because its energy is distributed evenly per octave, making it sound more balanced and natural to human hearing.",
        soundsLike: "Rustling leaves, steady wind, or light rain.",
        primaryUses: "Great for improving sleep quality, reducing background distractions, and enhancing memory retention during rest."
    )
]

struct NoiseInformationView: View {
    @Environment(\.dismiss) var dismiss
    
    //Tracks the ID of the currently centered card (defaults to White Noise: ID 1)
    @State private var activeCardID: Int? = 1
    
    var body: some View {
        ZStack {
            Color(red: 0.11, green: 0.11, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                //--Header--
                HStack {
                    Spacer()
                    Text("Noise Information")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 44)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                            .opacity(0.6)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                //--Main content--
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        //--Carousel section--
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(noiseProfiles) { profile in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(profile.color)
                                        
                                        //The HStack containing our interactive control layout
                                        HStack(spacing: 6) {
                                            Circle().fill(Color.white.opacity(0.6)).frame(width: 4, height: 4)
                                            Circle().fill(Color.white.opacity(0.6)).frame(width: 4, height: 4)
                                            
                                            //Custom play button (interactive)
                                            Button(action: {
                                                print("Tapped play button for: \(profile.title)")
                                                //Add the play pause audio logic here later!!!!!
                                            }) {
                                                ZStack {
                                                    //Translucent custom background disk
                                                    Circle()
                                                        .fill(Color.black.opacity(0.35))
                                                        .frame(width: 44, height: 44)
                                                    
                                                    //White play arrow icon inside
                                                    Image(systemName: "play.fill")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.white)
                                                        //Offset slightly to perfectly align the visual weight of the triangle
                                                        .padding(.leading, 2)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                            
                                            Circle().fill(Color.white.opacity(0.6)).frame(width: 4, height: 4)
                                            Circle().fill(Color.white.opacity(0.6)).frame(width: 4, height: 4)
                                        }
                                    }
                                    .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0)
                                    .id(profile.id)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .frame(height: 170)
                        .safeAreaPadding(.horizontal, 110)
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: $activeCardID)

                        //Safely look up the data of the active profile, fall back to White Noise if nil
                        let currentProfile = noiseProfiles.first(where: { $0.id == (activeCardID ?? 1) }) ?? noiseProfiles[1]
                        
                        //--Dynamic title--
                        Text(currentProfile.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                            //Smoothly crossfades text values during updates
                            .id(currentProfile.title)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal, 24)
                        
                        //--Dynamic text content--
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What is \(currentProfile.title)?")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                Text(currentProfile.definition)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(4)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What it sounds like")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                Text(currentProfile.soundsLike)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(4)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Primary Uses")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                Text(currentProfile.primaryUses)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(4)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                        //Applying .animation make sure text elements smoothly transition on change (the swoop swoop movement of the body texts)
                        .animation(.easeInOut, value: activeCardID)
                    }
                }
            }
        }
    }
}

#Preview {
    NoiseInformationView()
}
