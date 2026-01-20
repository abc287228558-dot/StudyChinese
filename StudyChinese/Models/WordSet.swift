//
//  WordSet.swift
//  StudyChinese
//

import Foundation

struct WordSet: Identifiable, Codable {
    let id: UUID
    var name: String
    var words: [String]
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, words: [String], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.words = words
        self.createdAt = createdAt
    }
}

struct PracticeRecord: Identifiable, Codable {
    let id: UUID
    var wordSetId: UUID
    var wordSetName: String
    var completedAt: Date
    var attempts: Int // 复活次数
    
    init(id: UUID = UUID(), wordSetId: UUID, wordSetName: String, completedAt: Date = Date(), attempts: Int) {
        self.id = id
        self.wordSetId = wordSetId
        self.wordSetName = wordSetName
        self.completedAt = completedAt
        self.attempts = attempts
    }
}
