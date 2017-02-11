//
//  TrainingViewController.swift
//  PrashCard
//
//  Created by nekki t on 2016/07/04.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData

class TrainingViewController: UIViewController, CardDeckMenuViewControllerDelegate {
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Constants/Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    enum Direction : Int {
        case None
        case Left
        case Right
    }
    
    let defaultChallengedInfo = "--- times challenged"
    let defaultTimesText = "---"
    // clear or fail
    var direction = Direction.None
    
    // Flags
    var isStarted = false
    var canRestart = false
    var isShowingFront = true
    
    var cardDeck: CardDeck!
    var cards:[Card]!
    var targets:[TargetSetting] = TargetSetting.getTargets()
    lazy private var currentCardView: SpringView = SpringView()
    lazy private var cardLabel:UILabel! = UILabel()
    
    // navigation item
    var pauseButton:UIBarButtonItem!
    var currentCardIndex = 0
    
    // result view
    var resultTap = UITapGestureRecognizer()
    
    // for Scoring
    var cleared = 0
    var failed = 0
    
    // for count down
    var timer: NSTimer!
    let timelimit = 7
    var counter = 0
    var countToShowTimer = 4
    
    // shuffle
    var isShuffling = false
    
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlets
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    
    // Before Start view
    @IBOutlet weak var startButton: DesignableButton!
    @IBOutlet weak var beforeStartView: UIView!
    
    // progress bar
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressValueLabel: UILabel!
    
    // info view
    @IBOutlet weak var topClearedCount: UILabel!
    @IBOutlet weak var topFailedCount: UILabel!
    @IBOutlet weak var topChallengedCount: UILabel!
    
    // Result view
    @IBOutlet weak var clearedLabel: UILabel!
    @IBOutlet weak var failedLabel: UILabel!
    @IBOutlet weak var resultView: SpringView!
    @IBOutlet weak var resultLevelView: SpringView!
    @IBOutlet weak var restartLabel: SpringLabel!
    @IBOutlet weak var updatedLevelLabel: UILabel!
    
    // Training view
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardDeckInfo: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var notYetButton: UIButton!
    
