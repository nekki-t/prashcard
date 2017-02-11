//
//  TopViewController.swift
//  PrashCard
//
//  Created by nekki t on 2016/05/06.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

class TopViewController: UIViewController, AddCardDeckViewControllerDelegate, CAPSPageMenuDelegate{
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    var pageMenu: CAPSPageMenu?
    
    // MARK: Object
    var cardDeckSelectedObserver: NSObjectProtocol?
    
    var buttonPositionFrame: CGRect!
    
    @IBOutlet weak var createDeckButton: UIButton!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Life Cycles
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerCardDeckSelectedObserver()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeCardDeckSelectedObserver()
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Observers
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func registerCardDeckSelectedObserver() {
        cardDeckSelectedObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            SharedConstants.CardDeckSelectedNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                let cardDeck = notification.object as! CardDeck
                
                if cardDeck.cards!.count < 1 {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CardListViewController") as! CardListViewController
                    controller.cardDeck = cardDeck
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TrainingViewController") as! TrainingViewController
                    controller.cardDeck = cardDeck
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                
            }
        )
    }
    func removeCardDeckSelectedObserver() {
        if let observer = cardDeckSelectedObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer);
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - UI
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func configureUI (){
        navigationItem.title = "PrashCard"
        navigationController?.navigationBar.titleTextAttributes =
            [NSFontAttributeName: UIFont(name: "Didot", size: 30)!,
             NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var controllerArray : [UIViewController] = []
       
        let whiteCardDeckController : CardDeckViewController = CardDeckViewController(nibName: "CardDeckViewController", bundle: nil)
        whiteCardDeckController.title = "Start"
        whiteCardDeckController.cardDeckLevel = Training.Level.White
        controllerArray.append(whiteCardDeckController)
                
        
        let redCardDeckController : CardDeckViewController = CardDeckViewController(nibName: "CardDeckViewController", bundle: nil)
        redCardDeckController.title = "Beginner"
        redCardDeckController.cardDeckLevel = Training.Level.Red
        controllerArray.append(redCardDeckController)
        
        
        let orangeCardDeckController : CardDeckViewController = CardDeckViewController(nibName: "CardDeckViewController", bundle: nil)
        orangeCardDeckController.title = "Intermediate"
        orangeCardDeckController.cardDeckLevel = Training.Level.Yellow
        controllerArray.append(orangeCardDeckController)
        
        let greenCardDeckController : CardDeckViewController = CardDeckViewController(nibName: "CardDeckViewController", bundle: nil)
        greenCardDeckController.title = "Mastered"
        greenCardDeckController.cardDeckLevel = Training.Level.Green
        controllerArray.append(greenCardDeckController)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor(red: 58.0/255.0, green: 13.0/255.0, blue: 136.0/255.0, alpha: 1.0)),
            //.ViewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
            .SelectionIndicatorColor(UIColor.orangeColor()),
            .AddBottomMenuHairline(false),
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 20.0)!),
            .MenuHeight(30.0),
            .SelectionIndicatorHeight(3.0),
            CAPSPageMenuOption.SelectionIndicatorColor(UIColor.yellowColor()),
            .MenuItemWidthBasedOnTitleTextWidth(true),
            .SelectedMenuItemLabelColors(Training.getSelectedMenuColors()),
            .UnselectedMenuItemLabelColors(Training.getUnselectedMenuColors())
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        pageMenu!.delegate = self
        view.addSubview(pageMenu!.view)
        view.bringSubviewToFront(createDeckButton)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? AddCardDeckViewController {
            controller.delegate = self
        }
    }

    func addCardDeck(sender: AnyObject) {
        if let title = sender as? String {
            let _ = CardDeck(newName: title, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.CardDeckChangedNotification, object: Training.Level.White.rawValue)
        }
    }
    
    
    func editCardDecks () {
        print("edit...");
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - PageMenu Delegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func didMoveToPage(controller: UIViewController, index: Int) {
        let target = controller as! CardDeckViewController
        
        if target.cardDeckLevel == Training.Level.White {
            createDeckButton.hidden = false
        } else {
            createDeckButton.hidden = true
        }
    }
    
}
