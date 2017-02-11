//
//  CardDeck+CoreDataClass.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/22.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
import CoreData


public class CardDeck: NSManagedObject {
    convenience init(newName: String, context: NSManagedObjectContext) {
        // Core Data
        if let entity = NSEntityDescription.entityForName("CardDeck", inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            name = newName
            cardCount = 0
            currentLevel = Training.Level.White.rawValue
            whiteCount = 0
            redCount = 0
            yellowCount = 0
            greenCount = 0
            challengedCount = 0
            clearedRate = 0.0
            createdAt = NSDate()            
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
    
    func updateLevel () {
        if Int(cardCount!) < 1 {
            return
        }
        if challengedCount == 0 {
            return
        }
        
        let rate = Double(greenCount!) / Double(cardCount!)
        clearedRate = rate
        
        if rate >= Training.LevelBorder.Master.rawValue {
            currentLevel = Training.Level.Green.rawValue
        } else if rate >= Training.LevelBorder.Intermediate.rawValue {
            currentLevel = Training.Level.Yellow.rawValue
        } else {
            let intermediateRate = (Double(greenCount!) + Double(yellowCount!)) / Double(cardCount!)
            if intermediateRate > Training.LevelBorder.AnotherIntermediate.rawValue {
                currentLevel = Training.Level.Yellow.rawValue
            } else {
                currentLevel = Training.Level.Red.rawValue
            }
        }
    }
    
    func getClearedPercentage() -> Int{
        return Int(Double(clearedRate!) * 100)
    }
    
    func importFromCsvRows(rows: [[String]], sharedContext: NSManagedObjectContext) -> String {
        var errString = ""
        var index = 1
        for row in rows {
            if row.count != 2 {
                errString = "There is an invalid data in the csv file. Please check the row \(index).\nImporting is interrupted."
                break
            }            
            
            let frontText = row[0].stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
            let backText = row[1].stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
            
            if let card = getTargetCard(frontText) {
                card.backText = backText
            } else {
                let newCard = Card(parentCardDeck: self, context: sharedContext)
                newCard.prepareForNewCard(frontText, backTextInput: backText)
                newCard.cardDeck!.whiteCount = NSNumber(integer: Int(newCard.cardDeck!.whiteCount!) + 1)
                newCard.cardDeck!.cardCount = NSNumber(integer: Int(newCard.cardDeck!.cardCount!) + 1)
                newCard.cardDeck!.updateLevel()
            }
            CoreDataStackManager.sharedInstance().saveContext()
            index += 1
        }
        
        return errString
    }
    
    func getTargetCard (frontText: String) -> Card? {
        var target:Card?
        
        let cardDeckFetchRequest = NSFetchRequest(entityName: "Card")
        cardDeckFetchRequest.predicate = NSPredicate(format: "cardDeck = %@ and frontText == %@", self, frontText)
        cardDeckFetchRequest.includesSubentities = false
        
        var results: NSArray?
        
        do {
            results = try CoreDataStackManager.sharedInstance().managedObjectContext?.executeFetchRequest(cardDeckFetchRequest)
        } catch let err as NSError {
            print("\(err)")
        }
        
        if let arr = results {
            if arr.count > 0 {
                target = arr[0] as? Card
            }
        }
        return target
    }
    
    class func nameExists (newName: String) -> Bool {
        var result = false
        
        let cardDeckFetchRequest = NSFetchRequest(entityName: "CardDeck")
        cardDeckFetchRequest.predicate = NSPredicate(format: "name == %@", newName)
        cardDeckFetchRequest.includesSubentities = false
        
        var count: Int?
        
        do {
            count = try CoreDataStackManager.sharedInstance().managedObjectContext?.countForFetchRequest(cardDeckFetchRequest)
        } catch let err as NSError {
            print("\(err)")
        }
        
        if count > 0 {
            result = true
        }
        
        return result
        
    }
}
