//
//  SoundModel.swift
//  ada_ch3
//
//  Created by Christofer Theodore on 29/05/26.
//

struct Sound: Equatable {
    let name: String
    let ext: String

    static let pinkNoise  = Sound(name: "pink-noise",  ext: "wav")
    static let whiteNoise = Sound(name: "white-noise", ext: "wav")
    static let brownNoise = Sound(name: "brown-noise", ext: "caf")
    // ...add 10 more here, the player code never changes
}
