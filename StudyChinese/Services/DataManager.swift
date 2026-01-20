//
//  DataManager.swift
//  StudyChinese
//

import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var wordSets: [WordSet] = []
    @Published var practiceRecords: [PracticeRecord] = []
    
    private let wordSetsKey = "wordSets"
    private let recordsKey = "practiceRecords"
    
    init() {
        loadData()
    }
    
    func saveWordSet(_ wordSet: WordSet) {
        if let index = wordSets.firstIndex(where: { $0.id == wordSet.id }) {
            wordSets[index] = wordSet
        } else {
            wordSets.append(wordSet)
        }
        saveData()
    }
    
    func deleteWordSet(_ wordSet: WordSet) {
        wordSets.removeAll { $0.id == wordSet.id }
        saveData()
    }
    
    func savePracticeRecord(_ record: PracticeRecord) {
        practiceRecords.append(record)
        saveRecords()
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(wordSets) {
            UserDefaults.standard.set(encoded, forKey: wordSetsKey)
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(practiceRecords) {
            UserDefaults.standard.set(encoded, forKey: recordsKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: wordSetsKey),
           let decoded = try? JSONDecoder().decode([WordSet].self, from: data) {
            wordSets = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([PracticeRecord].self, from: data) {
            practiceRecords = decoded
        }
    }
}
