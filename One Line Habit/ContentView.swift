//
//  ContentView.swift
//  One Line Habit
//
//  Created by Preeti Dave on 12/26/25.
//

import SwiftUI
import SwiftData

/// The main view of the Habit Tracker app.
/// Uses @Query to fetch habits from SwiftData and displays them in a beautiful list.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData @Query automatically fetches and observes Habit objects
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    
    @State private var showingAddSheet = false
    @State private var newHabitTitle = ""
    @State private var showingResetAlert = false
    @State private var showingCalendar = false
    
    #if os(iOS)
    @StateObject private var speechRecognizer = SpeechRecognizer()
    #endif
    
    // Background gradient colors
    private let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0F172A"), Color(hex: "1E1B4B")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Computed property for best current streak
    private var bestCurrentStreak: Int {
        habits.map { $0.currentStreak }.max() ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Stats
                    headerView
                    
                    // Streak Banner (if any streaks exist)
                    if bestCurrentStreak > 0 {
                        streakBanner
                    }
                    
                    if habits.isEmpty {
                        emptyStateView
                    } else {
                        habitListView
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        fabButton
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("One Line Habit")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Calendar/History Button
                        Button(action: { showingCalendar = true }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "9CA3AF"))
                        }
                        
                        // Reset Button
                        Button(action: { showingResetAlert = true }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "9CA3AF"))
                        }
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Text("One Line Habit")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .automatic) {
                    HStack(spacing: 16) {
                        Button(action: { showingCalendar = true }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "9CA3AF"))
                        }
                        
                        Button(action: { showingResetAlert = true }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "9CA3AF"))
                        }
                    }
                }
                #endif
            }
            #if os(iOS)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
        }
        .sheet(isPresented: $showingAddSheet) {
            addHabitSheet
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarView()
        }
        .alert("Reset All Habits?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetAllHabits()
            }
        } message: {
            Text("This will mark all habits as uncompleted for today. Your history is preserved!")
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Streak Banner
    private var streakBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "F59E0B"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(bestCurrentStreak) Day Streak!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Keep it going!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "9CA3AF"))
            }
            
            Spacer()
            
            Button(action: { showingCalendar = true }) {
                Text("View History")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1F2937"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "F59E0B").opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 20) {
            statsCard(
                title: "Completed",
                value: "\(habits.filter { $0.isCompleted }.count)",
                color: Color(hex: "10B981")
            )
            
            statsCard(
                title: "Remaining",
                value: "\(habits.filter { !$0.isCompleted }.count)",
                color: Color(hex: "F59E0B")
            )
            
            statsCard(
                title: "Total",
                value: "\(habits.count)",
                color: Color(hex: "6366F1")
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    private func statsCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1F2937").opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Habit List
    private var habitListView: some View {
        List {
            ForEach(habits) { habit in
                HabitRowView(
                    habit: habit,
                    onToggle: {
                        toggleHabit(habit)
                    },
                    onDelete: {
                        deleteHabit(habit)
                    }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteHabits)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80) // Space for FAB
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "1F2937"))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.badge.questionmark")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("No Habits Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Tap the + button to add your first habit")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "9CA3AF"))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - FAB Button
    private var fabButton: some View {
        Button(action: { showingAddSheet = true }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(hex: "6366F1").opacity(0.5), radius: 12, x: 0, y: 6)
                
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Add Habit Sheet
    private var addHabitSheet: some View {
        NavigationStack {
            ZStack {
                Color(hex: "111827").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Name")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "9CA3AF"))
                        
                        HStack(spacing: 12) {
                            TextField("e.g., Morning meditation", text: $newHabitTitle)
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .tint(Color(hex: "6366F1"))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "1F2937"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "374151"), lineWidth: 1)
                                        )
                                )
                                #if os(iOS)
                                .textInputAutocapitalization(.sentences)
                                #endif
                            
                            // Microphone Button (iOS only)
                            #if os(iOS)
                            Button(action: toggleRecording) {
                                ZStack {
                                    Circle()
                                        .fill(speechRecognizer.isRecording ? Color(hex: "EF4444") : Color(hex: "6366F1"))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                            #endif
                        }
                        
                        #if os(iOS)
                        // Recording status
                        if speechRecognizer.isRecording {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: "EF4444"))
                                    .frame(width: 8, height: 8)
                                
                                Text("Listening...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "EF4444"))
                            }
                            .padding(.top, 4)
                        }
                        
                        if let error = speechRecognizer.errorMessage {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "EF4444"))
                                .padding(.top, 4)
                        }
                        #endif
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("New Habit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        #if os(iOS)
                        speechRecognizer.stopRecording()
                        #endif
                        newHabitTitle = ""
                        showingAddSheet = false
                    }
                    .foregroundColor(Color(hex: "9CA3AF"))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addHabit()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "6366F1"))
                    .disabled(newHabitTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            #if os(iOS)
            .toolbarBackground(Color(hex: "111827"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onChange(of: speechRecognizer.transcript) { oldValue, newValue in
                if !newValue.isEmpty {
                    newHabitTitle = newValue
                }
            }
            #endif
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Actions
    
    #if os(iOS)
    /// Toggle voice recording on/off
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            speechRecognizer.startRecording()
        }
        triggerHaptic(.medium)
    }
    #endif
    
    /// Add a new habit to SwiftData
    private func addHabit() {
        let trimmedTitle = newHabitTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        #if os(iOS)
        speechRecognizer.stopRecording()
        #endif
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let habit = Habit(
                title: trimmedTitle,
                sortOrder: habits.count
            )
            modelContext.insert(habit)
        }
        
        newHabitTitle = ""
        showingAddSheet = false
        
        // Success haptic (iOS only)
        triggerHaptic(.success)
    }
    
    /// Toggle a habit's completion status with haptic feedback
    private func toggleHabit(_ habit: Habit) {
        // Use the new method that tracks history
        habit.toggleCompletion()
        
        // Trigger haptic feedback (iOS only)
        if habit.isCompleted {
            triggerHaptic(.success)
        } else {
            triggerHaptic(.light)
        }
    }
    
    /// Delete a habit from SwiftData
    private func deleteHabit(_ habit: Habit) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            modelContext.delete(habit)
        }
        
        // Light haptic for deletion
        triggerHaptic(.light)
    }
    
    /// Delete habits at offsets (for swipe-to-delete)
    private func deleteHabits(at offsets: IndexSet) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            for index in offsets {
                modelContext.delete(habits[index])
            }
        }
        triggerHaptic(.light)
    }
    
    /// Reset all habits to uncompleted state (for today only - history preserved)
    private func resetAllHabits() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            for habit in habits {
                habit.markUncompleted()
            }
        }
        
        // Haptic feedback
        triggerHaptic(.warning)
    }
    
    // MARK: - Haptic Feedback (iOS only)
    
    private enum HapticType {
        case light, medium, success, warning
    }
    
    private func triggerHaptic(_ type: HapticType) {
        #if os(iOS)
        switch type {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        #endif
    }
}

// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
