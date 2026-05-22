// Views/MainTabView.swift
// TazaAua – Root tab bar (4 tabs matching Figma)

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home    = "H"
        case search  = "S"
        case map     = "M"
        case profile = "P"

        var label: String {
            switch self {
            case .home:    return "Home"
            case .search:  return "Search"
            case .map:     return "Map"
            case .profile: return "Profile"
            }
        }

        var systemImage: String {
            switch self {
            case .home:    return "house.fill"
            case .search:  return "magnifyingglass"
            case .map:     return "map.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                case .search:
                    NavigationStack {
                        LocationsListView()
                    }
                case .map:
                    NavigationStack {
                        MapView()
                    }
                case .profile:
                    NavigationStack {
                        ProfileView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
    }

    // MARK: - Tab bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedTab == tab ? Color(red: 0.25, green: 0.5, blue: 1.0) : .secondary)
                        Text(tab.label)
                            .font(.caption2)
                            .foregroundStyle(selectedTab == tab ? Color(red: 0.25, green: 0.5, blue: 1.0) : .secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.bottom, 28)
        .padding(.top, 10)
        .background(
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Rectangle()
                    .fill(Color(red: 0.08, green: 0.09, blue: 0.12).opacity(0.85))
            }
            .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1),
            alignment: .top
        )
    }
}

#Preview {
    MainTabView()
        .environment(ProfileViewModel())
}
