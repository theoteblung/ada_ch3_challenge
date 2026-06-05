import Foundation
import AVFoundation
import Accelerate
import Combine

class SoundAnalyzer: ObservableObject {
    enum AnalyzerState: Equatable {
        case idle
        case analyzing(remainingTime: Int)
        case completed
    }
    
    @Published var state: AnalyzerState = .idle
    @Published var currentDecibel: Float = 0.0
    @Published var dominantFrequency: Float = 0.0
    @Published var recommendedColor: String = "Ready to analyze"
    
    @Published var lastLowEnergy: Float = 0.0
    @Published var lastMidEnergy: Float = 0.0
    @Published var lastHighEnergy: Float = 0.0
    
    private let audioEngine = AVAudioEngine()
    private let bufferSize: AVAudioFrameCount = 4096
    
    // Arrays to collect data over time
    private var collectedDecibels: [Float] = []
    private var collectedMagnitudes: [[Float]] = []
    private var analysisTimer: Timer?
    private var sampleRateSnapshot: Float = 44100.0
    private var frameCountSnapshot: Int = 4096
    
    func startTimedMonitoring(duration: TimeInterval) {
        // Reset old data structures
        collectedDecibels.removeAll()
        collectedMagnitudes.removeAll()
        
        // Activate Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        var finalFormat = recordingFormat
        if recordingFormat.sampleRate <= 0 || recordingFormat.channelCount == 0 {
            if let fallback = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1) {
                finalFormat = fallback
            }
        }
        
        sampleRateSnapshot = Float(finalFormat.sampleRate)
        frameCountSnapshot = Int(bufferSize)
        
        // Update UI state to show counting down
        var timeLeft = Int(duration)
        DispatchQueue.main.async {
            self.state = .analyzing(remainingTime: timeLeft)
            self.recommendedColor = "Listening to environment..."
        }
        
        // Start a 1-second interval timer for the UI countdown
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            timeLeft -= 1
            
