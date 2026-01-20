//
//  WordSetDetailView.swift
//  StudyChinese
//

import SwiftUI

struct WordSetDetailView: View {
    let wordSet: WordSet
    
    var body: some View {
        List(wordSet.words, id: \.self) { word in
            HStack {
                Text(word)
                    .font(.title2)
                Spacer()
                Text(PinyinConverter.convertToPinyinWithTone(word))
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle(wordSet.name)
    }
}
