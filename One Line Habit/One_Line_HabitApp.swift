//
//  One_Line_HabitApp.swift
//  One Line Habit
//
//  Created by Preeti Dave on 12/26/25.
//

import SwiftUI
import SwiftData

/// The main entry point for the One Line Habit app.
/// Sets up the SwiftData model container for persistence.
@main
struct One_Line_HabitApp: App {
    
    /// The shared model container that persists Habit and HabitCompletion data to disk.
    /// This container is automatically passed to all views via the environment.
    var sharedModelContainer: ModelContainer = {
        // Define the schema with both Habit and HabitCompletion models
        let schema = Schema([
            Habit.self,
            HabitCompletion.self,
        ])
        
        // Configure the model to persist data (not in-memory only)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Inject the model container into the environment
        // This makes @Query and @Environment(\.modelContext) work in child views
        .modelContainer(sharedModelContainer)
    }
}
