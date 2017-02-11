//
//  Card+CoreDataClass.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/22.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
import CoreData


public class Card: NSManagedObject {
    static let CsvAttributes = ["frontText", "backText"]
    static let FrontTextLength = 50
    static let BackTextLength = 300
    
    // Scoring Rule
    let upToYellow = 1
    let upToGreen = 3
    let downToYellow = 1
    let downToRed = 3
    let downFromWhite = 1
    
    convenience init(parentCardDeck: CardDeck!, context: NSManagedObjectContext) {
        // Core Data
        if let entity = NSEntityDescription.entityForName("Card", inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            frontText = ""
            backText = ""
            currentLevel = Training.Level.White.rawValue
            cardDeck = parentCardDeck
            consecutiveClearedCount = 0
            consecutiveFailedCount = 0
            clearedCount = 0
            failedCount = 0
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
    
    func prepareForNewCard(frontTextInput: String!, backTextInput:String!) {
        frontText = frontTextInput
        backText = backTextInput
        createdAt = NSDate()
    }
    
    // MARK: - Level related methods
    func cleared() {
        clearedCount = NSNumber(int: 1 + Int(clearedCount!))
        consecutiveClearedCount = NSNumber(int: 1 + Int(consecutiveClearedCount!))
        consecutiveFailedCount = 0
        lastChallengedAt = NSDate()
        updateLevelInfo()
        cardDeck!.updateLevel()        
    }
    func failed() {
        failedCount = NSNumber(int: 1 + Int(failedCount!))
        consecutiveClearedCount = 0
        consecutiveFailedCount = NSNumber(int: 1 + Int(consecutiveFailedCount!))
        lastChallengedAt = NSDate()
        updateLevelInfo()
        cardDeck!.updateLevel()
    }
    
    private func updateLevelInfo() {
        switch Int(currentLevel!) {
        case Training.Level.White.rawValue:
            updateLevelFromWhite()
        case Training.Level.Red.rawValue:
            updateLevelFromRed()
        case Training.Level.Yellow.rawValue:
            updateLevelFromYellow()
        case Training.Level.Green.rawValue:
            updateLevelFromGreen()
        default:
            break
        }
    }
    
    private func updateLevelFromWhite () {
        if Int(consecutiveClearedCount!) >= upToYellow {
            currentLevel = Training.Level.Yellow.rawValue
            cardDeck!.yellowCount = NSNumber(integer: Int(cardDeck!.yellowCount!) + 1)
        } else {
            currentLevel = Training.Level.Red.rawValue
            cardDeck!.redCount = NSNumber(integer: Int(cardDeck!.redCount!) + 1)
        }
        cardDeck!.whiteCount = NSNumber(integer: Int(cardDeck!.whiteCount!) - 1)
        resetConsecutiveCount()
    }
    private func updateLevelFromRed() {
        if Int(consecutiveClearedCount!) >= upToYellow {
            currentLevel = Training.Level.Yellow.rawValue
            cardDeck!.yellowCount = NSNumber(integer: Int(cardDeck!.yellowCount!) + 1)
            cardDeck!.redCount = NSNumber(integer: Int(cardDeck!.redCount!) - 1)
            cardDeck!.updateLevel()
            resetConsecutiveCount()
        }
    }
    private func updateLevelFromYellow() {
        if Int(consecutiveClearedCount!) >= upToGreen {
            currentLevel = Training.Level.Green.rawValue
            cardDeck!.yellowCount = NSNumber(integer: Int(cardDeck!.yellowCount!) - 1)
            cardDeck!.greenCount = NSNumber(integer: Int(cardDeck!.greenCount!) + 1)
            resetConsecutiveCount()
        } else if Int(consecutiveFailedCount!) >= downToRed {
            currentLevel = Training.Level.Red.rawValue
            cardDeck!.yellowCount = NSNumber(integer: Int(cardDeck!.yellowCount!) - 1)
            cardDeck!.redCount = NSNumber(integer: Int(cardDeck!.redCount!) + 1)
            resetConsecutiveCount()
        }
    }
    private func updateLevelFromGreen() {
        if Int(consecutiveFailedCount!) >= downToYellow {
            currentLevel = Training.Level.Yellow.rawValue
            cardDeck!.greenCount = NSNumber(integer: Int(cardDeck!.greenCount!) - 1)
            cardDeck!.yellowCount = NSNumber(integer: Int(cardDeck!.yellowCount!) + 1)
            resetConsecutiveCount()
        }
    }
    
    private func resetConsecutiveCount () {
        consecutiveClearedCount = 0
        consecutiveFailedCount = 0
    }    
    
    
    // MARK: - CSV related methods
    class func generateCSVString(cardDeck: CardDeck)->String{
        
        let fetchRequest = NSFetchRequest(entityName: "Card")
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "cardDeck==%@", cardDeck)
        
        var cards: NSArray?
        
        do {
            cards = try CoreDataStackManager.sharedInstance().managedObjectContext?.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            print(error)
            return ""
        }
        
        if cards?.count < 1 {
            return ""
        }
        
        var objects = cards as! [NSManagedObject]
        
        let firstObject = objects[0]
        let attribs = Array(firstObject.entity.attributesByName.keys)
        let sortedAttribs: [String] = sortCSVHeader(attribs)
        
        let csvBodyString = generateCSVBodyString(sortedAttribs, objects: objects)
        
        return csvBodyString
    }

    private class func sortCSVHeader(attribs: [String]) -> [String] {
        var sortedAttribs: [String] = []
        for header in CsvAttributes {
            if attribs.contains(header) {
                sortedAttribs.append(header)
            }
        }
        return sortedAttribs
    }
    private class func generateCSVBodyString(attribs: [String], objects: [NSManagedObject]) -> String {
        var csvArray:[String] = []
        for object in objects {
            var rowArray: [String] = []
            
            for attr in attribs {
                if object.valueForKey(attr) == nil {
                    rowArray.append("")
                } else {
                    var str = object.valueForKey(attr) as! String
                    str = str.stringByReplacingOccurrencesOfString("\"", withString: "\"\"")
                    str = "\"\(str)\""
                    rowArray.append(str)
                }
            }
            csvArray.append((rowArray.reduce("",combine: {($0 as String) + "," + $1}) as NSString).substringFromIndex(1) + "\n")
        }
        return csvArray.reduce("", combine: +)
    }
    
}
