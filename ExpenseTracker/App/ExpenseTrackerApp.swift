//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Jarvish on 11/03/26.
//

import Firebase
import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @StateObject private var authVM: AuthViewModel

    init() {
        FirebaseApp.configure()
        _authVM = StateObject(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}
