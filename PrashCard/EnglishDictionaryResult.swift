//
//  EnglishDictionaryResponse.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/25.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation

struct EnglishDictionaryResult {
    
    var partOfSpeech = ""
    var sourceDictionary = ""
    var text = ""
    
    init() {}
    init(dictionary: [String: AnyObject]){
        if let pos = dictionary[EnglishDictionaryClient.JsonKeys.PartOfSpeech] as? String {
             partOfSpeech = pos
        }
        if let sdict = dictionary[EnglishDictionaryClient.JsonKeys.SourceDictionary] as? String {
            sourceDictionary = sdict
        }
        if let txt = dictionary[EnglishDictionaryClient.JsonKeys.Text] as? String {
            text = txt
        }
    }
    
    
    static func meanings(parsedJson: [[String: AnyObject]]) -> [EnglishDictionaryResult]{
        var results = [EnglishDictionaryResult]()
        for child in parsedJson {
            results.append(EnglishDictionaryResult(dictionary: child))
        }
        return results
    }
    
    static func getResultString(array: [EnglishDictionaryResult]) -> String {
        var result = ""
        for item in array {
            result += "(\(item.partOfSpeech)) \(item.text)"
            if item.sourceDictionary != "" {
                result += result + "-> source dictionary: \(item.sourceDictionary)"
            }
            result += "\n\n"
        }
        return result
    }
}
