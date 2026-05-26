//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileHeader()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Account Settings")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)

                    VStack(spacing: 0) {
                        SettingsActionRow(
                            title: "Edit Profile",
                            systemImage: "person.crop.circle",
                            action: {}
                        )

                        SettingsDivider()

                        NavigationLink {
                            BudgetView()
                        } label: {
                            SettingsRowContent(
                                title: "Budget Settings",
                                systemImage: "gearshape.2"
                            )
                        }
                        .buttonStyle(.plain)

                        SettingsDivider()

                        SettingsActionRow(
                            title: "Currency",
                            systemImage: "indianrupeesign.circle",
                            trailing: {
                                HStack(spacing: 16) {
                                    Text("₹")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color(.systemGray))

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 21, weight: .medium))
                                        .foregroundStyle(Color.settingsBlue)
                                }
                            },
                            action: {}
                        )

                        SettingsDivider()

                        SettingsActionRow(
                            title: "Logout",
                            systemImage: "arrow.right.circle",
                            action: authVM.logout
                        )
                    }
                    .background(Color.white)
                }

                Spacer(minLength: 0)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ProfileHeader: View {
    var body: some View {
        VStack {
            ProfilePhoto()
                .frame(width: 132, height: 132)
                .padding(.top, 52)
                .padding(.bottom, 74)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProfilePhoto: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.04, green: 0.10, blue: 0.12),
                            Color(red: 0.09, green: 0.19, blue: 0.22),
                            Color(red: 0.01, green: 0.04, blue: 0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.12 : 0.07))
                    .frame(width: 2, height: CGFloat(58 + index * 8))
                    .offset(x: CGFloat(index - 4) * 13, y: -32)
            }

            Path { path in
                path.move(to: CGPoint(x: 66, y: 75))
                path.addLine(to: CGPoint(x: 40, y: 132))
                path.addLine(to: CGPoint(x: 92, y: 132))
                path.closeSubpath()
            }
            .fill(Color.black.opacity(0.34))

            Path { path in
                path.move(to: CGPoint(x: 66, y: 76))
                path.addLine(to: CGPoint(x: 66, y: 132))
            }
            .stroke(Color(red: 0.92, green: 0.78, blue: 0.34), lineWidth: 2)

            VStack(spacing: 0) {
                Circle()
                    .fill(Color(red: 1.0, green: 0.73, blue: 0.20))
                    .frame(width: 18, height: 18)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.96, green: 0.65, blue: 0.18))
                    .frame(width: 23, height: 32)
            }
            .offset(y: 17)
        }
        .clipShape(Circle())
    }
}

private struct SettingsActionRow<Trailing: View>: View {
    let title: String
    let systemImage: String
    let trailing: () -> Trailing
    let action: () -> Void

    init(
        title: String,
        systemImage: String,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() },
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.trailing = trailing
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            SettingsRowContent(
                title: title,
                systemImage: systemImage,
                trailing: trailing
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsRowContent<Trailing: View>: View {
    let title: String
    let systemImage: String
    let trailing: () -> Trailing

    init(
        title: String,
        systemImage: String,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: systemImage)
                .font(.system(size: 29, weight: .regular))
                .foregroundStyle(Color(.label))
                .frame(width: 32, height: 44)

            Text(title)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(Color(.label))

            Spacer(minLength: 16)

            trailing()
        }
        .frame(height: 64)
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
        .background(Color.white)
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 74)
    }
}

private extension Color {
    static var settingsBlue: Color {
        Color(red: 0.12, green: 0.48, blue: 0.76)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
