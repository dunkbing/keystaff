//
//  MetronomeView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import UIKit
import TikimUI
import ActivityKit

class MetronomeManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var tempo: Double = 120
    @Published var timeSignature: TimeSignature = .fourFour {
        didSet { updateBeatCycle() }
    }
    @Published var currentBeat: Int = 0

    private var timer: DispatchSourceTimer?
    private let audioManager = AudioManager.shared
    private var beatIndex: Int = 0
    private var resumeWorkItem: DispatchWorkItem?
    private var wasPlayingBeforeAdjustment = false
    private let autoResumeDelay: TimeInterval = 0.7
    private let timerQueue = DispatchQueue(label: "dev.db99.keystaff.metronome.timer", qos: .userInitiated)

    // Live Activity - stored as Any to avoid @available on stored property
    private var currentActivity: Any?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemotePlay),
            name: .metronomeRemotePlay,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemotePause),
            name: .metronomeRemotePause,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteStop),
            name: .metronomeRemoteStop,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var bpm: String {
        String(format: "%.0f", tempo)
    }

    func togglePlay() {
        if isPlaying {
            stop()
        } else {
            cancelAutoResume(resetFlag: true)
            start()
        }
    }

    func start() {
        resetTimerState()
        audioManager.stopMetronome()
        isPlaying = true
        beatIndex = timeSignature.beatsPerMeasure - 1
        currentBeat = 0
        scheduleTimer(fireImmediately: true)
        wasPlayingBeforeAdjustment = false
        audioManager.updateMetronomeNowPlaying(
            isPlaying: true,
            tempo: tempo,
            timeSignature: timeSignature,
            currentBeat: currentBeat
        )
        startLiveActivity()
    }

    func stop() {
        cancelAutoResume(resetFlag: true)
        isPlaying = false
        resetTimerState()
        beatIndex = 0
        currentBeat = 0
        audioManager.stopMetronome()
        audioManager.updateMetronomeNowPlaying(
            isPlaying: false,
            tempo: tempo,
            timeSignature: timeSignature,
            currentBeat: currentBeat
        )
        endLiveActivity()
    }

    func updateBeatCycle() {
        beatIndex = beatIndex % max(timeSignature.beatsPerMeasure, 1)
        currentBeat = beatIndex
    }

    private func scheduleTimer(fireImmediately: Bool) {
        guard isPlaying else { return }

        let interval = 60.0 / tempo

        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now() + interval, repeating: interval, leeway: .milliseconds(1))
        timer.setEventHandler { [weak self] in
            self?.handleNextBeat()
        }
        timer.resume()
        self.timer = timer

        if fireImmediately {
            timerQueue.async { [weak self] in
                self?.handleNextBeat()
            }
        }
    }

    func handleTempoEditingChange(isEditing: Bool) {
        if isEditing {
            beginInteractiveChange()
        } else {
            endInteractiveChange()
            audioManager.updateMetronomeNowPlaying(
                isPlaying: isPlaying,
                tempo: tempo,
                timeSignature: timeSignature,
                currentBeat: currentBeat
            )
            updateLiveActivity()
        }
    }

    func changeTimeSignature(to signature: TimeSignature) {
        guard timeSignature != signature else { return }
        let shouldResume = isPlaying || wasPlayingBeforeAdjustment

        if shouldResume {
            beginInteractiveChange()
            wasPlayingBeforeAdjustment = true
        } else {
            cancelAutoResume(resetFlag: true)
        }

        timeSignature = signature
        audioManager.updateMetronomeNowPlaying(
            isPlaying: isPlaying,
            tempo: tempo,
            timeSignature: timeSignature,
            currentBeat: currentBeat
        )
        updateLiveActivity()

        if shouldResume {
            endInteractiveChange()
        }
    }

    private func beginInteractiveChange() {
        cancelAutoResume(resetFlag: false)

        if isPlaying {
            wasPlayingBeforeAdjustment = true
            pauseMetronomeForAdjustment()
        }
    }

    private func endInteractiveChange() {
        scheduleAutoResume()
    }

    private func pauseMetronomeForAdjustment() {
        guard isPlaying else { return }

        resetTimerState()
        audioManager.stopMetronome()
        isPlaying = false
        beatIndex = 0
        currentBeat = 0
        audioManager.updateMetronomeNowPlaying(
            isPlaying: false,
            tempo: tempo,
            timeSignature: timeSignature,
            currentBeat: currentBeat
        )
    }

    private func scheduleAutoResume() {
        cancelAutoResume(resetFlag: false)
        guard wasPlayingBeforeAdjustment else { return }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.start()
            self.wasPlayingBeforeAdjustment = false
        }

        resumeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + autoResumeDelay, execute: workItem)
    }

    private func cancelAutoResume(resetFlag: Bool) {
        resumeWorkItem?.cancel()
        resumeWorkItem = nil

        if resetFlag {
            wasPlayingBeforeAdjustment = false
        }
    }

    private func resetTimerState() {
        timer?.cancel()
        timer = nil
    }

    private func handleNextBeat() {
        guard isPlaying else { return }

        beatIndex = (beatIndex + 1) % timeSignature.beatsPerMeasure
        let currentBeatIndex = beatIndex
        let isAccent = timeSignature.accentBeats.contains(currentBeatIndex)

        audioManager.playMetronomeBeat(isAccent: isAccent)
        audioManager.updateMetronomeNowPlaying(
            isPlaying: true,
            tempo: tempo,
            timeSignature: timeSignature,
            currentBeat: currentBeatIndex
        )

        DispatchQueue.main.async { [weak self] in
            self?.currentBeat = currentBeatIndex
            self?.updateLiveActivity()
        }
    }

    // MARK: - Remote Command Handling
    @objc private func handleRemotePlay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.isPlaying else { return }
            self.start()
        }
    }

    @objc private func handleRemotePause() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.stop()
        }
    }

    @objc private func handleRemoteStop() {
        DispatchQueue.main.async { [weak self] in
            self?.stop()
        }
    }

    // MARK: - Live Activity Management
    private func startLiveActivity() {
        if #available(iOS 16.2, *) {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                print("Live Activities are not enabled")
                return
            }

            // End any existing activity first
            endLiveActivity()

            let attributes = MetronomeActivityAttributes(appName: "KeyStaff")
            let contentState = MetronomeActivityAttributes.ContentState(
                tempo: tempo,
                timeSignature: timeSignature.rawValue,
                currentBeat: currentBeat,
                isPlaying: isPlaying
            )

            do {
                let activity = try Activity<MetronomeActivityAttributes>.request(
                    attributes: attributes,
                    content: .init(state: contentState, staleDate: nil),
                    pushType: nil
                )
                currentActivity = activity as Any
                print("✅ Live Activity started")
            } catch {
                print("❌ Failed to start Live Activity: \(error)")
            }
        }
    }

    private func updateLiveActivity() {
        if #available(iOS 16.2, *) {
            guard let activity = currentActivity as? Activity<MetronomeActivityAttributes> else { return }

            let contentState = MetronomeActivityAttributes.ContentState(
                tempo: tempo,
                timeSignature: timeSignature.rawValue,
                currentBeat: currentBeat,
                isPlaying: isPlaying
            )

            Task {
                await activity.update(
                    .init(state: contentState, staleDate: nil)
                )
            }
        }
    }

    private func endLiveActivity() {
        if #available(iOS 16.2, *) {
            guard let activity = currentActivity as? Activity<MetronomeActivityAttributes> else { return }

            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
                currentActivity = nil
                print("✅ Live Activity ended")
            }
        }
    }

}

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeManager()
    @Environment(\.scenePhase) private var scenePhase
    private let timeSignatureColumns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 3
    )

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appBackground,
                    Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        ZStack {
                            // Beat indicators around the circle
                            CircularBeatIndicatorView(
                                currentBeat: metronome.currentBeat,
                                totalBeats: metronome.timeSignature.beatsPerMeasure,
                                isPlaying: metronome.isPlaying
                            )
                            .frame(width: 240, height: 240)

                            // Play button inside circle
                            Button(action: { metronome.togglePlay() }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.91, green: 0.55, blue: 0.56),
                                                    Color(red: 0.85, green: 0.45, blue: 0.46)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 88, height: 88)

                                    Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 36, weight: .semibold))
                                        .foregroundColor(.white)
                                        .offset(x: metronome.isPlaying ? 0 : 3)
                                }
                                .shadow(
                                    color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.5),
                                    radius: 20,
                                    y: 8
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.vertical, 20)
                    }

                    // Tempo ruler with enhanced design
                    VStack(spacing: 20) {
                        TempoRulerControl(
                            tempo: $metronome.tempo,
                            onEditingChanged: { editing in
                                metronome.handleTempoEditingChange(isEditing: editing)
                            }
                        )

                        HStack(spacing: 32) {
                            Button(action: {
                                metronome.handleTempoEditingChange(isEditing: true)
                                if metronome.tempo > 40 {
                                    metronome.tempo -= 1
                                }
                                metronome.handleTempoEditingChange(isEditing: false)
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(metronome.tempo > 40 ? Color.appText : Color.appSubtitle.opacity(0.5))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.appSurface2)
                                    )
                            }
                            .disabled(metronome.tempo <= 40)
                            .buttonStyle(ScaleButtonStyle())

                            Text("\(Int(metronome.tempo.rounded())) BPM")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color.appText)

                            Button(action: {
                                metronome.handleTempoEditingChange(isEditing: true)
                                if metronome.tempo < 240 {
                                    metronome.tempo += 1
                                }
                                metronome.handleTempoEditingChange(isEditing: false)
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(metronome.tempo < 240 ? Color.appText : Color.appSubtitle.opacity(0.5))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.appSurface2)
                                    )
                            }
                            .disabled(metronome.tempo >= 240)
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appMantle)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    )
                    .padding(.horizontal, 24)

                    // Time signature selector with card design
                    VStack(spacing: 16) {
                        HStack {
                            Text("TIME SIGNATURE")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(Color.appSubtitle)

                            Spacer()
                        }

                        LazyVGrid(columns: timeSignatureColumns, alignment: .center, spacing: 14) {
                            ForEach(TimeSignature.allCases) { signature in
                                Button(action: {
                                    metronome.changeTimeSignature(to: signature)
                                }) {
                                    VStack(spacing: 8) {
                                        Text(signature.rawValue)
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(
                                                metronome.timeSignature == signature
                                                    ? Color.white : Color.appText
                                            )

                                        if metronome.timeSignature == signature {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                metronome.timeSignature == signature
                                                    ? LinearGradient(
                                                        colors: [
                                                            Color(red: 0.91, green: 0.55, blue: 0.56),
                                                            Color(red: 0.85, green: 0.45, blue: 0.46)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    : LinearGradient(
                                                        colors: [Color.appSurface2, Color.appSurface2],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                            )
                                            .shadow(
                                                color: metronome.timeSignature == signature
                                                    ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.4)
                                                    : Color.clear,
                                                radius: 8,
                                                y: 4
                                            )
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appMantle)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.top, 40)
                .padding(.bottom, 200)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: scenePhase) { newPhase in
            // Don't stop the metronome when going to background
            // It will continue playing with background audio
            if newPhase == .background {
                print("App moved to background - metronome continues")
            } else if newPhase == .active {
                print("App became active")
            }
        }
        .onDisappear {
            metronome.stop()
        }
    }
}

private struct TempoRulerControl: View {
    @Binding var tempo: Double
    var onEditingChanged: (Bool) -> Void

    private let tempoRange: ClosedRange<Int> = 40...240
    private let tickSpacing: CGFloat = 9

    var body: some View {
        VStack(spacing: 14) {
            TrianglePointer()
                .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                .frame(width: 18, height: 12)
                .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurface2)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)

                TempoRulerRepresentable(
                    tempo: $tempo,
                    range: tempoRange,
                    spacing: tickSpacing,
                    onEditingChanged: onEditingChanged
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Rectangle()
                    .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    .frame(width: 2, height: 50)
            }
            .frame(height: 96)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct TempoRulerRepresentable: UIViewRepresentable {
    @Binding var tempo: Double
    let range: ClosedRange<Int>
    let spacing: CGFloat
    var onEditingChanged: (Bool) -> Void

    func makeUIView(context: Context) -> TempoRulerScrollView {
        let scrollView = TempoRulerScrollView(range: range, spacing: spacing)
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }

    func updateUIView(_ scrollView: TempoRulerScrollView, context: Context) {
        scrollView.layoutIfNeeded()
        context.coordinator.update(scrollView: scrollView, tempo: tempo)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func clampedTempo(for value: Double) -> Int {
        let intValue = Int(round(value))
        return min(max(intValue, range.lowerBound), range.upperBound)
    }

    func tempo(for scrollView: UIScrollView) -> Int {
        let rawPosition = scrollView.contentOffset.x + scrollView.contentInset.left
        let relative = rawPosition / spacing
        let candidate = range.lowerBound + Int(round(relative))
        return min(max(candidate, range.lowerBound), range.upperBound)
    }

    func snap(_ scrollView: TempoRulerScrollView, to value: Int, animated: Bool = true) {
        let offset = scrollView.offset(for: value)
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        private let parent: TempoRulerRepresentable
        private var isUserInteracting = false
        private var isEditing = false

        init(parent: TempoRulerRepresentable) {
            self.parent = parent
        }

        func update(scrollView: TempoRulerScrollView, tempo: Double) {
            guard !isUserInteracting else { return }
            let targetTempo = parent.clampedTempo(for: tempo)
            let desiredOffset = scrollView.offset(for: targetTempo)
            if abs(scrollView.contentOffset.x - desiredOffset) > 0.5 {
                scrollView.setContentOffset(CGPoint(x: desiredOffset, y: 0), animated: false)
            }
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isUserInteracting = true
            if !isEditing {
                isEditing = true
                parent.onEditingChanged(true)
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard isUserInteracting else { return }
            let tempoValue = parent.tempo(for: scrollView)
            if parent.clampedTempo(for: parent.$tempo.wrappedValue) != tempoValue {
                parent.$tempo.wrappedValue = Double(tempoValue)
            }
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                finalizeInteraction(on: scrollView)
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            finalizeInteraction(on: scrollView)
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            if !isUserInteracting {
                finalizeInteraction(on: scrollView, shouldNotify: false)
            }
        }

        private func finalizeInteraction(on scrollView: UIScrollView, shouldNotify: Bool = true) {
            guard let tempoScrollView = scrollView as? TempoRulerScrollView else { return }
            let tempoValue = parent.tempo(for: scrollView)
            parent.$tempo.wrappedValue = Double(tempoValue)
            parent.snap(tempoScrollView, to: tempoValue, animated: false)
            if shouldNotify, isEditing {
                parent.onEditingChanged(false)
            }
            isUserInteracting = false
            isEditing = false
        }
    }
}

private final class TempoRulerScrollView: UIScrollView {
    private let contentView: TempoRulerContentView
    private let range: ClosedRange<Int>
    private let spacing: CGFloat

    init(range: ClosedRange<Int>, spacing: CGFloat) {
        self.range = range
        self.spacing = spacing
        self.contentView = TempoRulerContentView(range: range, spacing: spacing)
        super.init(frame: .zero)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = .fast
        bounces = true

        addSubview(contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.intrinsicContentSize
        if contentView.frame.size != size {
            contentView.frame = CGRect(origin: .zero, size: size)
        }
        contentSize = size

        let inset = bounds.width / 2
        if abs(contentInset.left - inset) > 0.5 {
            let currentPosition = contentOffset.x + contentInset.left
            contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            contentOffset = CGPoint(x: currentPosition - inset, y: 0)
        }
    }

    func offset(for tempo: Int) -> CGFloat {
        let clamped = min(max(tempo, range.lowerBound), range.upperBound)
        let position = CGFloat(clamped - range.lowerBound) * spacing
        return position - contentInset.left
    }
}

private final class TempoRulerContentView: UIView {
    private let range: ClosedRange<Int>
    private let spacing: CGFloat
    private let tallHeight: CGFloat = 40
    private let mediumHeight: CGFloat = 25
    private let shortHeight: CGFloat = 12
    private let topPadding: CGFloat = 8

    private var rangeCount: Int {
        range.upperBound - range.lowerBound + 1
    }

    init(range: ClosedRange<Int>, spacing: CGFloat) {
        self.range = range
        self.spacing = spacing
        super.init(frame: .zero)
        backgroundColor = .clear
        contentScaleFactor = UIScreen.main.scale
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: CGFloat(rangeCount - 1) * spacing + 1,
            height: topPadding + tallHeight + 34
        )
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)

        let tickColor = UIColor(Color.appSubtitle.opacity(0.85))
        let labelColor = UIColor(Color.appSubtitle)
        let baseline = topPadding + tallHeight

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: labelColor,
            .paragraphStyle: paragraphStyle
        ]

        for value in range {
            let step = CGFloat(value - range.lowerBound)
            let x = step * spacing

            let isTenth = value % 10 == 0
            let isFifth = value % 5 == 0

            let height: CGFloat = isTenth ? tallHeight : (isFifth ? mediumHeight : shortHeight)
            let lineWidth: CGFloat = isTenth ? 3 : 1.5
            let lineRect = CGRect(
                x: x - lineWidth / 2,
                y: baseline - height,
                width: lineWidth,
                height: height
            )

            let path = UIBezierPath(roundedRect: lineRect, cornerRadius: lineWidth / 2)
            tickColor.setFill()
            path.fill()

            if isTenth {
                let text = "\(value)" as NSString
                let size = text.size(withAttributes: labelAttributes)
                let rect = CGRect(
                    x: x - size.width / 2,
                    y: baseline + 8,
                    width: size.width,
                    height: size.height
                )
                text.draw(in: rect, withAttributes: labelAttributes)
            }
        }
    }
}

struct BeatIndicatorView: View {
    let currentBeat: Int
    let totalBeats: Int
    let isPlaying: Bool

    private var layoutConfiguration: (columns: [GridItem], circleSize: CGFloat, spacing: CGFloat) {
        switch totalBeats {
        case 0...4:
            let count = max(totalBeats, 1)
            return (
                Array(repeating: GridItem(.flexible(), spacing: 18), count: count),
                56,
                18
            )
        case 5...8:
            let columns = Int(ceil(Double(totalBeats) / 2.0))
            return (
                Array(repeating: GridItem(.flexible(), spacing: 14), count: columns),
                46,
                14
            )
        default:
            let columns = Int(ceil(Double(totalBeats) / 2.0))
            return (
                Array(repeating: GridItem(.flexible(), spacing: 12), count: max(columns, 1)),
                38,
                12
            )
        }
    }

    var body: some View {
        let layout = layoutConfiguration

        LazyVGrid(columns: layout.columns, alignment: .center, spacing: layout.spacing) {
            ForEach(0..<totalBeats, id: \.self) { beat in
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            isPlaying && beat == currentBeat
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 0.91, green: 0.55, blue: 0.56),
                                        Color(red: 0.85, green: 0.45, blue: 0.46)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.appSurface2, Color.appSurface2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: layout.circleSize, height: layout.circleSize)

                    // Accent ring for first beat
                    if beat == 0 {
                        Circle()
                            .stroke(
                                Color(red: 0.91, green: 0.55, blue: 0.56),
                                lineWidth: 3
                            )
                            .frame(
                                width: layout.circleSize + 4,
                                height: layout.circleSize + 4
                            )
                            .opacity(isPlaying && beat == currentBeat ? 0 : 0.6)
                    }

                    // Pulse effect when active
                    if isPlaying && beat == currentBeat {
                        Circle()
                            .stroke(
                                Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.6),
                                lineWidth: 2
                            )
                            .frame(
                                width: layout.circleSize + 12,
                                height: layout.circleSize + 12
                            )
                            .scaleEffect(1.2)
                            .opacity(0)
                            .animation(
                                Animation.easeOut(duration: 0.4),
                                value: currentBeat
                            )
                    }

                    // Beat number
                    Text("\(beat + 1)")
                        .font(.system(size: layout.circleSize * 0.35, weight: .bold, design: .rounded))
                        .foregroundColor(
                            isPlaying && beat == currentBeat
                                ? Color.white
                                : Color.appSubtitle
                        )
                }
                .scaleEffect(isPlaying && beat == currentBeat ? 1.15 : 1.0)
                .shadow(
                    color: isPlaying && beat == currentBeat
                        ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.5)
                        : Color.clear,
                    radius: 12,
                    y: 4
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentBeat)
            }
        }
    }
}

