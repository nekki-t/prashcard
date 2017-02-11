//
//  AddCardDeckViewController.swift
//  PrashCard
//
//  Created by nekki t on 2016/05/06.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// MARK: - Protocol
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
protocol AddCardDeckViewControllerDelegate: class {
    func addCardDeck(sender: AnyObject)
}
// MARK: - Clas Start
class AddCardDeckViewController: UIViewController, UITextFieldDelegate {
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlets
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cardDeckNameTextField: UITextField!
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: buttons
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var createButton: BorderedButton!
    @IBOutlet weak var cancelButton: BorderedButton!
    
    weak var delegate: AddCardDeckViewControllerDelegate?
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Life Cycle
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cardDeckNameTextField.becomeFirstResponder()
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
    
    
    // MARK: - IBOutlets
    func backToTop () {
        closeAction()
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - View Functions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func configureUI () {
        modalView.transform = CGAffineTransformMakeTranslation(0, 600)
        // Modal view setting
        modalView.layer.shadowColor = UIColor.blackColor().CGColor
        modalView.layer.shadowOffset = CGSize(width: 1.1, height: 1.1)
        modalView.layer.shadowOpacity = 1
        
        // Background view(for lock)
        let tapRecognizerToBack = UITapGestureRecognizer(target: self, action: #selector(backToTop))
        tapRecognizerToBack.numberOfTapsRequired = 1
        
        backgroundView.userInteractionEnabled = true
        backgroundView.addGestureRecognizer(tapRecognizerToBack)
        // Prepare for animation -> Background lock view
        backgroundView.alpha = 0
        
        // Configure CancelButton
        cancelButton.backgroundColor = SharedViewValues.getLightOrangeColor()
        cancelButton.highlightedBackingColor = SharedViewValues.getDarkOrangeColor()
        cancelButton.backingColor = SharedViewValues.getLightOrangeColor()
        
        // Text Field
        cardDeckNameTextField.delegate = self
    }
    
    func closeAction() {
        cardDeckNameTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBActions
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBAction func createButtunTapped(sender: AnyObject) {
        cardDeckNameTextField.text = cardDeckNameTextField.text?.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        if let name = cardDeckNameTextField.text {
            if CardDeck.nameExists(name) {
                // Same name must be rejected
                return SharedController.showAlert("Card Deck Name", message: "The name you input is already in use.", targetViewController: self)
            } else if name.length > 30 {
                // Same name must be rejected
                return SharedController.showAlert("Card Deck Name", message: "Please input the name in less than 30 characters.",
                targetViewController: self)
            
            } else if !name.isEmpty {
                // save record to care data
                delegate?.addCardDeck(cardDeckNameTextField.text!)
                closeAction()
                return
            }
        }
        SharedController.showAlert("Card Deck Name", message: "Please input the name!", targetViewController: self)
    }
    
    @IBAction func cancelButtnTapped(sender: AnyObject) {
        closeAction()
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - textField delegate
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}