            DispatchQueue.main.async {
                if timeLeft <= 0 {
                    self.stopAndProcessAnalysis()
                } else {
                    self.state = .analyzing(remainingTime: timeLeft)
                }
            }
        }
        
        // Install Audio Tap to capture ongoing sound slices
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: finalFormat) { [weak self] (buffer, time) in
            guard let self = self else { return }
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameCount = Int(buffer.frameLength)
            
            // 1. Snapshot raw RMS Decibels
            var rms: Float = 0.0
            vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameCount))
            let db = 20 * log10(max(rms, 0.00001)) + 100
            
            // 2. Snapshot FFT Magnitudes array
            let magnitudes = self.analyzeFrequencies(buffer: buffer)
            
            // 3. FIX: Calculate the IMMEDIATE live frequency right now for the UI
            var maxMagnitude: Float = 0.0
            var maxIndex: vDSP_Length = 0
            vDSP_maxvi(magnitudes, 1, &maxMagnitude, &maxIndex, vDSP_Length(magnitudes.count))
            let liveHz = Float(maxIndex) * (self.sampleRateSnapshot / Float(frameCount))
            
            // Append data to memory arrays for the final historical average
            self.collectedDecibels.append(db)
            self.collectedMagnitudes.append(magnitudes)
            
            // 4. FIX: Push BOTH live decibels AND live frequency back to UI thread instantly
            DispatchQueue.main.async {
                self.currentDecibel = db
                self.dominantFrequency = liveHz // 👈 This updates your "Live Freq" card in real-time!
            }
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    private func stopAndProcessAnalysis() {
        // Stop timer and audio hardware
        analysisTimer?.invalidate()
        analysisTimer = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        
        guard !collectedDecibels.isEmpty, !collectedMagnitudes.isEmpty else {
            state = .idle
            recommendedColor = "No data captured."
            return
        }
        
        // 1. Calculate Average Decibel
        let avgDecibels = collectedDecibels.reduce(0, +) / Float(collectedDecibels.count)
        
        // 2. Average out the frequency magnitudes arrays across time
        let bucketCount = collectedMagnitudes[0].count
        var averagedMagnitudes = [Float](repeating: 0.0, count: bucketCount)
        
        for bucketIndex in 0..<bucketCount {
            var totalMagForBucket: Float = 0.0
            for snapshot in collectedMagnitudes {
                totalMagForBucket += snapshot[bucketIndex]
            }
            averagedMagnitudes[bucketIndex] = totalMagForBucket / Float(collectedMagnitudes.count)
        }
        
        // 3. Find Dominant Frequency from the Averaged Magnitudes
        var maxMagnitude: Float = 0.0
        var maxIndex: vDSP_Length = 0
        vDSP_maxvi(averagedMagnitudes, 1, &maxMagnitude, &maxIndex, vDSP_Length(bucketCount))
        let finalHz = Float(maxIndex) * (sampleRateSnapshot / Float(frameCountSnapshot * 2)) // Frequency scaling factor correction
        
        // 4. Calculate Energy Zones from Averaged Magnitudes
        let zones = calculateFrequencyZones(magnitudes: averagedMagnitudes, sampleRate: sampleRateSnapshot, frameCount: frameCountSnapshot * 2)
        
        // Update UI properties permanently for the final result view
        self.currentDecibel = avgDecibels
        self.dominantFrequency = finalHz
        self.state = .completed
        
        self.evaluateRecommendation(
            lowEnergy: zones.low,
            midEnergy: zones.mid,
            highEnergy: zones.high,
            decibels: avgDecibels
        )
    }
    
    func analyzeFrequencies(buffer: AVAudioPCMBuffer) -> [Float] {
        let frameCount = Int(buffer.frameLength)
        let log2n = vDSP_Length(log2(Double(frameCount)))
        guard let sourceData = buffer.floatChannelData?[0] else { return Array(repeating: 0.0, count: frameCount / 2) }
        
        guard let fft = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self) else {
            return Array(repeating: 0.0, count: frameCount / 2)
        }
        
        var realParts = [Float](repeating: 0.0, count: frameCount / 2)
        var imaginaryParts = [Float](repeating: 0.0, count: frameCount / 2)
        
        realParts.withUnsafeMutableBufferPointer { realPtr in
            imaginaryParts.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                sourceData.withMemoryRebound(to: DSPComplex.self, capacity: frameCount / 2) { complexPtr in
                    vDSP_ctoz(complexPtr, 2, &splitComplex, 1, vDSP_Length(frameCount / 2))
                }
                fft.forward(input: splitComplex, output: &splitComplex)
            }
        }
        
        var magnitudes = [Float](repeating: 0.0, count: frameCount / 2)
        realParts.withUnsafeBufferPointer { rPtr in
            imaginaryParts.withUnsafeBufferPointer { iPtr in
                var splitComplex = DSPSplitComplex(
                    realp: UnsafeMutablePointer(mutating: rPtr.baseAddress!),
                    imagp: UnsafeMutablePointer(mutating: iPtr.baseAddress!)
                )
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(frameCount / 2))
            }
        }
        return magnitudes
    }
    
    private func calculateFrequencyZones(magnitudes: [Float], sampleRate: Float, frameCount: Int) -> (low: Float, mid: Float, high: Float) {
        var lowSum: Float = 0.0; var lowCount: Float = 0.0
        var midSum: Float = 0.0; var midCount: Float = 0.0
        var highSum: Float = 0.0; var highCount: Float = 0.0
        
        for index in 0..<magnitudes.count {
            let currentHz = Float(index) * (sampleRate / Float(frameCount))
            let magnitude = magnitudes[index]
            
            switch currentHz {
            case 20...250:
                lowSum += magnitude; lowCount += 1
            case 251...2000:
                midSum += magnitude; midCount += 1
            case 2001...8000:
                highSum += magnitude; highCount += 1
            default:
                break
            }
        }
        return (
            lowCount > 0 ? (lowSum / lowCount) : 0,
            midCount > 0 ? (midSum / midCount) : 0,
            highCount > 0 ? (highSum / highCount) : 0
        )
    }
    
    func evaluateRecommendation(lowEnergy: Float, midEnergy: Float, highEnergy: Float, decibels: Float) {
        DispatchQueue.main.async {
            self.lastLowEnergy = lowEnergy
            self.lastMidEnergy = midEnergy
            self.lastHighEnergy = highEnergy
        }
        
        let energyThreshold: Float = 0.5
        
        if decibels < 45 {
            recommendedColor = "Green Noise / Nature (Quiet environment. No masking needed.)"
        } else if lowEnergy > energyThreshold && lowEnergy > midEnergy {
            recommendedColor = "Brown Noise (To completely absorb heavy background engine or AC rumbles.)"
        } else if midEnergy > energyThreshold {
            recommendedColor = "White Noise (Best for completely blocking out chaotic human speech.)"
        } else if highEnergy > energyThreshold && highEnergy > midEnergy {
            recommendedColor = "Pink Noise (To naturally soften piercing, sharp high-frequency sounds.)"
        } else {
            recommendedColor = "Pink Noise (Balanced background protection.)"
        }
    }
}
