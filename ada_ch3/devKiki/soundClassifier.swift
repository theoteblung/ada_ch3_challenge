import Foundation
import AVFoundation
import SoundAnalysis
import Combine

class SoundClassifier: NSObject, ObservableObject, SNResultsObserving {
    @Published var isAnalyzing = false
    @Published var detectedSound: String = "Quiet / Unknown"
    @Published var recommendedNoise: String = "Awaiting Analysis..."
    @Published var confidence: Double = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "com.app.soundanalysis.queue")
    
    private var classifyRequest: SNClassifySoundRequest?
    
    func startAnalysis() {
        AVAudioApplication.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }
            guard allowed else {
                print("Microphone permission denied.")
                return
            }
            
            // 🔥 FORCE CONFIGURATION OF AUDIO SESSION BEFORE ENGINE INITIALIZATION
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                
                // Now that the session is guaranteed active, start the engine on the main thread
                DispatchQueue.main.async {
                    self.setupAndStartAudioEngine()
                }
            } catch {
                print("Failed to activate audio session inside SoundClassifier: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupAndStartAudioEngine() {
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        
        let inputNode = engine.inputNode
        let bus = 0
        
        // 1. ALWAYS use the exact native format of the hardware bus for the tap
        let hardwareFormat = inputNode.inputFormat(forBus: bus)
        
        // 2. Double-check that the hardware actually returned valid numbers
        guard hardwareFormat.sampleRate > 0, hardwareFormat.channelCount > 0 else {
            print("❌ Critical Error: Microphone hardware returned an invalid format (0 Hz or 0 channels).")
            return
        }
        
        do {
            // Initialize the sound classification request
            classifyRequest = try SNClassifySoundRequest(classifierIdentifier: .version1)
            
            // 3. Set up the analyzer using the hardware format
            streamAnalyzer = SNAudioStreamAnalyzer(format: hardwareFormat)
            
            guard let request = classifyRequest else { return }
            try streamAnalyzer?.add(request, withObserver: self)
            
            // 4. Install the tap matching the hardwareFormat EXACTLY
            inputNode.installTap(onBus: bus, bufferSize: 8192, format: hardwareFormat) { [weak self] buffer, time in
                self?.analysisQueue.async {
                    self?.streamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
            
            // 5. Explicitly prepare the engine before starting to allocate audio resources cleanly
            engine.prepare()
            try engine.start()
            
            DispatchQueue.main.async {
                self.isAnalyzing = true
                self.detectedSound = "Listening..."
                self.recommendedNoise = "Analyzing background textures..."
            }
            
        } catch {
            print("Sound Analysis setup failed: \(error.localizedDescription)")
            stopAnalysis()
        }
    }
    
    func stopAnalysis() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        if let request = classifyRequest {
            streamAnalyzer?.remove(request)
        }
        
        audioEngine = nil
        streamAnalyzer = nil
        
        DispatchQueue.main.async {
            self.isAnalyzing = false
        }
    }
    
    // MARK: - SNResultsObserving Delegate
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult,
              let topClassification = classificationResult.classifications.first else { return }
        
        guard topClassification.confidence > 0.50 else { return }
        
        let identifier = topClassification.identifier
        
        DispatchQueue.main.async {
            self.detectedSound = identifier.replacingOccurrences(of: "_", with: " ").capitalized
            self.confidence = topClassification.confidence * 100
            self.determineRecommendation(for: identifier)
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Analysis request failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("Analysis request completed.")
    }
    
    private func determineRecommendation(for soundIdentifier: String) {
        switch soundIdentifier {
        case "typing", "keyboard", "mouse_click", "clapping", "snapping_fingers", "laughter":
            self.recommendedNoise = "White Noise (Best to drown out sudden, sharp office/ambient spikes)"
            
        case "traffic", "car", "bus", "motorcycle", "train", "vacuum_cleaner", "lawn_mower", "tools":
            self.recommendedNoise = "Green Noise (Best to mask heavy, low-frequency vehicle & machinery drones)"
            
        case "speech", "chatter", "whispering", "babbling", "dog", "cat", "music":
            self.recommendedNoise = "Pink Noise (Best for organic soundscapes like voices or active households)"
            
        case "rain", "ocean", "wind", "waterfall":
            self.recommendedNoise = "Nature Active (Environment is already playing natural calming sounds!)"
            
        default:
            self.recommendedNoise = "Pink Noise (Balanced fallback for general background environments)"
        }
    }
}
