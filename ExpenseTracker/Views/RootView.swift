//
//  RootView.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import Foundation
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        if authVM.user == nil {
            LoginView()
        } else {
            DashboardView()
        }
    }
}
