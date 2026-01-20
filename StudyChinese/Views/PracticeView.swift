//
//  PracticeView.swift
//  StudyChinese
//

import SwiftUI
import PencilKit

struct PracticeView: View {
    let wordSet: WordSet
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var canvasViews: [String: PKCanvasView] = [:]
    @State private var wrongWords: [String] = []
    @State private var attempts = 0
    @State private var showingResult = false
    @State private var isCompleted = false

    init(wordSet: WordSet) {
        self.wordSet = wordSet
        var initialCanvasViews: [String: PKCanvasView] = [:]
        for word in wordSet.words {
            for (index, char) in Array(word).enumerated() {
                let key = "\(word)_\(index)_\(char)"
                let canvas = PKCanvasView()
                canvas.drawingPolicy = .pencilOnly
                canvas.tool = PKInkingTool(.pen, color: .black, width: 5)
                initialCanvasViews[key] = canvas
            }
        }
        _canvasViews = State(initialValue: initialCanvasViews)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !isCompleted {
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
                
                Button("完成") {
                    checkAllAnswers()
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
                .padding()
            } else {
                if wrongWords.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        Text("全部完成！")
                            .font(.title)
                        Text("复活次数: \(attempts)")
                            .font(.headline)
                        Button("返回") {
                            savePracticeRecord()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("错误的词汇")
                            .font(.title2)
                            .padding(.top)
                        
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(wrongWords, id: \.self) { word in
                                    HStack {
                                        Text(word)
                                            .font(.title)
                                        Text(PinyinConverter.convertToPinyinWithTone(word))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                        
                        Button("继续练习") {
                            continueWithWrongWords()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("练习: \(wordSet.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func checkAllAnswers() {
        print("🚀 开始验证所有答案...")
        wrongWords = []
        let group = DispatchGroup()
        var tempWrongWords: [String] = []
        
        for word in wordSet.words {
            group.enter()
            checkWord(word) { isCorrect in
                if !isCorrect {
                    tempWrongWords.append(word)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            wrongWords = tempWrongWords
            isCompleted = true
            print("🏁 验证完成！错误词汇: \(wrongWords.isEmpty ? "无" : wrongWords.joined(separator: ", "))")
        }
    }
    
    private func checkWord(_ word: String, completion: @escaping (Bool) -> Void) {
        let chars = Array(word)
        var recognizedChars = Array(repeating: "", count: chars.count)
        let group = DispatchGroup()

        for (index, char) in chars.enumerated() {
            let key = "\(word)_\(index)_\(char)"
            guard let canvas = canvasViews[key] else {
                print("❌ 找不到画布: \(key)")
                completion(false)
                return
            }
            
            group.enter()
            HandwritingRecognizer.recognizeText(from: canvas.drawing, expected: String(char)) { recognized in
                let recognizedChar = recognized ?? ""
                recognizedChars[index] = recognizedChar
                print("📝 字符: \(char) -> 识别为: \(recognizedChar.isEmpty ? "空" : recognizedChar)")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let recognizedWord = recognizedChars.joined()
            let isCorrect = recognizedWord == word
            print("✅ 词语: \(word) | 识别结果: \(recognizedWord.isEmpty ? "空" : recognizedWord) | \(isCorrect ? "正确" : "错误")")
            print("---")
            completion(isCorrect)
        }
    }
    
    private func continueWithWrongWords() {
        // 清空错误词汇的画布
        for word in wrongWords {
            for (index, char) in Array(word).enumerated() {
                let key = "\(word)_\(index)_\(char)"
                canvasViews[key]?.drawing = PKDrawing()
            }
        }
        
        // 创建新的词汇集只包含错误的词
        let newWordSet = WordSet(
            id: wordSet.id,
            name: wordSet.name,
            words: wrongWords,
            createdAt: wordSet.createdAt
        )
        
        wrongWords = []
        isCompleted = false
        attempts += 1
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

struct WordPracticeRow: View {
    let word: String
    @Binding var canvasViews: [String: PKCanvasView]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 显示拼音
            Text(PinyinConverter.convertToPinyinWithTone(word))
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.gray)
            
            // 每个字一个田字格
            HStack(spacing: 15) {
                ForEach(Array(word.enumerated()), id: \.offset) { index, char in
                    VStack(spacing: 5) {
                        let key = "\(word)_\(index)_\(char)"
                        ZStack {
                            TianZiGeBackground()
                            CanvasViewWrapper(canvasView: getOrCreateCanvas(for: key))
                        }
                        .frame(width: 120, height: 120)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func getOrCreateCanvas(for key: String) -> PKCanvasView {
        if let existing = canvasViews[key] {
            return existing
        }
        let newCanvas = PKCanvasView()
        newCanvas.drawingPolicy = .pencilOnly
        newCanvas.tool = PKInkingTool(.pen, color: .black, width: 5)
        DispatchQueue.main.async {
            canvasViews[key] = newCanvas
        }
        return newCanvas
    }
}

struct CanvasViewWrapper: UIViewRepresentable {
    let canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = .clear
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
