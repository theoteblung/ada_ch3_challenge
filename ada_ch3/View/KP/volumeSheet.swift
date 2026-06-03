//
//  volumeSheet.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 02/06/26.
//

import SwiftUI

struct VolumeSheet: View {
    @State private var isExpanded: Bool = false
    @EnvironmentObject var volumeManager: VolumeManager

    private let background     = Color(hex: "#1A1916")
    private let borderColor    = Color(hex: "#979797").opacity(0.20)

    var body: some View {
        VStack(spacing: 0) {
            // Collapsed header (always visible)
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Volume")
                        .font(.system(size: 21, weight: .bold))

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color("IconBG"))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded content placeholder (to be built out later)
            if isExpanded {
                VStack(spacing: 16) {
                    // Placeholder — will be filled with active volume controls later
//                    Text("Volume controls will go here")
//                        .font(.system(size: 14))
//                        .foregroundColor(.white.opacity(0.40))
//                        .padding(.vertical, 20)
                    VolumeSettingsViewV2().environmentObject(volumeManager)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(Color("ColorBG"))
//        .padding(.bottom, isExpanded ? 0 : 16)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24,
                style: .continuous
            )
        )
        .overlay(
            VolumeSheetTopBorder()
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

struct VolumeSheetTopBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 24
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: radius))
        // Top-left arc
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        // Top edge
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        // Top-right arc
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Right side down
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        return path
    }
}
#Preview {
    ZStack {
        Color(hex: "#1A1916").ignoresSafeArea()
        VStack {
            Spacer()
            VolumeSheet().environmentObject(VolumeManager())
        }
    }
}
