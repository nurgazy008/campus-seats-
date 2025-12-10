//
//  ContentView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            EventsListView()
                .tabItem {
                    Label("События", systemImage: "calendar")
                }
            
            MyTicketsView()
                .tabItem {
                    Label("Мои билеты", systemImage: "ticket.fill")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
