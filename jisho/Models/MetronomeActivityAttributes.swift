//
//  MetronomeActivityAttributes.swift
//  jisho
//
//  Live Activity attributes for Metronome
//

import Foundation
import ActivityKit

@available(iOS 16.1, *)
struct MetronomeActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var tempo: Double
        var timeSignature: String
        var currentBeat: Int
        var isPlaying: Bool
    }

    // Static data that doesn't change during the activity
    var appName: String
}