struct CircularBeatIndicatorView: View {
    let currentBeat: Int
    let totalBeats: Int
    let isPlaying: Bool

    var body: some View {
        ZStack {
            ForEach(0..<totalBeats, id: \.self) { beat in
                let angle = (Double(beat) / Double(totalBeats)) * 360.0 - 90.0
                let isActive = isPlaying && beat == currentBeat
                let isFirst = beat == 0

                ZStack {
                    // Beat circle
                    Circle()
                        .fill(
                            isActive
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 0.91, green: 0.55, blue: 0.56),
                                        Color(red: 0.85, green: 0.45, blue: 0.46)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.appMantle, Color.appMantle],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: isActive ? 48 : 40, height: isActive ? 48 : 40)

                    // Accent ring for first beat
                    if isFirst && !isActive {
                        Circle()
                            .stroke(
                                Color(red: 0.91, green: 0.55, blue: 0.56),
                                lineWidth: 2.5
                            )
                            .frame(width: 44, height: 44)
                    }

                    // Pulse effect when active
                    if isActive {
                        Circle()
                            .stroke(
                                Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.6),
                                lineWidth: 2
                            )
                            .frame(width: 60, height: 60)
                            .scaleEffect(1.3)
                            .opacity(0)
                            .animation(
                                Animation.easeOut(duration: 0.4),
                                value: currentBeat
                            )
                    }

                    // Beat number
                    Text("\(beat + 1)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(
                            isActive ? Color.white : Color.appText
                        )
                }
                .shadow(
                    color: isActive
                        ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.5)
                        : Color.clear,
                    radius: 12,
                    y: 4
                )
                .offset(
                    x: cos(angle * .pi / 180) * 100,
                    y: sin(angle * .pi / 180) * 100
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentBeat)
            }
        }
    }
}
