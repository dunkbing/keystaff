//
//  PracticeView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

struct PracticeView: View {
    @StateObject private var gameManager = GameManager()
    @EnvironmentObject var settings: GameSettings
    @State private var inputMode: InputMode = .musicNotes
    @State private var showOptions = false
    @State private var showMenu = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Menu button
                HStack {
                    Button(action: { showMenu = true }) {
                        Text("Menu")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Rectangle()
                    .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    .frame(height: 4)
                    .padding(.top, 8)

                // Stats row
                HStack(spacing: 40) {
                    StatView(title: "Time", value: gameManager.formattedTime)
                    StatView(title: "Score", value: "\(gameManager.score)")
                    StatView(title: "Accuracy", value: gameManager.accuracy)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
                    .frame(minHeight: 20, maxHeight: 40)

                // Staff with note
                StaffView(
                    note: gameManager.currentNote,
                    clef: gameManager.currentClef,
                    showNote: gameManager.isGameActive
                )
                .padding(.horizontal)
                .padding(.vertical, 20)
                .opacity(gameManager.showFeedback ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: gameManager.showFeedback)

                Spacer()
                    .frame(minHeight: 10, maxHeight: 30)

                // Input mode toggle
                HStack(spacing: 16) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Button(action: { inputMode = mode }) {
                            Text(mode.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(
                                    inputMode == mode ? Color.appText : Color.appSubtitle)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            inputMode == mode
                                                ? Color.appMantle : Color.clear
                                        )
                                )
                        }
                    }
                }
                .padding(.bottom, 12)

                // Input area
                Group {
                    if inputMode == .musicNotes {
                        MusicNoteButtonsView(
                            includeAccidentals: settings.includeAccidentals
                        ) { note, accidental in
                            if gameManager.isGameActive {
                                gameManager.checkAnswer(note, accidental: accidental)
                            }
                        }
                        .padding(.horizontal, 12)
                    } else {
                        PianoKeyboardView { note, accidental in
                            if gameManager.isGameActive {
                                gameManager.checkAnswer(note, accidental: accidental)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom, 100)
            }

            // Feedback overlay
            if gameManager.showFeedback {
                FeedbackOverlay(isCorrect: gameManager.lastAnswerCorrect)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }

            // Start game overlay
            if !gameManager.isGameActive {
                StartGameOverlay {
                    gameManager.startGame()
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showMenu) {
            MenuView(
                showOptions: $showOptions,
                onStartGame: {
                    showMenu = false
                    gameManager.resetGame()
                }
            )
        }
        .sheet(isPresented: $showOptions) {
            OptionsView()
                .environmentObject(settings)
        }
        .navigationBarHidden(true)
    }
}

struct StatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.appText)
        }
    }
}

struct FeedbackOverlay: View {
    let isCorrect: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(isCorrect ? .green : .red)
        }
    }
}

struct StartGameOverlay: View {
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            Button(action: onStart) {
                Text("Start Practice")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    )
            }
        }
    }
}

struct MenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showOptions: Bool
    let onStartGame: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    onStartGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Practice")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    )
                }

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    showOptions = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Options")
                    }
                    .font(.headline)
                    .foregroundColor(Color.appText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appMantle)
                    )
                }

                NavigationLink(destination: LearnView()) {
                    HStack {
                        Image(systemName: "book")
                        Text("Learn")
                    }
                    .font(.headline)
                    .foregroundColor(Color.appText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appMantle)
                    )
                }

                Spacer()
            }
            .padding()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.appAccent)
                }
            }
        }
    }
}

#Preview {
    PracticeView()
        .environmentObject(GameSettings.shared)
}
