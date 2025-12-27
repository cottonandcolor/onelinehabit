//
//  HabitRowView.swift
//  One Line Habit
//
//  Created by Preeti Dave on 12/26/25.
//

import SwiftUI
import SwiftData
import Foundation

/// A beautifully designed row view for displaying a single habit.
/// Features smooth animations and satisfying micro-interactions.
struct HabitRowView: View {
    let habit: Habit
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    @State private var showCompletionEffect = false
    @State private var particleOpacity: Double = 0
    
    // Custom color scheme - dark mode ready
    private let completedGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion Circle with Animation
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        habit.isCompleted ? Color(hex: "6366F1") : Color(hex: "4B5563"),
                        lineWidth: 2
                    )
                    .frame(width: 28, height: 28)
                
                // Filled circle when completed
                if habit.isCompleted {
                    Circle()
                        .fill(completedGradient)
                        .frame(width: 28, height: 28)
                        .transition(.scale.combined(with: .opacity))
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Particle effect on completion
                if showCompletionEffect {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color(hex: "8B5CF6"))
                            .frame(width: 6, height: 6)
                            .offset(particleOffset(for: index))
                            .opacity(particleOpacity)
                    }
                }
            }
            .contentShape(Circle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if !habit.isCompleted {
                        triggerCompletionEffect()
                    }
                    onToggle()
                }
            }
            
            // Habit Title
            Text(habit.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(habit.isCompleted ? Color(hex: "9CA3AF") : .white)
                .strikethrough(habit.isCompleted, color: Color(hex: "6366F1"))
                .animation(.easeInOut(duration: 0.2), value: habit.isCompleted)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(habit.isCompleted ? Color(hex: "1F2937").opacity(0.6) : Color(hex: "1F2937"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            habit.isCompleted ? Color(hex: "6366F1").opacity(0.3) : Color(hex: "374151"),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private func particleOffset(for index: Int) -> CGSize {
        let angle = Double(index) * .pi / 4
        let distance: Double = showCompletionEffect ? 24 : 0
        return CGSize(
            width: Foundation.cos(angle) * distance,
            height: Foundation.sin(angle) * distance
        )
    }
    
    private func triggerCompletionEffect() {
        showCompletionEffect = true
        particleOpacity = 1
        
        withAnimation(.easeOut(duration: 0.4)) {
            particleOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCompletionEffect = false
        }
    }
}

// MARK: - Color Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ZStack {
        Color(hex: "111827").ignoresSafeArea()
        
        VStack(spacing: 12) {
            HabitRowView(
                habit: Habit(title: "Morning meditation"),
                onToggle: {},
                onDelete: {}
            )
            
            HabitRowView(
                habit: {
                    let h = Habit(title: "Read for 30 minutes")
                    h.isCompleted = true
                    return h
                }(),
                onToggle: {},
                onDelete: {}
            )
        }
        .padding()
    }
}
