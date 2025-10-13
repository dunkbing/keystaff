# Music Note Learning App

A simple iOS music note learning app with metronome, written in Swift.
Supports iOS >= 15

## Features

### Practice Tab
- Learn to read music notes on a staff
- Support for Treble, Bass, and Alto clefs
- Two input modes:
  - **Music Notes**: Letter buttons (C, D, E, F, G, A, B) with sharp/flat accidentals
  - **Piano Keys**: Interactive piano keyboard
- Real-time scoring with timer, score, and accuracy tracking
- Sound playback for notes (optional)
- Visual feedback for correct/incorrect answers
- Configurable practice duration (1 min, 5 mins, 10 mins, or infinite practice mode)

### Metronome Tab
- Professional metronome with tempo control (40-240 BPM)
- Visual beat indicators
- Time signature selection (2/4, 3/4, 4/4, 6/8)
- Accent on first beat
- Play/pause controls
- Beat sound playback

### Settings Tab
- Theme management (Catppuccin color schemes)
- Language settings
- App preferences

### Learn Section
- Educational reference screens for each clef (Treble, Bass, Alto)
- Visual staff examples with note positions
- Music theory basics

## Architecture

### Models (`jisho/Models/`)
- `MusicModels.swift`: Core data structures
  - `MusicNote`: Represents a musical note with name, octave, and accidental
  - `NoteName`: Enum for note names (C-B)
  - `Accidental`: Natural, sharp, flat
  - `Clef`: Treble, bass, alto with default note ranges
  - `GameSettings`: Practice configuration (clefs, range, duration, sounds)
  - `TimeSignature`: For metronome

### Managers (`jisho/Managers/`)
- `AudioManager.swift`: Sound generation for notes and metronome using AVFoundation
- `GameManager.swift`: Practice game logic, scoring, and answer checking with enharmonic equivalents

### Views (`jisho/Views/`)
- `ContentView.swift`: Main tab container
- `PracticeView.swift`: Practice interface with staff and input modes
- `MetronomeView.swift`: Metronome interface
- `OptionsView.swift`: Game configuration
- `LearnView.swift`: Educational reference screens
- `SettingsTabView.swift`: App settings

### Components (`jisho/Views/Components/`)
- `StaffView.swift`: Musical staff with clef and notes
- `PianoKeyboardView.swift`: Interactive piano keyboard
- `MusicNoteButtonsView.swift`: Letter note input buttons

## Technical Details

- Uses SwiftUI for all UI components
- AVFoundation for audio synthesis
- Custom drawing for musical staff using Path/Shape
- Enharmonic equivalent checking (C# = D♭, etc.)
- Timer-based metronome with precise timing
- Color scheme: Coral red accent (#E88D8F) on dark theme

## Known Issues

- Ledger lines (for notes above/below the staff) are not rendering correctly through note heads
- Answer checking may have issues with notes on ledger lines

