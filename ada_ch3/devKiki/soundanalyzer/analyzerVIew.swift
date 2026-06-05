import SwiftUI
import AVFAudio

struct AnalyzerView: View {
    @StateObject private var analyzer = SoundAnalyzer()
    @State private var debugLogs: [String] = ["System Initialized..."]
    @State private var analysisDuration: TimeInterval = 10.0
    
    private var isAnalyzing: Bool {
        if case .analyzing = analyzer.state { return true }
        return false
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
            VStack(spacing: 4) {
                Text("Sound Environment Analyzer")
                    .font(.title2)
                    .bold()
                Text("Samples audio over time for stable profiles")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // MARK: - Status & Countdown display
            VStack(spacing: 8) {
                switch analyzer.state {
                case .idle:
                    Text("Ready to Analyze")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                case .analyzing(let remainingTime):
                    HStack {
                        ProgressView()
                            .padding(.trailing, 4)
                        Text("Analyzing Environment... \(remainingTime)s left")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                case .completed:
                    Text("✅ Analysis Complete")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            // MARK: - Recommendation Result Box
            VStack(spacing: 12) {
                Text(analyzer.state == .completed ? "FINAL RECOMMENDATION" : "CURRENT STATUS")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                
                Text(analyzer.recommendedColor)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            
            // MARK: - NEW: Decision Logic Inspector Panel
            VStack(alignment: .leading, spacing: 10) {
                Label("Recommendation Logic Diagnostic", systemImage: "chart.bar.doc.horizontal")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    DebugMetricRow(label: "Low (Bass)", value: analyzer.lastLowEnergy, threshold: 0.5)
                    DebugMetricRow(label: "Mid (Voice)", value: analyzer.lastMidEnergy, threshold: 0.5)
                    DebugMetricRow(label: "High (Sharp)", value: analyzer.lastHighEnergy, threshold: 0.5)
                }
                
                Text("Threshold trigger line is set to: **0.50**")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // MARK: - Metrics Layout
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                MetricCard(
                    title: analyzer.state == .completed ? "Average Volume" : "Live Volume",
                    value: String(format: "%.1f dB", analyzer.currentDecibel),
                    icon: "waveform.and.mic",
                    color: analyzer.currentDecibel > 75 ? .red : .green
                )
                
                MetricCard(
                    title: analyzer.state == .completed ? "Dominant Freq" : "Live Freq",
                    value: analyzer.state == .idle ? "0 Hz" : String(format: "%.0f Hz", analyzer.dominantFrequency),
                    icon: "tuningfork",
                    color: .blue
                )
            }
            
            // MARK: - Duration Selector
            if !isAnalyzing {
                Picker("Duration", selection: $analysisDuration) {
                    Text("10 Seconds").tag(10.0)
                    Text("20 Seconds").tag(20.0)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 4)
            }
            
            // MARK: - Value Tracer Terminal
            VStack(alignment: .leading, spacing: 6) {
                Label("Live Value Tracer", systemImage: "terminal")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.green)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(debugLogs, id: \.self) { log in
                            Text(log)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(height: 100)
                .padding(10)
                .background(Color.black)
                .cornerRadius(8)
            }
            
            Spacer()
            
            // MARK: - Action Control Button
            Button(action: {
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        if granted {
                            appendLog("Starting a \(Int(analysisDuration))s profile capture...")
                            analyzer.startTimedMonitoring(duration: analysisDuration)
                        } else {
                            appendLog("ERROR: Microphone permission denied.")
                        }
                    }
                }
            }) {
                Label(analyzer.state == .completed ? "Re-Analyze Sound" : "Start Analysis", systemImage: "play.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAnalyzing ? Color.gray : Color.accentColor)
                    .cornerRadius(12)
            }
            .disabled(isAnalyzing)
        }
        .padding()
        .onChange(of: analyzer.currentDecibel) {
            traceValues()
        }
        .onChange(of: analyzer.state) { oldValue, newState in
            if case .completed = newState {
                appendLog("🎉 Session Finished! Math profiles aggregated.")
            }
        }
    }
    
    private func traceValues() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timestamp = formatter.string(from: Date())
        
        let statePrefix = isAnalyzing ? "[REC]" : "[LIVE]"
        
        // NEW: Enriched log format that records the raw decision data inline
        let logLine = "\(statePrefix) [\(timestamp)] dB: \(String(format: "%.1f", analyzer.currentDecibel)) | L:\(String(format: "%.2f", analyzer.lastLowEnergy)) M:\(String(format: "%.2f", analyzer.lastMidEnergy)) H:\(String(format: "%.2f", analyzer.lastHighEnergy))"
        
        print(logLine)
        appendLog(logLine)
    }
    
    private func appendLog(_ message: String) {
        debugLogs.append(message)
        if debugLogs.count > 15 {
            debugLogs.removeFirst()
        }
    }
}

// MARK: - NEW: Subview for Inspector Energy Rows
struct DebugMetricRow: View {
    let label: String
    let value: Float
    let threshold: Float
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
            
            Text(String(format: "%.3f", value))
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(value > threshold ? .orange : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
    }
}

// (MetricCard Subview stays exactly the same)
struct MetricCard: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundColor(color).font(.subheadline)
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.headline).bold().minimumScaleFactor(0.8).lineLimit(1)
                Text(title).font(.system(size: 11)).foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyzerView()
}
