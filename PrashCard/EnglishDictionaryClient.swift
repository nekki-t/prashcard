//
//  EnglishDictionaryClient.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/25.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
class EnglishDictionaryClient: NSObject {
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    var session: NSURLSession
    var apiResult: [EnglishDictionaryResult]?
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Init
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override init(){
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Instance funcs
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func getDefinitionOftheWord(word: String, completionHandler: (success: Bool, error: String?) -> Void) {
        let urlString = EnglishDictionaryClient.Constants.BASE_URL.stringByReplacingOccurrencesOfString(EnglishDictionaryClient.Constants.PARAM, withString: word)
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = EnglishDictionaryClient.Constants.METHOD
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            print(error)
            guard error == nil else {
                completionHandler(success: false, error: "Access to API request failed!")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(success: false, error: "Invalid response! Status Code: \(response.statusCode)")
                } else if let response = response {
                    completionHandler(success: false, error: "Invalid response! Response: \(response)")
                } else {
                    completionHandler(success: false, error: "Invalid response!")
                }
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, error: "No data was returned!")
                return
            }
            
            EnglishDictionaryClient.parseJSONwithCompletionHandler(data) {
                JSONResult, error in
                print(JSONResult)
                
                guard let results = JSONResult as? [[String: AnyObject]] else {
                    completionHandler(success: false, error: "Invalid Json Data: \(JSONResult)")
                    return
                }
                
                self.apiResult = EnglishDictionaryResult.meanings(results)
                completionHandler(success: true, error: nil)
                return
            }
            
        }
        task.resume()
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Class funcs
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: Singleton
    class func sharedInstance() -> EnglishDictionaryClient {
        struct Singleton {
            static var sharedInstance = EnglishDictionaryClient()
        }
        return Singleton.sharedInstance
    }
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONwithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONwithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
    }

}
