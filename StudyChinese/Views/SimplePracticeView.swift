//
//  SimplePracticeView.swift
//  StudyChinese
//  简化版练习 - 用户自己判断对错
//

import SwiftUI
import PencilKit

struct SimplePracticeView: View {
    let wordSet: WordSet
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var canvasViews: [String: PKCanvasView] = [:]
    @State private var showingReview = false
    @State private var attempts = 0
    
    var body: some View {
        VStack(spacing: 0) {
            if !showingReview {
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(wordSet.words, id: \.self) { word in
                            WordPracticeRow(
                                word: word,
                                canvasViews: $canvasViews
                            )
                        }
                    }
                    .padding()
                }
                
                Button("完成练习") {
                    showingReview = true
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
                .padding()
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    Text("练习完成！")
                        .font(.title)
                    Text("本次练习: \(wordSet.words.count) 个词")
                        .font(.headline)
                    Button("返回") {
                        savePracticeRecord()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("练习: \(wordSet.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            initializeCanvasViews()
        }
    }
    
    private func initializeCanvasViews() {
        for word in wordSet.words {
            for (index, char) in Array(word).enumerated() {
                let key = "\(word)_\(index)_\(char)"
                let canvas = PKCanvasView()
                canvas.drawingPolicy = .pencilOnly
                canvas.tool = PKInkingTool(.pen, color: .black, width: 5)
                canvasViews[key] = canvas
            }
        }
    }
    
    private func savePracticeRecord() {
        let record = PracticeRecord(
            wordSetId: wordSet.id,
            wordSetName: wordSet.name,
            attempts: attempts
        )
        dataManager.savePracticeRecord(record)
    }
}
