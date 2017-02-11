//
//  CardDeckMenuViewController.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/21.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// MARK: - Protocol
protocol CardDeckMenuViewControllerDelegate: class {
    func optionChanged(sender: [TargetSetting])
    func doShuffle(sender: [TargetSetting])
}
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// MARK: - Class starts
class CardDeckMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Delegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    weak var delegate: CardDeckMenuViewControllerDelegate?
    var cardDeck:CardDeck!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    var targets:[TargetSetting]!
    let actionItems:[String] = ["Shuffle cards", "Edit cards"]
    
    let idxTarget = 0
    let idxAction = 1
    
    let idxRowShuffleCards = 0
    let idxRowEditCards = 1
    
    let sectionTitles: NSArray = ["Target 🎯", "Actions ☝️"]
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlet
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Life Cycle
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        menuTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        modalView.animate()
        
        // Background lock
        UIView.animateWithDuration(0.3, animations: {
            self.backgroundView.alpha = 0.3
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Background unlock
        backgroundView.alpha = 0
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Local functions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func configureUI () {
        
        // modalView
        modalView.transform = CGAffineTransformMakeTranslation(250, 0)
        
        modalView.layer.shadowColor = UIColor.blackColor().CGColor
        modalView.layer.shadowOffset = CGSize(width: 1.1, height: 1.1)
        modalView.layer.shadowOpacity = 1
        
        // Settings for background
        let backToTrainingTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backToTraining))
        backToTrainingTapRecognizer.numberOfTouchesRequired = 1
        backgroundView.userInteractionEnabled = true
        backgroundView.addGestureRecognizer(backToTrainingTapRecognizer)
        backgroundView.alpha = 0
        
        let backToTrainingSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        backToTrainingSwipeRecognizer.direction = .Right
        view.addGestureRecognizer(backToTrainingSwipeRecognizer)
    }
    
    func swipeRight(recognizer: UISwipeGestureRecognizer) {
        backToTraining()
    }
    func backToTraining () {
        modalView.animation = "slideLeft"
        modalView.animateFrom = false
        modalView.animateToNext({
            self.delegate?.optionChanged(self.targets)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Table View
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: Sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section] as? String
    }
    
    
    // MARK: Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case idxTarget:
            return targets.count
        case idxAction:
            return actionItems.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case idxTarget:
            targets[indexPath.row].selected = !targets[indexPath.row].selected
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! CardDeckMenuTableViewCell
            cell.targetSetting = targets[indexPath.row]
        case idxAction:
            switch indexPath.row {
            case idxRowShuffleCards:
                modalView.animation = "slideLeft"
                modalView.animateFrom = false
                modalView.animateToNext({
                    self.delegate?.doShuffle(self.targets)
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            case idxRowEditCards:
                let controller = storyboard?.instantiateViewControllerWithIdentifier("CardListViewController") as! CardListViewController
                controller.cardDeck = cardDeck
                if let nav = presentingViewController as? UINavigationController {
                    nav.pushViewController(controller, animated: true)
                    modalView.animation = "slideLeft"
                    modalView.animateFrom = false
                    modalView.animateToNext({
                        self.dismissViewControllerAnimated(false, completion: nil)
                    })
                }
            default:
                break
            }
        default:
            break
        }
    }
        
    // MARK: Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! CardDeckMenuTableViewCell
        
        switch indexPath.section {
        case idxTarget:
            cell.targetSetting = targets[indexPath.row]
        case idxAction:
            cell.title.text = actionItems[indexPath.row]
            cell.hideCheckMark()
        default:
            break
        }
        
        return cell
    }
}
