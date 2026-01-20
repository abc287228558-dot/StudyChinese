//
//  WordEditView.swift
//  StudyChinese
//

import SwiftUI

struct WordEditView: View {
    @Binding var words: [String]
    @Binding var isPresented: Bool
    @EnvironmentObject var dataManager: DataManager
    @State private var setName = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("词汇集名称", text: $setName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                List {
                    ForEach(words, id: \.self) { word in
                        Text(word)
                    }
                    .onDelete(perform: deleteWord)
                }
            }
            .navigationTitle("编辑词汇")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveWordSet()
                    }
                    .disabled(setName.isEmpty || words.isEmpty)
                }
            }
            .alert("保存成功", isPresented: $showingAlert) {
                Button("确定") {
                    isPresented = false
                }
            }
        }
    }
    
    private func deleteWord(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
    }
    
    private func saveWordSet() {
        let wordSet = WordSet(name: setName, words: words)
        dataManager.saveWordSet(wordSet)
        showingAlert = true
    }
}
