//
//  CardDeck+CoreDataProperties.swift
//  PrashCard
//
//  Created by nekki t on 2016/10/25.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
import CoreData

extension CardDeck {
    @NSManaged public var cardCount: NSNumber?
    @NSManaged public var challengedCount: NSNumber?
    @NSManaged public var clearedRate: NSNumber?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var currentLevel: NSNumber?
    @NSManaged public var greenCount: NSNumber?
    @NSManaged public var lastChallengedAt: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var redCount: NSNumber?
    @NSManaged public var whiteCount: NSNumber?
    @NSManaged public var yellowCount: NSNumber?
    @NSManaged public var cards: NSOrderedSet?

}

// MARK: Generated accessors for cards
extension CardDeck {

    @objc(insertObject:inCardsAtIndex:)
    @NSManaged public func insertIntoCards(value: Card, at idx: Int)

    @objc(removeObjectFromCardsAtIndex:)
    @NSManaged public func removeFromCards(at idx: Int)

    @objc(insertCards:atIndexes:)
    @NSManaged public func insertIntoCards(values: [Card], at indexes: NSIndexSet)

    @objc(removeCardsAtIndexes:)
    @NSManaged public func removeFromCards(at indexes: NSIndexSet)

    @objc(replaceObjectInCardsAtIndex:withObject:)
    @NSManaged public func replaceCards(at idx: Int, with value: Card)

    @objc(replaceCardsAtIndexes:withCards:)
    @NSManaged public func replaceCards(at indexes: NSIndexSet, with values: [Card])

    @objc(addCardsObject:)
    @NSManaged public func addToCards(value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(values: NSOrderedSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(values: NSOrderedSet)

}
