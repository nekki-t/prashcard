//
//  CardViewController.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/23.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// MARK: - Protocol
protocol CardViewControllerDelegate: class {
    func cardEditEnded(targetCard: Card)
}
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// MARK: - Class starts
class CardViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Delegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    weak var delegate: CardViewControllerDelegate?
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    var cardDeck: CardDeck!
    var card: Card?
    var indicator: UIActivityIndicatorView?
    
    var placeHolderTextForBack = "Input the meaning for the word in your own language. \r\nYou can also get help from WORDS API. \r\nShorter input will be prefered for you to master it more easily."
    
    // For keyboard setting
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlets
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var frontTextView: SpringView!
    @IBOutlet weak var backTextView: SpringView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var inputFrontText: UITextField!
    @IBOutlet weak var inputBackText: UITextView!
    @IBOutlet weak var cancelButton: BorderedButton!
    @IBOutlet weak var getWordsApiButton: BorderedButton!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Life Cycle
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedViewFunctions.setShadow(frontTextView.layer)
        SharedViewFunctions.setShadow(backTextView.layer)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1

        configureUI()
        setValues()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDissmissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        keyboardWillHide()
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        frontTextView.animate()
        backTextView.animate()
        
        // Background lock
        UIView.animateWithDuration(0.3, animations: {
            self.backgroundView.alpha = 0.6
        })
    }
    

   
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Local Functions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // if text is empty, show guide
    func recoverTextViewGuide() {
        if inputBackText.text == "" {
            inputBackText.text = placeHolderTextForBack
            inputBackText.textColor = UIColor.grayColor()
        }
    }
    
    func configureUI() {
        
        // Configure saveButton
        getWordsApiButton.backgroundColor = SharedViewValues.getMaterialGreenColor()
        getWordsApiButton.highlightedBackingColor = SharedViewValues.getMaterialGreenColor()
        getWordsApiButton.backingColor = SharedViewValues.getMaterialGreenColor()

        // Configure cancelButton
        cancelButton.backgroundColor = SharedViewValues.getLightOrangeColor()
        cancelButton.highlightedBackingColor = SharedViewValues.getDarkOrangeColor()
        cancelButton.backingColor = SharedViewValues.getLightOrangeColor()
        
        // Configure input controls
        inputFrontText.layer.borderWidth = 0.5
        inputFrontText.layer.borderColor = UIColor.lightGrayColor().CGColor
        inputFrontText.layer.cornerRadius = 1
        inputFrontText.delegate = self
        
        inputBackText.textColor = UIColor.grayColor()
        inputBackText.delegate = self
        inputBackText.layer.borderWidth = 0.5
        inputBackText.layer.borderColor = UIColor.lightGrayColor().CGColor
        inputBackText.layer.cornerRadius = 1
    }
    
    func setValues () {
        if let cd = card {
            inputFrontText.text = cd.frontText
            if cd.backText != "" {
                inputBackText.text = cd.backText
                inputBackText.textColor = UIColor.blackColor()
            } else {
                inputBackText.text = placeHolderTextForBack
                
            }
        } else {
            inputBackText.text = placeHolderTextForBack
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - textFieldDelegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        inputFrontText.resignFirstResponder()
        return true
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - textViewDelegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // clear if text is the guide text
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == placeHolderTextForBack {
            textView.text = ""
        }
        textView.textColor = UIColor.blackColor()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    

    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBActions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBAction func saveButtonTapped(sender: AnyObject) {
        let frontText = inputFrontText.text?.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        let backText = inputBackText.text?.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        var msg = ""
        let invalidBackText = backText == "" || backText == placeHolderTextForBack
        
        if frontText == "" && invalidBackText {
            msg = "Please enter the word and the meaning."
        } else if frontText == "" {
            msg = "Please enter the word."
        } else if invalidBackText {
            msg = "Please enter the meaning."
        } else {
            // Both are input
            if frontText?.length > Card.FrontTextLength {
                msg = "The word length must be less than \(Card.FrontTextLength)."
            } else if backText?.length > Card.BackTextLength {
                msg = "The meaning is bit too long. Please make it less than \(Card.BackTextLength) characters."
            }
        }
        
        if msg != "" {
            SharedController.showAlert("Input Error!", message: msg, targetViewController: self)
        } else if let targetCard = card {
            if frontText != targetCard.frontText {
                // if changed, need check existance
                if let _ = cardDeck.getTargetCard(frontText!) {
                    SharedController.showAlert("Invalid!", message: "The word has already existed in this card deck.", targetViewController: self)
                    return
                }
            }
            targetCard.frontText = frontText
            targetCard.backText = backText
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.CardDeckChangedNotification, object: Training.Level.White.rawValue)
            
            self.delegate?.cardEditEnded(targetCard)
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            // new card
            if let _ = cardDeck.getTargetCard(frontText!) {
                SharedController.showAlert("Invalid!", message: "The word has already existed in this card deck.", targetViewController: self)
                return
            }
            
            let newCard = Card(parentCardDeck: cardDeck, context: sharedContext)
            newCard.prepareForNewCard(frontText, backTextInput: backText)
            newCard.cardDeck!.whiteCount = NSNumber(integer: Int(newCard.cardDeck!.whiteCount!) + 1)
            newCard.cardDeck!.cardCount = NSNumber(integer: Int(newCard.cardDeck!.cardCount!) + 1)
            newCard.cardDeck!.updateLevel()
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.CardDeckChangedNotification, object: Training.Level.White.rawValue)
            
            self.delegate?.cardEditEnded(newCard)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func getWordsApiButtonTapped(sender: AnyObject) {
        
        inputFrontText.text = inputFrontText.text?.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        if inputFrontText.text == "" {
            SharedController.showAlert("No Word!", message: "Please input a word.", targetViewController: self)
            return
        }
        
        view.endEditing(true)
        showIndicator()
        let apiClient = EnglishDictionaryClient.sharedInstance()
        apiClient.getDefinitionOftheWord(inputFrontText.text!) {
            success, error in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.hideIndicator()
                    self.inputBackText.text = EnglishDictionaryResult.getResultString(apiClient.apiResult!)
                    self.inputBackText.textColor = UIColor.blackColor()
                } else {
                    
                    SharedController.showAlert("API Error!", message: error, targetViewController: self)
                    self.hideIndicator()
                }
            })
        }
        
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Keyboard Dismiss
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func addKeyboardDissmissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        inputBackText.editable = true
        view.endEditing(true)
    }
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Keyboard Settings
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide),
                                                         name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false && inputBackText.isFirstResponder(){
            print(lastKeyboardOffset)
            lastKeyboardOffset = getKeyboardHeight(notification)
            print(lastKeyboardOffset)
            view.frame.origin.y -= lastKeyboardOffset
            //view.superview?.superview?.frame.origin.y -= lastKeyboardOffset

            keyboardAdjusted = true
        }
        
    }
    
    func keyboardWillHide() {
        if keyboardAdjusted == true {
            view.frame.origin.y += lastKeyboardOffset
            //view.superview?.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        inputBackText.editable = false
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        inputBackText.editable = true
    }

    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Visual Effect -> Indicator
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func showIndicator() {
        
        if let window = UIApplication.sharedApplication().keyWindow {
            self.indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
            self.indicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            if let loading = self.indicator {
                loading.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
                loading.color = UIColor.blackColor()
                self.view.userInteractionEnabled = false
                window.addSubview(loading)
                loading.startAnimating()
            }
        }
    }
    
    func hideIndicator() {
        if let loading = self.indicator {
            loading.removeFromSuperview()
            self.view.userInteractionEnabled = true
            self.indicator = nil
        }
    }

  
}
