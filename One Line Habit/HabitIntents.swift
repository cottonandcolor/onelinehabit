//
//  HabitIntents.swift
//  One Line Habit
//
//  Created by Preeti Dave on 12/26/25.
//

import AppIntents
import SwiftData
import SwiftUI

// MARK: - Add Habit Intent
/// Siri: "Add habit [name]" or "Create a new habit called [name]"
struct AddHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Habit"
    static var description = IntentDescription("Add a new habit to track")
    
    @Parameter(title: "Habit Name")
    var habitName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add habit called \(\.$habitName)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Get the model container
        let container = try ModelContainer(for: Habit.self)
        let context = container.mainContext
        
        // Count existing habits for sort order
        let descriptor = FetchDescriptor<Habit>()
        let existingHabits = try context.fetch(descriptor)
        
        // Create new habit
        let habit = Habit(
            title: habitName,
            sortOrder: existingHabits.count
        )
        context.insert(habit)
        try context.save()
        
        return .result(dialog: "Added '\(habitName)' to your habits!")
    }
}

// MARK: - Complete Habit Intent
/// Siri: "Complete habit [name]" or "Mark [name] as done"
struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Mark a habit as completed")
    
    @Parameter(title: "Habit Name")
    var habitName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Complete habit \(\.$habitName)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Habit.self)
        let context = container.mainContext
        
        // Find the habit
        let descriptor = FetchDescriptor<Habit>()
        let habits = try context.fetch(descriptor)
        
        if let habit = habits.first(where: { $0.title.lowercased().contains(habitName.lowercased()) }) {
            habit.isCompleted = true
            try context.save()
            return .result(dialog: "Marked '\(habit.title)' as complete! Great job! 🎉")
        } else {
            return .result(dialog: "Couldn't find a habit called '\(habitName)'")
        }
    }
}

// MARK: - Reset All Habits Intent
/// Siri: "Reset my habits" or "Start fresh with habits"
struct ResetHabitsIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset All Habits"
    static var description = IntentDescription("Reset all habits to uncompleted")
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Habit.self)
        let context = container.mainContext
        
        let descriptor = FetchDescriptor<Habit>()
        let habits = try context.fetch(descriptor)
        
        for habit in habits {
            habit.isCompleted = false
        }
        try context.save()
        
        return .result(dialog: "All habits have been reset. Ready for a new day!")
    }
}

// MARK: - Check Progress Intent
/// Siri: "How are my habits?" or "Check my habit progress"
struct CheckProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Habit Progress"
    static var description = IntentDescription("Check how many habits you've completed today")
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Habit.self)
        let context = container.mainContext
        
        let descriptor = FetchDescriptor<Habit>()
        let habits = try context.fetch(descriptor)
        
        let completed = habits.filter { $0.isCompleted }.count
        let total = habits.count
        
        if total == 0 {
            return .result(dialog: "You don't have any habits yet. Add some to get started!")
        } else if completed == total {
            return .result(dialog: "Amazing! You've completed all \(total) habits today! 🌟")
        } else {
            return .result(dialog: "You've completed \(completed) out of \(total) habits. Keep going!")
        }
    }
}

// MARK: - App Shortcuts Provider
/// Makes shortcuts available in the Shortcuts app and Siri
struct HabitShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddHabitIntent(),
            phrases: [
                "Add habit in \(.applicationName)",
                "Create a habit in \(.applicationName)",
                "New habit in \(.applicationName)"
            ],
            shortTitle: "Add Habit",
            systemImageName: "plus.circle"
        )
        
        AppShortcut(
            intent: CompleteHabitIntent(),
            phrases: [
                "Complete habit in \(.applicationName)",
                "Mark habit done in \(.applicationName)",
                "Finish habit in \(.applicationName)"
            ],
            shortTitle: "Complete Habit",
            systemImageName: "checkmark.circle"
        )
        
        AppShortcut(
            intent: ResetHabitsIntent(),
            phrases: [
                "Reset habits in \(.applicationName)",
                "Start fresh in \(.applicationName)",
                "New day in \(.applicationName)"
            ],
            shortTitle: "Reset Habits",
            systemImageName: "arrow.counterclockwise"
        )
        
        AppShortcut(
            intent: CheckProgressIntent(),
            phrases: [
                "Check habits in \(.applicationName)",
                "How are my habits in \(.applicationName)",
                "Habit progress in \(.applicationName)"
            ],
            shortTitle: "Check Progress",
            systemImageName: "chart.bar"
        )
    }
}

