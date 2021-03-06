//
//  EnglishDictionaryConstants.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/25.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation

extension EnglishDictionaryClient {
    struct Constants {
        static let PARAM = ":word"
        static let BASE_URL = "http://api.wordnik.com:80/v4/word.json/\(PARAM)/definitions?limit=3&includeRelated=false&sourceDictionaries=all&useCanonical=false&includeTags=false&api_key=(your key!)"
        static let METHOD = "GET"
    }
    
    struct JsonKeys {
        
        static let PartOfSpeech = "partOfSpeech"
        static let SourceDictionary = "ahd-legacy"
        static let Text = "text"
    }
}
