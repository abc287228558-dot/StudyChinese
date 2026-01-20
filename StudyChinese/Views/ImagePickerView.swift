//
//  ImagePickerView.swift
//  StudyChinese
//

import SwiftUI
import PhotosUI
import Vision

struct ImagePickerView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var recognizedWords: [String] = []
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                    
                    if recognizedWords.isEmpty {
                        ProgressView("识别中...")
                    } else {
                        Button("编辑词汇") {
                            showingEditView = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 60))
                            Text("选择照片")
                        }
                    }
                }
            }
            .navigationTitle("拍照识别")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        recognizeText(in: image)
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                WordEditView(words: $recognizedWords, isPresented: $isPresented)
            }
        }
    }
    
    private func recognizeText(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                self.recognizedWords = extractChineseWords(from: recognizedStrings)
            }
        }
        
        request.recognitionLanguages = ["zh-Hans", "zh-Hant"]
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    private func extractChineseWords(from strings: [String]) -> [String] {
        var words: [String] = []
        let chineseCharacterSet = CharacterSet(charactersIn: "\u{4E00}"..."\u{9FFF}")
        
        for string in strings {
            var currentWord = ""
            
            for char in string {
                let isChinese = char.unicodeScalars.allSatisfy { chineseCharacterSet.contains($0) }
                
                if isChinese {
                    currentWord.append(char)
                } else {
                    // 遇到非汉字，保存当前词
                    if !currentWord.isEmpty {
                        words.append(currentWord)
                        currentWord = ""
                    }
                }
            }
            
            // 保存最后一个词
            if !currentWord.isEmpty {
                words.append(currentWord)
            }
        }
        
        // 去重并排序
        return Array(Set(words)).sorted()
    }
}
