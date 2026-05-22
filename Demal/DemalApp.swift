//
//  DemalApp.swift
//  Demal
//
//  Created by Alexandr Kisslitsyn on 21.05.2026.
//

import SwiftUI

@main
struct DemalApp: App {
    @State private var profileViewModel = ProfileViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(profileViewModel)
        }
    }
}
