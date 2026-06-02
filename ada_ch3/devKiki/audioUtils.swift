import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordedAudioURL: URL?
    
    // Analysis properties
    @Published var recommendedNoise: String = "Analyzing..."
    @Published var ambientDecibels: Float = -160.0
    
    // Track the current recommended sound type for file lookups
    private var detectedNoiseColor: String? = nil
    private var detectedNoiseVolume: Float = 1.0
    
    // Debug instrumentation properties
    @Published var debugPeakPower: Float = -160.0
    @Published var debugVariance: Float = 0.0
    @Published var debugAvgVariance: Float = 0.0
    @Published var debugFinalDecibels: Float = -160.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var analysisTimer: Timer?
    
    private var decibelHistory: [Float] = []
    
    // theo test dynamic player
    @Published private(set) var soundPlaying: Sound?
    private var soundPlayer: AVAudioPlayer?
    private var soundPlayerLists: [String: AVAudioPlayer] = [:]   // keyed by file name
    private let soundFadeDuration = 1.0
    
    //theo breath player
    @Published private(set) var breathPlaying: Sound?
    private var breathPlayer: AVAudioPlayer?
    @Published var isBreathPlaying = false
    @Published var breathIndex = 0
    @Published var breathVolume: Float = 0.5
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        AVAudioApplication.requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                guard allowed else { return }
                print("Recording Start")
                self?.beginRecordingProcess()
            }
        }
    }
    
    private func beginRecordingProcess() {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "recording-\(UUID().uuidString).m4a"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            print("Recording Process Start")
            
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordedAudioURL = fileURL
            recommendedNoise = "Analyzing environment..."
            detectedNoiseColor = nil
            decibelHistory.removeAll()
            
            startAnalyzing()
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        analysisTimer?.invalidate()
        
        determineBestNoiseColor()
    }
    
    private func startAnalyzing() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder, recorder.isRecording else { return }
            
            print("Analyzing Process Start")
            
            recorder.updateMeters()
            let currentPower = recorder.averagePower(forChannel: 0)
            let peakPower = recorder.peakPower(forChannel: 0)
            let variance = peakPower - currentPower
            
            DispatchQueue.main.async {
                self.ambientDecibels = currentPower
                self.debugPeakPower = peakPower
                self.debugVariance = variance
                self.decibelHistory.append(variance)
            }
        }
    }
    
    private func determineBestNoiseColor() {
        guard !decibelHistory.isEmpty else { return }
        
        let avgVariance = decibelHistory.reduce(0, +) / Float(decibelHistory.count)
        
        DispatchQueue.main.async {
            self.debugAvgVariance = avgVariance
            self.debugFinalDecibels = self.ambientDecibels
        }
        
        if ambientDecibels < -55 {
            recommendedNoise = "Pure Silence (Room is already quiet!)"
            detectedNoiseColor = nil
            return
        }
        
        // Matches your exact imported file structures with hyphens
        if avgVariance > 12.0 {
            recommendedNoise = "White Noise (Best for blocking sudden, sharp sounds)"
            detectedNoiseColor = "white-noise"
            detectedNoiseVolume = 0.1
        } else if ambientDecibels > -30 {
            recommendedNoise = "Brown Noise (Best for deep, low-frequency rumbles)"
            detectedNoiseColor = "brown-noise"
        } else if ambientDecibels > -45 {
            recommendedNoise = "Green Noise (Best for washing out ambient mechanical hums)"
            detectedNoiseColor = "green-noise"
        } else {
            recommendedNoise = "Pink Noise (Best for balanced environments)"
            detectedNoiseColor = "pink-noise"
        }
    }
    
    // MARK: - Playback Type 1: Mask Audio (Loops MP3 Resource)
    func startRecommendedNoisePlayback() {
        guard let colorToPlay = detectedNoiseColor else { return }
        let detectedNoiseVolume = detectedNoiseVolume
        
        playNoiseFile(named: colorToPlay, volume: detectedNoiseVolume)
    }
    
    func playNoiseFile(named filename: String, volume: Float = 1.0, ext: String = "wav") {
        guard let resPath = Bundle.main.path(forResource: filename, ofType: ext) else {
            print("Error: Could not find \(filename).mp3 in bundle.")
            return
        }
        
        let url = URL(fileURLWithPath: resPath)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = -1 // Infinite background loop
            
            audioPlayer?.volume = volume
            
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        } catch {
            print("Failed to play asset file: \(error.localizedDescription)")
        }
    }
    private func dynamicNoisePlayer(for sound: Sound, isLooping: Bool = true) -> AVAudioPlayer? {
        if let soundPlayerList = soundPlayerLists[sound.name] { return soundPlayerList }
        guard let url = Bundle.main.url(forResource: sound.name, withExtension: sound.ext) else {
            print("⚠️ \(sound.name).\(sound.ext) not in bundle"); return nil
        }
        let p = try? AVAudioPlayer(contentsOf: url)
        if (isLooping) {
            p?.numberOfLoops = -1
        }
        p?.prepareToPlay()
        soundPlayerLists[sound.name] = p
        return p
    }
    func playNoiseDynamic(_ sound: Sound, volume: Float = 1.0) {
        guard sound != soundPlaying else { return }       // already on it
        guard let nextSoundPlayer = dynamicNoisePlayer(for: sound) else { return }
        
        let currentSoundPlayer = soundPlayer

        // fade in the new one -> transition to next sound
        nextSoundPlayer.volume = 0
        nextSoundPlayer.currentTime = 0
        nextSoundPlayer.play()
        nextSoundPlayer.setVolume(volume, fadeDuration: soundFadeDuration/2)

        // fade out the old one
        currentSoundPlayer?.setVolume(0, fadeDuration: soundFadeDuration)

        soundPlayer = nextSoundPlayer
        soundPlaying = sound
        self.isPlaying = true
    }
    func stopNoiseDynamic() {
        soundPlayer?.setVolume(0, fadeDuration: 0.1)
        soundPlayer = nil
        soundPlaying = nil
        self.isPlaying = false
    }
    func setBreathVolume(volume: Float = 1.0) {
        breathVolume = volume
    }
    func playBreathDynamic() {
        
        var sound: Sound = .breathInSound
        if (breathIndex == 0) {
            sound = .breathInSound
        }else if (breathIndex == 2) {
            sound = .breathOutSound
        }else {
            sound = .breathHoldSound
        }
        
        guard sound != breathPlaying else { return }       // already on it
        guard let nextSoundPlayer = dynamicNoisePlayer(for: sound, isLooping: false) else { return }
        
        let currentSoundPlayer = breathPlayer

        // fade in the new one -> transition to next sound
        nextSoundPlayer.volume = 0
        nextSoundPlayer.currentTime = 0
        nextSoundPlayer.play()
        nextSoundPlayer.setVolume(breathVolume, fadeDuration: 0.1)

        // fade out the old one
        currentSoundPlayer?.setVolume(0, fadeDuration: 0.1)

        breathPlayer = nextSoundPlayer
        breathPlaying = sound
        
        self.isBreathPlaying = true
        
    }
    func stopBreathDynamic() {
        breathPlayer?.setVolume(0, fadeDuration: 0.1)
        breathPlayer = nil
        breathPlaying = nil
        self.isBreathPlaying = false
    }
    
    // MARK: - Playback Type 2: Debug Audio (Plays what mic captured)
    func startPlayback() {
        guard let url = recordedAudioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = 0 // Play once
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        } catch {
            print("Playback failed: \(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { allowed in
            DispatchQueue.main.async {
                completion(allowed)
            }
        }
    }

}
