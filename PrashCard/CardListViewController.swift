//
//  CardEditViewController.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/22.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData

class CardListViewController: UIViewController,
UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CardViewControllerDelegate {
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    var cardDeck: CardDeck!
    var selectedCard: Card!
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    var csvExporting = false
    
    // MARK: NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Card")
        let sortDescriptor = NSSortDescriptor(key: "frontText", ascending: true)
        fetchRequest.sortDescriptors = []
        fetchRequest.sortDescriptors!.append(sortDescriptor)
        fetchRequest.predicate = NSPredicate(format: "cardDeck==%@", self.cardDeck)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: "frontText",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlets
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var cardCountLabel: UILabel!
    @IBOutlet weak var cardDeckNameLabel: UILabel!
    @IBOutlet weak var cardDeckInfoView: UIView!
    @IBOutlet weak var cardTableView: UITableView!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Life Cycle
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedViewFunctions.setShadow(cardDeckInfoView.layer)
        
        // navigation
        setNavigationBar()
        
        // swipe
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        recognizer.direction = .Left
        view.addGestureRecognizer(recognizer)
        
        doFetch()
        setValues()
    }
    
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBActions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBAction func btnAddTapped(sender: AnyObject) {
        selectedCard = nil
        performSegueWithIdentifier("GotoCard", sender: self)
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - segue
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CardViewController {
            controller.cardDeck = cardDeck
            controller.card = selectedCard
            controller.delegate = self
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Local Functions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func setValues() {
        cardDeckNameLabel.text = cardDeck.name
        cardCountLabel.text = String(fetchedResultsController.fetchedObjects!.count)
    }
    
    func setNavigationBar() {
        navigationItem.title = "Card Deck"
        let exportButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(self.exportToCSV))
        //let importButton = UIBarButtonItem(barButtonSystemItem: .Organize, target: self, action: #selector(self.importFromCSV)) // excluded for the time reason
        
        
        navigationItem.rightBarButtonItems = [exportButton]
    
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back", style: .Done, target: self, action: #selector(self.back))
        navigationItem.leftBarButtonItem = backButton
    }
    
    
    func back() {
        if Int(cardDeck.cardCount!) < 1 {
            navigationController?.popToRootViewControllerAnimated(true)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    func exportToCSV() {
        csvExporting = true
        
        if cardDeck.cards?.count < 1 {
            SharedController.showAlert("Csv Exporting Error!", message: "No card is created.", targetViewController: self)
            return
        }
        let csvString = Card.generateCSVString(cardDeck)
        
        if csvString == "" {
            SharedController.showAlert("Csv Exporting Error!", message: "Failed to generate CSV string.", targetViewController: self)
            return
        }
        
        let csvFileName = "\(cardDeck.name!).csv"
        let exportResult = SharedController.saveCSV(csvString, exportFileName: csvFileName)
        csvExporting = false
        if exportResult {
            SharedController.showAlert("CSV file saved as \"\(csvFileName)\"", message: "You can read the file from iTunes. In the future release, you will be able to edit it as you want and import it here again.", targetViewController: self)
        } else {
            SharedController.showAlert("Csv Exporting Error!", message: "Failed to generate CSV string.", targetViewController: self)
        }
    }
    func importFromCSV() {
        let cardRows = SharedController.loadCSV("\(cardDeck.name!).csv")
        if cardRows.count < 1 {
            SharedController.showAlert("Csv Importing Error!", message: "Failed to read CSV file. Please make sure you have exported this card deck first.", targetViewController: self)
            return
        } else {
            cardDeck.importFromCsvRows(cardRows, sharedContext: sharedContext)
            SharedController.showAlert("Succeeded!!", message: "Cards are imported from the file and synchronized successfully.", targetViewController: self)
            doFetch()
            setValues()
        }
    }
    
    func swipeLeft(recognizer: UISwipeGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            cardTableView.reloadData()
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - CardViewControllerDelegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func cardEditEnded(targetCard: Card) {
        doFetch()
        setValues()
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Table View Delegate and Data Source
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: Sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.fetchedResultsController.sectionIndexTitles //UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
    }
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    // MARK: Row
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCard = fetchedResultsController.objectAtIndexPath(indexPath) as! Card
        performSegueWithIdentifier("GotoCard", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let cancelAlert = UIAlertController(title: "Warning!!", message: "This card is completely deleted.\r\nAre you sure?", preferredStyle: UIAlertControllerStyle.Alert)
            
            cancelAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                let card = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Card
                if Int(card.cardDeck!.cardCount!) == 0 {
                    // just in case
                    return
                }
                
                card.cardDeck!.cardCount = NSNumber(integer: Int(card.cardDeck!.cardCount!) - 1)
                switch Int(card.currentLevel!) {
                case Training.Level.White.rawValue:
                    card.cardDeck!.whiteCount = NSNumber(integer: Int(card.cardDeck!.whiteCount!) - 1)
                case Training.Level.Red.rawValue:
                    card.cardDeck!.redCount = NSNumber(integer: Int(card.cardDeck!.redCount!) - 1)
                case Training.Level.Yellow.rawValue:
                    card.cardDeck!.yellowCount = NSNumber(integer: Int(card.cardDeck!.yellowCount!) - 1)
                case Training.Level.Green.rawValue:
                    card.cardDeck!.greenCount = NSNumber(integer: Int(card.cardDeck!.greenCount!) - 1)
                default:
                    break
                }
                card.cardDeck!.updateLevel()
                self.sharedContext.deleteObject(card)
                CoreDataStackManager.sharedInstance().saveContext()
                self.doFetch()
                self.setValues()
                NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.CardDeckChangedNotification, object: Training.Level.White.rawValue)
                return
            }))
            cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(cancelAlert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuserdId = "CardCell"
        let cell = cardTableView.dequeueReusableCellWithIdentifier(cellReuserdId, forIndexPath: indexPath) as! CardPreviewTableViewCell
        if let card = fetchedResultsController.objectAtIndexPath(indexPath) as? Card {
            cell.card = card
        }
        return cell
    }
}
