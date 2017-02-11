//
//  Card+CoreDataProperties.swift
//  PrashCard
//
//  Created by nekki t on 2016/10/25.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
import CoreData

extension Card {

    @NSManaged public var backText: String?
    @NSManaged public var clearedCount: NSNumber?
    @NSManaged public var consecutiveClearedCount: NSNumber?
    @NSManaged public var consecutiveFailedCount: NSNumber?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var currentLevel: NSNumber?
    @NSManaged public var failedCount: NSNumber?
    @NSManaged public var frontText: String?
    @NSManaged public var lastChallengedAt: NSDate?
    @NSManaged public var sortIndex: NSNumber?
    @NSManaged public var cardDeck: CardDeck?

}
