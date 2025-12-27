//
//  Habit.swift
//  One Line Habit
//
//  Created by Preeti Dave on 12/26/25.
//

import Foundation
import SwiftData

/// The Habit model represents a single habit entry in the tracker.
/// Uses SwiftData for automatic persistence (iOS 17+).
@Model
final class Habit {
    /// The name/title of the habit
    var title: String
    
    /// Whether the habit has been completed today
    var isCompleted: Bool
    
    /// When the habit was created
    var dateCreated: Date
    
    /// The order in the list (for potential sorting)
    var sortOrder: Int
    
    /// All completions for this habit (for history tracking)
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion] = []
    
    init(title: String, isCompleted: Bool = false, dateCreated: Date = Date(), sortOrder: Int = 0) {
        self.title = title
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.sortOrder = sortOrder
    }
    
    // MARK: - Streak Calculations
    
    /// Current streak (consecutive days completed)
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort completions by date descending
        let sortedDates = completions
            .map { calendar.startOfDay(for: $0.completedDate) }
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var streak = 0
        var checkDate = today
        
        // If not completed today, start checking from yesterday
        if !sortedDates.contains(today) {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if !sortedDates.contains(yesterday) {
                return 0 // Streak is broken
            }
            checkDate = yesterday
        }
        
        // Count consecutive days
        while sortedDates.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        return streak
    }
    
    /// Longest streak ever achieved
    var longestStreak: Int {
        let calendar = Calendar.current
        let sortedDates = completions
            .map { calendar.startOfDay(for: $0.completedDate) }
            .sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var longest = 1
        var current = 1
        
        for i in 1..<sortedDates.count {
            let daysDiff = calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            
            if daysDiff == 1 {
                current += 1
                longest = max(longest, current)
            } else if daysDiff > 1 {
                current = 1
            }
            // daysDiff == 0 means same day, skip
        }
        
        return longest
    }
    
    /// Total number of times this habit was completed
    var totalCompletions: Int {
        completions.count
    }
    
    /// Check if habit was completed on a specific date
    func wasCompleted(on date: Date) -> Bool {
        let targetDate = Calendar.current.startOfDay(for: date)
        return completions.contains { Calendar.current.isDate($0.completedDate, inSameDayAs: targetDate) }
    }
    
    /// Mark habit as completed for today (adds to history)
    func markCompleted() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Don't add duplicate completion for today
        if !wasCompleted(on: today) {
            let completion = HabitCompletion(completedDate: today, habit: self)
            completions.append(completion)
        }
        isCompleted = true
    }
    
    /// Mark habit as not completed for today (removes from today's history)
    func markUncompleted() {
        let today = Calendar.current.startOfDay(for: Date())
        completions.removeAll { Calendar.current.isDate($0.completedDate, inSameDayAs: today) }
        isCompleted = false
    }
    
    /// Toggle completion status
    func toggleCompletion() {
        if isCompleted {
            markUncompleted()
        } else {
            markCompleted()
        }
    }
}
