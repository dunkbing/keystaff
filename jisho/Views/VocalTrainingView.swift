//
//  VocalTrainingView.swift
//  jisho
//

import SwiftUI

struct VocalTrainingView: View {
    @StateObject private var settings = VocalTrainingSettings.shared
    @ObservedObject private var store = VocalProgressStore.shared
    @State private var detailExercise: VocalExercise?
    @State private var sessionExercise: VocalExercise?
    @State private var showRangeTest = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.03),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Vocal")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color.appText)

                        Spacer()

                        Button(action: { showRangeTest = true }) {
                            Image(systemName: "tuningfork")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.appAccent)
                                .padding(10)
                                .background(Circle().fill(Color.appMantle))
                        }
                    }

                    progressHeader

                    ForEach(VocalExerciseCategory.allCases) { category in
                        categorySection(category)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 140)
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $detailExercise) { exercise in
            VocalExerciseDetailView(exercise: exercise) {
                detailExercise = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    sessionExercise = exercise
                }
            }
        }
        .sheet(isPresented: $showRangeTest) {
            VocalRangeTestView()
        }
        .fullScreenCover(item: $sessionExercise) { exercise in
            VocalExerciseSessionView(exercise: exercise)
        }
    }

    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.appSurface2, lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: min(1, CGFloat(store.todayCount) / CGFloat(max(1, settings.dailyGoal))))
                        .stroke(
                            Color.appAccent,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text("\(store.todayCount)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.appText)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily Goal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.appText)
                    Text("\(store.todayCount) / \(settings.dailyGoal) exercises today")
                        .font(.system(size: 13))
                        .foregroundColor(Color.appSubtitle)
                }

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("\(store.streak)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.appText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.appSurface))
            }

            HStack {
                Text("Vocal Range")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.appSubtitle)
                Spacer()
                Menu {
                    ForEach(VoiceType.allCases) { voice in
                        Button(action: { settings.voiceType = voice }) {
                            if settings.voiceType == voice {
                                Label(voice.rawValue, systemImage: "checkmark")
                            } else {
                                Text(voice.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "music.mic")
                            .font(.system(size: 12))
                        Text(settings.voiceType.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(Color.appAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.appSurface))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.appMantle)
        )
    }

    // MARK: - Category Section
    private func categorySection(_ category: VocalExerciseCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.system(size: 13, weight: .semibold))
                Text(LocalizedStringKey(category.rawValue))
                    .font(.system(size: 14, weight: .bold))
                    .textCase(.uppercase)
            }
            .foregroundColor(Color.appText)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.appSurface))

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(VocalExercise.exercises(in: category)) { exercise in
                    exerciseCard(exercise)
                }
            }
        }
    }

    private func exerciseCard(_ exercise: VocalExercise) -> some View {
        Button(action: { detailExercise = exercise }) {
            VStack(alignment: .leading, spacing: 10) {
                VocalPatternPreview(pattern: exercise.pattern)
                    .frame(height: 64)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.appMantle)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.appText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    VocalStarsView(stars: store.bestStars(for: exercise.id), size: 10)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pattern Preview
struct VocalPatternPreview: View {
    let pattern: [Int]
    var barColor: Color = Color.appText

    var body: some View {
        GeometryReader { geo in
            let minOffset = pattern.min() ?? 0
            let maxOffset = pattern.max() ?? 1
            let span = max(1, maxOffset - minOffset)
            let count = pattern.count
            let barWidth = min(26, max(10, geo.size.width / CGFloat(count) - 6))
            let stepX = count > 1 ? (geo.size.width - barWidth) / CGFloat(count - 1) : 0
            let usableHeight = geo.size.height - 6

            ForEach(Array(pattern.enumerated()), id: \.offset) { index, offset in
                Capsule()
                    .fill(barColor)
                    .frame(width: barWidth, height: 5)
                    .position(
                        x: barWidth / 2 + stepX * CGFloat(index),
                        y: 3 + usableHeight
                            * (1 - CGFloat(offset - minOffset) / CGFloat(span))
                    )
            }
        }
    }
}

// MARK: - Stars
struct VocalStarsView: View {
    let stars: Int
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(index < stars ? Color.appAccent : Color.appSurface2)
            }
        }
    }
}
