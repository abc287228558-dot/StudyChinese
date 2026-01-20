//
//  WordSetListView.swift
//  StudyChinese
//

import SwiftUI

struct WordSetListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingImagePicker = false
    @State private var showingCreateSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.wordSets) { wordSet in
                    NavigationLink(destination: WordSetDetailView(wordSet: wordSet)) {
                        VStack(alignment: .leading) {
                            Text(wordSet.name)
                                .font(.headline)
                            Text("\(wordSet.words.count) 个词")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteWordSet)
            }
            .navigationTitle("词汇集")
            .toolbar {
                Button(action: { showingImagePicker = true }) {
                    Image(systemName: "camera")
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(isPresented: $showingImagePicker)
            }
        }
    }
    
    private func deleteWordSet(at offsets: IndexSet) {
        offsets.forEach { index in
            dataManager.deleteWordSet(dataManager.wordSets[index])
        }
    }
}
