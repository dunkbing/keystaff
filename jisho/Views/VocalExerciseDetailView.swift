//
//  VocalExerciseDetailView.swift
//  jisho
//

import SwiftUI

struct VocalExerciseDetailView: View {
    let exercise: VocalExercise
    let onStart: () -> Void
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.appText)
                            .padding(10)
                            .background(Circle().fill(Color.appSurface))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                HStack(spacing: 8) {
                    Image(systemName: "headphones")
                        .font(.system(size: 13))
                    Text("Wired Headphones Recommended")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Color.appSubtitle)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.appSurface))
                .padding(.top, 4)

                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: exercise.category.iconName)
                            .font(.system(size: 12, weight: .semibold))
                        Text(LocalizedStringKey(exercise.category.rawValue))
                            .font(.system(size: 13, weight: .bold))
                            .textCase(.uppercase)
                    }
                    .foregroundColor(Color.appSubtitle)

                    Text(exercise.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color.appText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 18)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        VStack(spacing: 10) {
                            VocalPatternPreview(pattern: exercise.pattern)
                                .frame(height: 110)
                                .padding(.horizontal, 28)

                            Text(exercise.syllables.joined(separator: " · "))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color.appText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.appMantle)
                        )

                        infoCard(title: "Goal", text: exercise.goal)
                        infoCard(title: "Instructions", text: exercise.instructions)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 20)
                }

                Button(action: onStart) {
                    Text("Start")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.91, green: 0.55, blue: 0.56),
                                            Color(red: 0.85, green: 0.45, blue: 0.46),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.35),
                                    radius: 10,
                                    y: 5
                                )
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private func infoCard(title: LocalizedStringKey, text: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .foregroundColor(Color.appSubtitle)
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color.appText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appMantle)
        )
    }
}
