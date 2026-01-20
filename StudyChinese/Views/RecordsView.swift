//
//  RecordsView.swift
//  StudyChinese
//

import SwiftUI

struct RecordsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List(dataManager.practiceRecords.sorted(by: { $0.completedAt > $1.completedAt })) { record in
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.wordSetName)
                        .font(.headline)
                    
                    HStack {
                        Label(formatDate(record.completedAt), systemImage: "clock")
                        Spacer()
                        Label("复活 \(record.attempts) 次", systemImage: "arrow.clockwise")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("练习记录")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