    // count down view
    @IBOutlet weak var countDownView: UIView!
    @IBOutlet weak var countDownLabel: UILabel!
    
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Life Cycle
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // navigation
        navigationItem.title = "Training"
        let menubutton = UIBarButtonItem(image: UIImage(named: "menuButton"), style: .Done, target: self, action: #selector(self.menuButtonTapped))
        navigationItem.rightBarButtonItem = menubutton
        pauseButton = UIBarButtonItem(image: UIImage(named: "pause"), style: .Plain, target: self, action: #selector(self.pauseButtonTapped))
        navigationItem.leftBarButtonItem = pauseButton
        navigationItem.hidesBackButton = true
        
        // result view
        setResultView()

        // Other View Settings
        configureView()
        
        // Load and update progress view
        refreshData()
        
        // z-index
        view.bringSubviewToFront(resultView)
        view.bringSubviewToFront(beforeStartView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        currentCardView.removeFromSuperview()
        isShowingFront = false
        isStarted = false
        currentCardIndex = 0
        beforeStartView.hidden = false
        view.sendSubviewToBack(countDownView)
        
        // Load and update progress view
        refreshData()
        
    }

    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - NavigationItem buttons
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func menuButtonTapped () {
        if isStarted {
            let cancelAlert = UIAlertController(
                title: "Show menu",
                message: "Are you sure?\nThis will quit this challenge.",
                preferredStyle: .Alert)
            cancelAlert.addAction(
                UIAlertAction(title: "Yes", style: .Default, handler: {
                    (action: UIAlertAction!) in
                    self.resetTraining()
                    self.performSegueWithIdentifier("GotoCardDeckMenu", sender: self)
                    return
            }))
            cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(cancelAlert, animated: true, completion: nil)
        } else {
            self.resetTraining()
            performSegueWithIdentifier("GotoCardDeckMenu", sender: self)
        }
    }
    
    func pauseButtonTapped() {
        if isStarted {
            let cancelAlert = UIAlertController(
                title: "Back to Top",
                message: "Do you quit this challenge?",
                preferredStyle: .Alert)
            cancelAlert.addAction(
                UIAlertAction(title: "Yes", style: .Default, handler: {
                    (action: UIAlertAction!) in
                    NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.CardDeckChangedNotification, object: Training.Level.White.rawValue)
                    self.navigationController?.popViewControllerAnimated(true)
                    return
                }))
            cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(cancelAlert, animated: true, completion: nil)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.CardDeckChangedNotification, object: Training.Level.White.rawValue)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Segue
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CardDeckMenuViewController {
            controller.delegate = self
            controller.cardDeck = cardDeck
            controller.targets = targets
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - CardDeckMenu Delegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func optionChanged(sender: [TargetSetting]) {
        targets = sender
        // Load and update progress view
        refreshData()
        resetTraining()
    }
    
    func doShuffle(sender: [TargetSetting]) {
        
        targets = sender
        
        var count = cards.count
        
        for index in 0..<cards.count {
            let randomIndex = arc4random() % UInt32(count)
            cards[index].sortIndex = Int(randomIndex)
            count = count - 1
        }
        CoreDataStackManager.sharedInstance().saveContext()
        isShuffling = true
        // Load and update progress view
        refreshData()
        resetTraining()
        
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Local functions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func refreshData() {
        // Load Cards
        loadCardArray();
        
        // progress info
        progressView.setProgress(0.0, animated: true)
        updateProgressLabel()
    }
    
    
    func swipeLeft(recognizer: UISwipeGestureRecognizer) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func configureView() {
        cardView.backgroundColor = UIColor.grayColor()
        cardView.layer.cornerRadius = 3
        cardView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        cardView.layer.shadowOffset = CGSizeMake(1, 1)
        cardView.layer.shadowOpacity = 1.0;
        cardView.layer.shadowRadius = 1;
        cardView.alpha = 1.0
        
        cardDeckInfo.backgroundColor = UIColor.whiteColor()
        cardDeckInfo.layer.cornerRadius = 3
        cardDeckInfo.layer.shadowColor = UIColor.darkGrayColor().CGColor
        cardDeckInfo.layer.shadowOffset = CGSizeMake(1, 1)
        cardDeckInfo.layer.shadowOpacity = 1.0;
        cardDeckInfo.layer.shadowRadius = 1;
        cardDeckInfo.alpha = 1.0
        
        adjustButtonStyle(startButton, backgroundColor:  UIColor(colorLiteralRed: 215/255, green: 1/255, blue: 168/255, alpha: 1.0))
        startButton.layer.cornerRadius = 3
        startButton.layer.shadowColor = UIColor.darkGrayColor().CGColor
        startButton.layer.shadowOffset = CGSizeMake(1, 1)
        startButton.layer.shadowOpacity = 1.0;
        startButton.layer.shadowRadius = 1;
        
        resultLevelView.layer.cornerRadius = 3
        resultLevelView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        resultLevelView.layer.shadowOffset = CGSizeMake(1, 1)
        resultLevelView.layer.shadowOpacity = 1.0;
        resultLevelView.layer.shadowRadius = 1;
        
        adjustButtonStyle(okButton, backgroundColor: UIColor(colorLiteralRed: 6/255, green: 200/255, blue: 31/255, alpha: 1.0))
        adjustButtonStyle(notYetButton, backgroundColor: UIColor(colorLiteralRed: 255/255, green: 0/255, blue: 0/255, alpha: 1.0))
        
        progressView.setProgress(0.0, animated: true)
        
        topClearedCount.text = defaultTimesText
        topFailedCount.text = defaultTimesText
        topChallengedCount.text = defaultChallengedInfo
        
    }
    
    func setResultView() {
        resultView.hidden = true
        resultLevelView.hidden = true
        restartLabel.hidden = true
        
        resultTap = UITapGestureRecognizer(target: self, action: #selector(self.resultTapped(_:)))
        resultTap.numberOfTapsRequired = 1
        resultView.addGestureRecognizer(resultTap)
    }
    
    func start() {
        
        cardDeck.challengedCount = Int(cardDeck.challengedCount!) + 1
        CoreDataStackManager.sharedInstance().saveContext()

        UIView.animateWithDuration(
            1,
            animations: {
                self.beforeStartView.backgroundColor = UIColor.blackColor()
            },
            completion: {
                (finished: Bool) in
                self.beforeStartView.hidden = true
                self.isStarted = true
                self.generateNextCardView()
                self.updateProgressLabel()
                self.progressView.setProgress(self.getProgressValue(), animated: true)
                self.timerStart()
            }
        )
    }
    
    
    func timerStart () {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.tickTimer(_:)), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    func tickTimer(tmr: NSTimer) {
        counter += 1
        if counter == countToShowTimer {
            view.bringSubviewToFront(countDownView)
        }
        if counter == timelimit {
            counter = 0
            answerAction(Direction.Left)
        } else {
            countDownLabel.text = "\(timelimit - counter)"
        }
    }
    
    func generateNextCardView() {
        self.isShowingFront = true
        
        currentCardView = SpringView(frame: cardView.layer.frame)
        
        cardLabel.text = cards[currentCardIndex].frontText
        currentCardView.backgroundColor = Training.getColorByLevel(Int(cards[currentCardIndex].currentLevel!))
                
        // configure label
        cardLabel.sizeToFit()
        cardLabel.frame = CGRectMake(0, 0, currentCardView.layer.frame.width, currentCardView.layer.frame.height)
        cardLabel.textAlignment = .Center
        cardLabel.font = UIFont.systemFontOfSize(CGFloat(25))
        cardLabel.textColor = UIColor.blackColor()
        cardLabel.lineBreakMode = .ByWordWrapping
        cardLabel.numberOfLines = 0
        
        // configure card view
        currentCardView.alpha = 0.0
        currentCardView.layer.cornerRadius = 3
        currentCardView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        currentCardView.layer.shadowOffset = CGSizeMake(1, 1)
        currentCardView.layer.shadowOpacity = 1.0;
        currentCardView.layer.shadowRadius = 1;
        
        
        self.view.addSubview(currentCardView)
        currentCardView.addSubview(cardLabel)
        currentCardView.frame = cardView.frame
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.cardDoubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        currentCardView.addGestureRecognizer(doubleTap)
        
        self.updateChallengeInfo()
        
        super.updateViewConstraints()
        UIView.animateWithDuration(
            0.1,
            animations: {
                self.currentCardView.alpha = 1.0
            }
        )
    }
    
    func resetTraining() {
        // remove card
        currentCardView.removeFromSuperview()
        
        // init index & scores
        currentCardIndex = 0
        cleared = 0
        failed = 0
        
        // training info
        topChallengedCount.text = defaultChallengedInfo
        topClearedCount.text = defaultTimesText
        topFailedCount.text = defaultTimesText
        
        updateProgressLabel()
        progressView.setProgress(0.0, animated: true)
        
        isShowingFront = false
        isStarted = false
        beforeStartView.backgroundColor = UIColor.darkGrayColor()
        beforeStartView.hidden = false
        resultView.hidden = true

        // countdown info
        counter = 0
        if let tmr = timer {
            tmr.invalidate()
        }
        view.sendSubviewToBack(countDownView)
    }
    
    func resultTapped(sender: UIGestureRecognizer!) {
        if canRestart {
            UIView.animateWithDuration(
                1.0,
                animations: {
                    self.resultView.alpha = 0
                    self.resetTraining()
                },
                completion: {
                    finished in
                    
                    self.canRestart = false
                    self.resultView.hidden = true
                    self.resultView.alpha = 1.0
                }
            )
        }
    }
    
    func cardDoubleTapped(sender: UIGestureRecognizer!) {
        print("Double Tapped!!")
        UIView.transitionWithView(
            self.currentCardView,
            duration: 0.2,
            options: UIViewAnimationOptions.TransitionFlipFromLeft,
            animations: {
                
                if self.isShowingFront {
                    self.currentCardView.backgroundColor = UIColor.whiteColor()
                    self.cardLabel.text = self.cards[self.currentCardIndex].backText

                } else {
                    self.currentCardView.backgroundColor = Training.getColorByLevel(Int(self.cards[self.currentCardIndex].currentLevel!))
                    self.cardLabel.text = self.cards[self.currentCardIndex].frontText
                }
                self.isShowingFront = !self.isShowingFront
                
                            },
            completion: nil
        )
    }
    
    func adjustButtonStyle(button: UIButton, backgroundColor: UIColor) {
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 3
        button.layer.shadowColor = UIColor.darkGrayColor().CGColor
        button.layer.shadowOffset = CGSizeMake(1, 1)
        button.layer.shadowOpacity = 1.0;
        button.layer.shadowRadius = 1;
        button.alpha = 1.0
    }
    
    func loadCardArray() {
        let fetchRequest = NSFetchRequest(entityName: "Card")
        fetchRequest.predicate = getPredicateByTargetSettings()
        
        var sortDescriptor: NSSortDescriptor
        if isShuffling {
            sortDescriptor = NSSortDescriptor(key: "sortIndex", ascending: true)
            isShuffling = false
        } else {
            sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var results: NSArray?
        var error: NSError?
        do {
            results = try CoreDataStackManager.sharedInstance().managedObjectContext?.executeFetchRequest(fetchRequest)
        } catch let err as NSError {
            error = err
            print("Could not fetch \(err), \(err.userInfo)")
        }

        if error == nil {
            cards = results as! [Card]
        }
    }
    
    func getPredicateByTargetSettings() -> NSPredicate{
        
        var query = "cardDeck==%@"
        
        let white = TargetSetting.getTargetSetting(targets, levelString: TargetSetting.settingWhite).selected
        let red = TargetSetting.getTargetSetting(targets, levelString: TargetSetting.settingRed).selected
        let yellow = TargetSetting.getTargetSetting(targets, levelString: TargetSetting.settingYellow).selected
        let green = TargetSetting.getTargetSetting(targets, levelString: TargetSetting.setttingGreen).selected
        
        if white && red && yellow && green {
            return NSPredicate(format: query, cardDeck)
        } else if white && red && yellow {
            query = "\(query) and (currentLevel = %d or currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.White.rawValue, Training.Level.Red.rawValue, Training.Level.Yellow.rawValue)
        } else if white && red {
            query = "\(query) and (currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.White.rawValue, Training.Level.Red.rawValue)
        } else if white && yellow {
            query = "\(query) and (currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.White.rawValue, Training.Level.Yellow.rawValue)
        } else if white && green {
            query = "\(query) and (currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.White.rawValue, Training.Level.Green.rawValue)
        } else if red && yellow && green {
            query = "\(query) and (currentLevel = %d or currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.Red.rawValue, Training.Level.Yellow.rawValue, Training.Level.Green.rawValue)
        } else if red && yellow {
            query = "\(query) and (currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.Red.rawValue, Training.Level.Yellow.rawValue)
        } else if red && green {
            query = "\(query) and (currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.Red.rawValue, Training.Level.Green.rawValue)
        } else if yellow && green && white {
            query = "\(query) and (currentLevel = %d or currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.Yellow.rawValue, Training.Level.Green.rawValue, Training.Level.White.rawValue)
        } else if yellow && green {
            query = "\(query) and (currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.Yellow.rawValue, Training.Level.Green.rawValue)
        } else if green && white && red {
            query = "\(query) and (currentLevel = %d or currentLevel = %d or currentLevel = %d)"
            return NSPredicate(format: query, cardDeck, Training.Level.Green.rawValue, Training.Level.White.rawValue, Training.Level.Green.rawValue)
        } else if white {
            query = "\(query) and currentLevel = %d"
            return NSPredicate(format: query, cardDeck, Training.Level.White.rawValue)
        } else if red {
            query = "\(query) and currentLevel = %d"
            return NSPredicate(format: query, cardDeck, Training.Level.Red.rawValue)
        } else if yellow {
            query = "\(query) and currentLevel = %d"
            return NSPredicate(format: query, cardDeck, Training.Level.Yellow.rawValue)
        } else if green {
            query = "\(query) and currentLevel = %d"
            return NSPredicate(format: query, cardDeck, Training.Level.Green.rawValue)
        } else {
            return NSPredicate(format: query, cardDeck)
        }
    }
    
    
    func answerAction(direction: Direction) {
        if !isStarted {
            return
        }
        UIView.animateWithDuration(
            0.1,
            animations: { () -> Void in
                if direction == Direction.Right {
                    self.cards[self.currentCardIndex].cleared()
                    self.direction = Direction.Right
                    
                } else {
                    self.cards[self.currentCardIndex].failed()
                    self.direction = Direction.Left
                }
                CoreDataStackManager.sharedInstance().saveContext()
                return
            },
            completion: {
                finished in
                self.view.sendSubviewToBack(self.countDownView)
                if self.direction == Direction.Left || self.direction == Direction.Right {
                    
                    var myFrame: CGRect = self.currentCardView.frame
                    var degree:CGFloat
                    if self.direction == Direction.Left {
                        myFrame.origin.x = self.view.frame.origin.x - myFrame.width
                        myFrame.origin.y = self.view.frame.maxY + 300
                        degree = 0 - CGFloat(M_PI_2)
                        self.failed = self.failed + 1
                    } else {
                        myFrame.origin.x = self.view.frame.maxX + myFrame.width
                        myFrame.origin.y = self.view.frame.maxY + 300
                        degree = CGFloat(M_PI_2)
                        self.cleared = self.cleared + 1
                    }
                    
                    
                    UIView.animateWithDuration(
                        0.1,
                        animations: {
                            self.currentCardView.frame = myFrame
                            self.currentCardView.transform = CGAffineTransformRotate(self.currentCardView.transform, degree)
                        },
                        completion: {
                            finished in
                            self.direction = Direction.None
                            self.currentCardView.removeFromSuperview()
                            
                            self.counter = 0
                            
                            if self.currentCardIndex < (self.cards.count - 1) {
                                // next card
                                self.currentCardIndex += 1
                                // training info
                                self.updateProgressLabel()
                                self.progressView.setProgress(self.getProgressValue(), animated: true)
                                self.generateNextCardView()
                                self.timer.invalidate()
                                self.timerStart()
                            } else {
                                
                                // Finished all
                                self.clearedLabel.text = String(self.cleared)
                                self.failedLabel.text = String(self.failed)
                                
                                self.updatedLevelLabel.text = String(self.cardDeck.getClearedPercentage()) + "%"
                                
                                self.timer.invalidate()
                                self.view.sendSubviewToBack(self.countDownView)
                                
                                self.resultLevelView.backgroundColor = Training.getColorByLevel(Int(self.cardDeck.currentLevel!))
                                
                                self.isStarted = false
                                self.resultView.hidden = false
                                self.resultView.animation = "squeezeUp"
                                self.resultView.duration = 1
                                
                                self.resultView.animateNext() {
                                    self.resultLevelView.hidden = false
                                    self.resultLevelView.animation = "pop"
                                    self.resultLevelView.duration = 1
                                   
                                    self.resultLevelView.animateNext(){
                                        self.restartLabel.hidden = false
                                        self.restartLabel.animation = "pop"
                                        self.restartLabel.duration = 3
                                        self.restartLabel.animateNext() {
                                            self.canRestart = true
                                        }
                                    }
                                }
                            }
                        }
                    )
                }
            }
        )
    }
    
    func nextCardAction() {
        
    }
    
    
    func updateChallengeInfo() {
        let challengedInfo = Int(self.cards[self.currentCardIndex].clearedCount!) + Int(self.cards[self.currentCardIndex].failedCount!)
        
        self.topChallengedCount.text = "\(challengedInfo) times challenged"
        self.topClearedCount.text = "\(self.cards[self.currentCardIndex].clearedCount!)"
        self.topFailedCount.text = "\(self.cards[self.currentCardIndex].failedCount!)"
    }
    func updateProgressLabel() {
        self.progressValueLabel.text = "\(self.currentCardIndex + 1) / \(self.cards.count)"
    }
    
    func getProgressValue() -> Float {
        return (Float(self.currentCardIndex + 1)) / Float(self.cards.count)
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IB Actions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    
    @IBAction func startButtonTapped(sender: AnyObject) {
        if cards.count < 1 {
            SharedController.showAlert(
                "No Card!",
                message: "There are no card which match current options you chose.\nPlease change your options on setting menu.",
                targetViewController: self)
        } else {
            start()
        }
    }
    
    @IBAction func gotItButtonTapped(sender: AnyObject) {
        answerAction(Direction.Right)
    }
    
    @IBAction func notYetButtonTapped(sender: AnyObject) {
        answerAction(Direction.Left)
    }
   
    
    
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Card Animation
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: touch began
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //print("touchesBegan")
        
        UIView.animateWithDuration(
            0.06,
            animations: { () -> Void in
                self.currentCardView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }
        )
        
    }
    
    // MARK: touching
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        let aTouch = touches.first! as UITouch
        let location = aTouch.locationInView(self.view)
        let prevLocation = aTouch.previousLocationInView(self.view)
        var myFrame: CGRect = self.currentCardView.frame
        let deltaX: CGFloat = location.x - prevLocation.x
        let deltaY: CGFloat = location.y - prevLocation.y
        myFrame.origin.x += deltaX
        myFrame.origin.y += deltaY
        self.currentCardView.frame = myFrame
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.currentCardView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        self.currentCardView.frame = self.cardView.layer.frame
        //print("touch cancelled")
    }
    
    // MARK: touch ended
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //print("touchesEnded")
        if self.currentCardView.center.x > (self.cardView.center.x + 50) {
            answerAction(Direction.Right)
        } else if self.currentCardView.center.x < (self.cardView.center.x - 50) {
            answerAction(Direction.Left)
        } else {
            
            UIView.animateWithDuration(
                0.1,
                animations: { () -> Void in
                    self.currentCardView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    self.currentCardView.frame = self.cardView.layer.frame
                }
            )
            
        }
        
    }
}
