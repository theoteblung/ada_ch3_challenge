//
//  SoundModel.swift
//  ada_ch3
//
//  Created by Christofer Theodore on 29/05/26.
//

struct Sound: Equatable {
    let name: String
    let ext: String

    static let pinkNoise  = Sound(name: "pinknoise",  ext: "caf")
    static let whiteNoise = Sound(name: "whitenoise", ext: "caf")
    static let brownNoise = Sound(name: "brownnoise", ext: "caf")
    static let breathInSound = Sound(name: "breathein", ext: "caf")
    static let breathOutSound = Sound(name: "breatheout", ext: "caf")
    static let breathHoldSound = Sound(name: "breathehold", ext: "caf")
    // ...add 10 more here, the player code never changes
}
