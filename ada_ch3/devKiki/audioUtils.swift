import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordedAudioURL: URL?
    
    // New analysis properties
    @Published var recommendedNoise: String = "Analyzing..."
    @Published var ambientDecibels: Float = -160.0
    
    // debug
    @Published var debugPeakPower: Float = -160.0
    @Published var debugVariance: Float = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var analysisTimer: Timer?
    
    // Variables to track variations in sound
    private var decibelHistory: [Float] = []
    
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
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            
            // 1. Enable metering so we can read volume levels
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordedAudioURL = fileURL
            recommendedNoise = "Analyzing environment..."
            decibelHistory.removeAll()
            
            // 2. Start a timer to analyze the audio every 0.2 seconds
            startAnalyzing()
            
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        analysisTimer?.invalidate()
        
        // Finalize the choice when recording stops
        determineBestNoiseColor()
    }
    
    private func startAnalyzing() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder, recorder.isRecording else { return }
            
            // Refresh decibel metrics
            recorder.updateMeters()
            
            // averagePower returns a value from -160 (silence) to 0 (max volume)
            let currentPower = recorder.averagePower(forChannel: 0)
            let peakPower = recorder.peakPower(forChannel: 0)
            let variance = peakPower - currentPower
            
            DispatchQueue.main.async {
                self.ambientDecibels = currentPower
                
                // start debug
                self.debugPeakPower = peakPower
                self.debugVariance = variance
                // end debug
                
                self.decibelHistory.append(variance)
            }
        }
    }
    
    private func determineBestNoiseColor() {
        guard !decibelHistory.isEmpty else { return }
        
        // Calculate the average variance of the room
        let avgVariance = decibelHistory.reduce(0, +) / Float(decibelHistory.count)
        
        // Fallback if the room is dead silent
        if ambientDecibels < -55 {
            recommendedNoise = "Pure Silence (Room is already quiet!)"
            return
        }
        
        // Map the ambient variance to a specific type of background noise
        if avgVariance > 12.0 {
            // High variance means lots of sudden erratic spikes (clacking, footsteps, clicking)
            recommendedNoise = "White Noise (Best for blocking sudden, sharp sounds like clicking or typing)"
        } else if ambientDecibels > -35 {
            // Loud but consistent background noise (traffic rumbles, heavy machinery)
            recommendedNoise = "Green Noise (Best for washing out heavy, low-mid mechanical sounds and traffic)"
        } else {
            // Moderate, steady ambient environment (office hums, distant chatter)
            recommendedNoise = "Pink Noise (Best for balanced, steady environments like office chatter)"
        }
    }
    
    // MARK: - Playback
    func startPlayback() {
        guard let url = recordedAudioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Playback failed: \(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
