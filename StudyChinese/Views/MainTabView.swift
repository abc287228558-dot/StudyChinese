//
//  MainTabView.swift
//  StudyChinese
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            WordSetListView()
                .tabItem {
                    Label("录入", systemImage: "square.and.pencil")
                }
            
            PracticeListView()
                .tabItem {
                    Label("练习", systemImage: "pencil.and.outline")
                }
            
            RecordsView()
                .tabItem {
                    Label("记录", systemImage: "chart.bar")
                }
        }
        .environmentObject(dataManager)
    }
}
