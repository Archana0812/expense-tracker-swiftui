//
//  LoginView.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Expense Tracker")
                .font(.largeTitle)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = authVM.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Login") {
                Task { await authVM.login(email: email, password: password) }
            }
            .disabled(authVM.isLoading)

            Button("Signup") {
                Task { await authVM.signup(email: email, password: password) }
            }
            .disabled(authVM.isLoading)
        }
        .padding()
    }
}
