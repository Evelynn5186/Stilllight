import SwiftUI

struct AccountView: View {
    @Environment(\.dismiss) private var dismiss

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    Text("Profile")
                        .font(.custom("Baskerville", size: 24))
                        .foregroundColor(themeBrown)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                        .padding(.bottom, 24)

                    // Profile cards
                    VStack(spacing: 16) {
                        // Username
                        ProfileCard(
                            title: "Username",
                            subtitle: "demo-user",
                            icon: "paintbrush",
                            action: {}
                        )

                        // Email
                        ProfileCard(
                            title: "Email",
                            subtitle: "demo-user@gmail.com",
                            icon: "paintbrush",
                            action: {}
                        )

                        // Password
                        ProfileCardPassword(action: {})

                        // Sign Out
                        ProfileCard(
                            title: "Sign Out?",
                            subtitle: "You'll be signed out of this account.",
                            icon: "face.dashed",
                            action: {}
                        )
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                        .frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeBrown)
                }
            }
        }
    }
}

// MARK: - Profile Card

struct ProfileCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Urbanist", size: 16).weight(.bold))
                        .foregroundColor(themeBrown)

                    Text(subtitle)
                        .font(.custom("Urbanist", size: 14).weight(.medium))
                        .foregroundColor(grey)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(themeBrown.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.03), radius: 4, x: 0, y: 4)
                    .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.02), radius: 8, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Card (Password with eye icon)

struct ProfileCardPassword: View {
    let action: () -> Void

    @State private var showPassword = false

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Password")
                            .font(.custom("Urbanist", size: 16).weight(.bold))
                            .foregroundColor(themeBrown)

                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye" : "eye.slash")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeBrown.opacity(0.5))
                        }
                    }

                    Text(showPassword ? "password" : "*******")
                        .font(.custom("Urbanist", size: 14).weight(.medium))
                        .foregroundColor(grey)
                }

                Spacer()

                Image(systemName: "paintbrush")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(themeBrown.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.03), radius: 4, x: 0, y: 4)
                    .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.02), radius: 8, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
}
