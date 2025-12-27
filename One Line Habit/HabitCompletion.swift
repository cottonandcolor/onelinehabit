//
//  HabitCompletion.swift
//  One Line Habit
//
//  Created by Preeti Dave on 12/26/25.
//

import Foundation
import SwiftData

/// Tracks individual habit completions by date.
/// Each completion represents a habit being marked done on a specific day.
@Model
final class HabitCompletion {
    /// The date when the habit was completed (normalized to start of day)
    var completedDate: Date
    
    /// Reference to the habit that was completed
    var habit: Habit?
    
    init(completedDate: Date = Date(), habit: Habit? = nil) {
        // Normalize to start of day for consistent date comparisons
        self.completedDate = Calendar.current.startOfDay(for: completedDate)
        self.habit = habit
    }
}

// MARK: - Date Helpers
extension Date {
    /// Returns the start of the day for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Check if this date is the same day as another date
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    /// Returns date string for display (e.g., "Dec 26")
    var shortDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    /// Get all dates in a month
    var daysInMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
    
    /// First day of the month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    /// Add months to date
    func addingMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self)!
    }
    
    /// Get weekday (0 = Sunday, 6 = Saturday)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self) - 1
    }
    
    /// Month and year string (e.g., "December 2025")
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
}

