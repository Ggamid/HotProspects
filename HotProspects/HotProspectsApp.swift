//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Gamıd Khalıdov on 27.06.2024.
//

import SwiftUI

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
        // создать modelContainder для всего приложения, который будет
        // хранить в себе объекты заданного класса.
    }
}
