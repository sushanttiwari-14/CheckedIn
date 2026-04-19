//
//  SpeechService.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import AVFoundation

class SpeechService {

    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "checkedin.voiceEnabled") as? Bool ?? true
    }

    func speak(_ text: String) {
        guard isEnabled else { return }
        guard !synthesizer.isSpeaking else {
            synthesizer.stopSpeaking(at: .immediate)
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
