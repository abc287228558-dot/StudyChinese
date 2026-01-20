//
//  PinyinConverter.swift
//  StudyChinese
//

import Foundation

class PinyinConverter {
    static func convertToPinyin(_ text: String) -> String {
        let mutableString = NSMutableString(string: text) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        return mutableString as String
    }
    
    static func convertToPinyinWithTone(_ text: String) -> String {
        let mutableString = NSMutableString(string: text) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        return mutableString as String
    }
}
