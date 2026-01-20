//
//  PracticeListView.swift
//  StudyChinese
//

import SwiftUI

struct PracticeListView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List(dataManager.wordSets) { wordSet in
                NavigationLink(destination: PracticeView(wordSet: wordSet)) {
                    VStack(alignment: .leading) {
                        Text(wordSet.name)
                            .font(.headline)
                        Text("\(wordSet.words.count) 个词")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("选择练习")
        }
    }
}
