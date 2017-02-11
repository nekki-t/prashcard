//
//  CardDeckViewController.swift
//  PrashCard
//
//  Created by nekki t on 2016/05/26.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class CardDeckViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CardDeckTableViewCellDelegate {
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Connstants / Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    // MARK: Sample
    let sampleFileName = "english dictionary sample"
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    var pageMenu: CAPSPageMenu?
    var cardDeckLevel = Training.Level.White
    
    // To know the event card deck added
    var cardDeckChangedObserver: NSObjectProtocol?
    
    var cardDeckSelectedObserver: NSObjectProtocol?
    
    // MARK: NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "CardDeck")
        let sortDescriptor = NSSortDescriptor(key: "currentLevel", ascending: false)
        let sortByIdDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = []
        fetchRequest.sortDescriptors?.append(sortDescriptor)
        fetchRequest.sortDescriptors?.append(sortByIdDescriptor)
        fetchRequest.predicate = NSPredicate(format: "currentLevel==%d", self.cardDeckLevel.rawValue)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: "name", cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlets
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var cardDeckTableView: UITableView!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Life Cycle
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func viewDidLoad() {
        super.viewDidLoad()
        cardDeckTableView.registerNib(UINib(nibName: "CardDeckTableViewCell", bundle: nil), forCellReuseIdentifier: "CardDeckTableViewCell")
        doFetch()
        //if cardDeckLevel == Training.Level.White {
            registerCardDeckChangedObserver()
        //}
        if PrashCardConfig.unarchivedInstance() == nil {
            createSampleCardDeck()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        doFetch()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
   
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Local Functions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func createSampleCardDeck () {
        let cardDeck = CardDeck(newName: sampleFileName, context: sharedContext)
        
        let filePath = NSBundle.mainBundle().pathForResource(sampleFileName, ofType: "csv")
        let csvData = SharedController.loadCSV(filePath)
        for row in csvData {
            let card = Card(parentCardDeck: cardDeck, context: sharedContext)
            card.prepareForNewCard(row[0], backTextInput: row[1])
            cardDeck.addToCards(card)
        }
        cardDeck.cardCount = cardDeck.cards!.count
        cardDeck.whiteCount = cardDeck.cardCount
        
        CoreDataStackManager.sharedInstance().saveContext()
        PrashCardConfig.startPrashCard()
        doFetch()

    }
    
    func doFetch() {
        var error: NSError?
        
        do {
            try fetchedResultsController.performFetch()
        } catch let err as NSError {
            error = err
        }
        
        if let error = error {
            print("Error performing initial fetch for Reports: \(error)")
        } else {
            cardDeckTableView.reloadData()
        }
    }
    
    // MARK: Observers
    func registerCardDeckChangedObserver() {
        if cardDeckChangedObserver == nil {
            cardDeckChangedObserver = NSNotificationCenter.defaultCenter().addObserverForName(
                SharedConstants.CardDeckChangedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in    
                    self.doFetch()
                }
            )
        }
    }
    
    func removeCardDeckAddedObserver() {
        if let observer = cardDeckChangedObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    // MARK: Delegate from cell
    func cardDeckDeleted() {
        doFetch()
    }
    
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Table View Delegate and Data Source
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReusedId = "CardDeckTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReusedId, forIndexPath: indexPath) as! CardDeckTableViewCell
        let cardDeck = fetchedResultsController.objectAtIndexPath(indexPath) as! CardDeck
        
        cell.cardDeck = cardDeck
        cell.viewControllerDelegate = self
        cell.cardDeckTableViewCellDelegate = self
        return cell
    }
    
    // top space
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    // bottom space
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
    }
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
    }

    // Sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.fetchedResultsController.sectionIndexTitles //UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
    }
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    // Numbers of Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    // Height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.CardDeckSelectedNotification, object: fetchedResultsController.objectAtIndexPath(indexPath) as! CardDeck)
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
