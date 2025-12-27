//
//  CalendarView.swift
//  One Line Habit
//
//  Created by Preeti Dave on 12/26/25.
//

import SwiftUI
import SwiftData

/// A calendar view showing habit completion history
struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    
    @State private var selectedMonth: Date = Date()
    @State private var selectedHabit: Habit?
    
    private let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E1B4B")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Habit Picker
                        habitPicker
                        
                        // Stats Cards
                        if let habit = selectedHabit {
                            statsSection(for: habit)
                        } else {
                            overallStatsSection
                        }
                        
                        // Calendar
                        calendarSection
                        
                        // Legend
                        legendView
                    }
                    .padding()
                }
            }
            .navigationTitle("History")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "6366F1"))
                }
            }
            #if os(iOS)
            .toolbarBackground(Color(hex: "0F172A"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Habit Picker
    private var habitPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All habits option
                Button(action: { selectedHabit = nil }) {
                    Text("All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedHabit == nil ? .white : Color(hex: "9CA3AF"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedHabit == nil ? Color(hex: "6366F1") : Color(hex: "1F2937"))
                        )
                }
                
                ForEach(habits) { habit in
                    Button(action: { selectedHabit = habit }) {
                        Text(habit.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedHabit?.id == habit.id ? .white : Color(hex: "9CA3AF"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedHabit?.id == habit.id ? Color(hex: "6366F1") : Color(hex: "1F2937"))
                            )
                    }
                    .lineLimit(1)
                }
            }
        }
    }
    
    // MARK: - Stats Section
    private func statsSection(for habit: Habit) -> some View {
        HStack(spacing: 16) {
            statCard(
                title: "Current Streak",
                value: "\(habit.currentStreak)",
                icon: "flame.fill",
                color: Color(hex: "F59E0B")
            )
            
            statCard(
                title: "Best Streak",
                value: "\(habit.longestStreak)",
                icon: "trophy.fill",
                color: Color(hex: "10B981")
            )
            
            statCard(
                title: "Total",
                value: "\(habit.totalCompletions)",
                icon: "checkmark.circle.fill",
                color: Color(hex: "6366F1")
            )
        }
    }
    
    private var overallStatsSection: some View {
        let totalCompletions = habits.reduce(0) { $0 + $1.totalCompletions }
        let avgStreak = habits.isEmpty ? 0 : habits.reduce(0) { $0 + $1.currentStreak } / habits.count
        let bestStreak = habits.map { $0.longestStreak }.max() ?? 0
        
        return HStack(spacing: 16) {
            statCard(
                title: "Avg Streak",
                value: "\(avgStreak)",
                icon: "flame.fill",
                color: Color(hex: "F59E0B")
            )
            
            statCard(
                title: "Best Streak",
                value: "\(bestStreak)",
                icon: "trophy.fill",
                color: Color(hex: "10B981")
            )
            
            statCard(
                title: "Total Done",
                value: "\(totalCompletions)",
                icon: "checkmark.circle.fill",
                color: Color(hex: "6366F1")
            )
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1F2937"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: { selectedMonth = selectedMonth.addingMonths(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                }
                
                Spacer()
                
                Text(selectedMonth.monthYearString)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { selectedMonth = selectedMonth.addingMonths(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "6366F1"))
                }
            }
            .padding(.horizontal)
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "9CA3AF"))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            let days = selectedMonth.daysInMonth
            let firstWeekday = days.first?.weekday ?? 0
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Empty cells for padding
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear
                        .frame(height: 40)
                }
                
                // Day cells
                ForEach(days, id: \.self) { date in
                    dayCell(for: date)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1F2937").opacity(0.5))
        )
    }
    
    private func dayCell(for date: Date) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        let isFuture = date > Date()
        let completionStatus = getCompletionStatus(for: date)
        
        return VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                .foregroundColor(isFuture ? Color(hex: "4B5563") : .white)
            
            // Completion indicator
            Circle()
                .fill(completionColor(for: completionStatus))
                .frame(width: 8, height: 8)
                .opacity(isFuture ? 0 : 1)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color(hex: "6366F1").opacity(0.3) : Color.clear)
        )
    }
    
    private enum CompletionStatus {
        case none, partial, complete
    }
    
    private func getCompletionStatus(for date: Date) -> CompletionStatus {
        if let habit = selectedHabit {
            return habit.wasCompleted(on: date) ? .complete : .none
        } else {
            let completedCount = habits.filter { $0.wasCompleted(on: date) }.count
            if completedCount == 0 { return .none }
            if completedCount == habits.count { return .complete }
            return .partial
        }
    }
    
    private func completionColor(for status: CompletionStatus) -> Color {
        switch status {
        case .none:
            return Color(hex: "374151")
        case .partial:
            return Color(hex: "F59E0B")
        case .complete:
            return Color(hex: "10B981")
        }
    }
    
    // MARK: - Legend
    private var legendView: some View {
        HStack(spacing: 24) {
            legendItem(color: Color(hex: "10B981"), text: "All Complete")
            legendItem(color: Color(hex: "F59E0B"), text: "Partial")
            legendItem(color: Color(hex: "374151"), text: "None")
        }
        .padding(.top, 8)
    }
    
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "9CA3AF"))
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}

