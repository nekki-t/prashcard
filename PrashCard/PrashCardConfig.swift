//
//  PrashCardConfig.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/24.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
import UIKit

private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("PrashCardConfig-Context")!

class PrashCardConfig: NSObject, NSCoding {
    
    override init() {}
    convenience init?(dictionary: [String: AnyObject]) {
        self.init()
    }
    
    // MARK: Variables
    var started = false
    var startedAt: NSDate? = nil
    
    // MARK: NSCoding
    let StartedStringKey = "config.started"
    let StartedAtStringKey = "config.startedAt"
    
    required init(coder aDecoder: NSCoder) {
        started = aDecoder.decodeObjectForKey(StartedStringKey) as! Bool
        startedAt = aDecoder.decodeObjectForKey(StartedAtStringKey) as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(started, forKey: StartedStringKey)
        aCoder.encodeObject(startedAt, forKey: StartedAtStringKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func startPrashCard() {
        let config = PrashCardConfig()
        config.started = true
        config.startedAt = NSDate()
        
        config.save()
    }
    
    class func unarchivedInstance() -> PrashCardConfig? {
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? PrashCardConfig
        } else {
            return nil
        }
    }
}
