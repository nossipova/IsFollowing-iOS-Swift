//
//  CheckViewController.swift
//  IsFollowing
//
//  Created by Natalia Ossipova on 07.07.2014.
//  Copyright (c) 2014 Natalia Ossipova. All rights reserved.
//

import UIKit

class CheckViewController: UIViewController {

    let snapThreshold: CGFloat = 20.0
    let userDefaultsHideAnimation = "UserDefaultsHideAnimation"

    @IBOutlet var firstTextField: PositionAwareTextField!
    @IBOutlet var secondTextField: PositionAwareTextField!
    @IBOutlet var checkButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var resultView: ResultView!
    @IBOutlet var firstTextFieldTopSpace: NSLayoutConstraint!
    @IBOutlet var secondTextFieldTopSpace: NSLayoutConstraint!

    var twitterCommunicator: TwitterCommunicator!

    //    #pragma mark - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        twitterCommunicator = TwitterCommunicator()

        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("didReceiveResult:"), name:Notification.DidReceiveResult.toRaw(), object:twitterCommunicator)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("didFailWithError:"), name:Notification.DidFailWithError.toRaw(), object:twitterCommunicator)

        let firstGestureRecognizer = UIPanGestureRecognizer(target:self, action:Selector("swapTextFields:"))
        firstGestureRecognizer.maximumNumberOfTouches = 1
        firstTextField.addGestureRecognizer(firstGestureRecognizer)

        let secondGestureRecognizer = UIPanGestureRecognizer(target:self, action:Selector("swapTextFields:"))
        secondGestureRecognizer.maximumNumberOfTouches = 1
        secondTextField.addGestureRecognizer(secondGestureRecognizer)

        firstTextField.becomeFirstResponder()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        firstTextField.originalPosition = firstTextField.center
        secondTextField.originalPosition = secondTextField.center
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:Notification.DidReceiveResult.toRaw(), object:twitterCommunicator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:Notification.DidFailWithError.toRaw(), object:twitterCommunicator)
    }

    //    #pragma mark - Interface Builder actions

    func check(sender: AnyObject) {
        if bothTextFieldsFilled() {
            backgroundTap(sender)
            spinner.startAnimating()
            resultView.hidden = true

            var sourceName: String!
            var targetName: String!
            if firstTextField.isAboveTextField(secondTextField) {
                sourceName = firstTextField.text
                targetName = secondTextField.text
            } else {
                sourceName = secondTextField.text
                targetName = firstTextField.text
            }
            twitterCommunicator.sendRequestWithSourceName(sourceName, targetName:targetName)
        }
    }

    func backgroundTap(sender: AnyObject) {
        firstTextField.resignFirstResponder()
        secondTextField.resignFirstResponder()
    }

    func textChanged(sender: AnyObject) {
        if bothTextFieldsFilled() {
            checkButton.enabled = true
        } else {
            checkButton.enabled = false
        }
    }

    //    #pragma mark - Controller logic methods

    func panView(panGestureRecognizer: UIPanGestureRecognizer) {
        let view = panGestureRecognizer.view
        let translation = panGestureRecognizer.translationInView(view.superview)
        view.center = CGPointMake(view.center.x, view.center.y + translation.y)
        panGestureRecognizer.setTranslation(CGPointZero, inView:view.superview)
    }

    func swapOriginalPositions() {
        let temporarilyCoordinates = firstTextField.originalPosition!
        firstTextField.originalPosition = secondTextField.originalPosition!
        secondTextField.originalPosition = temporarilyCoordinates

        let temporarilyTopSpace = firstTextFieldTopSpace.constant
        firstTextFieldTopSpace.constant = secondTextFieldTopSpace.constant
        secondTextFieldTopSpace.constant = temporarilyTopSpace
    }

    func swapPositions() {
        swapOriginalPositions()
        firstTextField.center = CGPointMake(firstTextField.originalPosition!.x, firstTextField.originalPosition!.y)
        secondTextField.center = CGPointMake(secondTextField.originalPosition!.x, secondTextField.originalPosition!.y)
    }

    func adjustAttributes() {
        let returnKeyType = firstTextField.returnKeyType
        firstTextField.returnKeyType = secondTextField.returnKeyType
        secondTextField.returnKeyType = returnKeyType

        let placeholder = firstTextField.placeholder
        firstTextField.placeholder = secondTextField.placeholder
        secondTextField.placeholder = placeholder

        if firstTextField.isFirstResponder() {
            firstTextField.resignFirstResponder()
            firstTextField.becomeFirstResponder()
        }
        if secondTextField.isFirstResponder() {
            secondTextField.resignFirstResponder()
            secondTextField.becomeFirstResponder()
        }
    }

    func swapTextFields(gestureRecongnizer: UIGestureRecognizer) {
        let panGestureRecognizer = gestureRecongnizer as UIPanGestureRecognizer
        if panGestureRecognizer.state == UIGestureRecognizerState.Began || panGestureRecognizer.state == UIGestureRecognizerState.Changed {
            panView(panGestureRecognizer)
        }
        if panGestureRecognizer.state == UIGestureRecognizerState.Changed || panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            if fabs(firstTextField.center.y - secondTextField.center.y) < snapThreshold {
                swapOriginalPositions()
                UIView.animateWithDuration(0.5, delay:0.0, options:UIViewAnimationOptions.TransitionCrossDissolve|UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        if panGestureRecognizer.view === self.firstTextField {
                            self.secondTextField.center = CGPointMake(self.secondTextField.originalPosition!.x, self.secondTextField.originalPosition!.y)
                        } else {
                            self.firstTextField.center = CGPointMake(self.firstTextField.originalPosition!.x, self.firstTextField.originalPosition!.y)
                        }
                    }, completion:
                    {_ in
                        self.adjustAttributes()
                    }
                )
            }
        }
        if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.5, delay:0.0, options:UIViewAnimationOptions.TransitionCrossDissolve|UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.firstTextField.center = CGPointMake(self.firstTextField.originalPosition!.x, self.firstTextField.originalPosition!.y)
                    self.secondTextField.center = CGPointMake(self.secondTextField.originalPosition!.x, self.secondTextField.originalPosition!.y)
                }, completion:nil
            )
        }
    }

    func bothTextFieldsFilled() -> Bool {
        return countElements(firstTextField.text!) > 0 && countElements(secondTextField.text!) > 0
    }

    func showAnimation() {
        UIView.animateWithDuration(2.0, delay:1.0, options:UIViewAnimationOptions.TransitionCrossDissolve|UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.swapPositions()
            }, completion:
            {_ in
                self.adjustAttributes()
            })
    }

    func shouldShowAnimation() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey(userDefaultsHideAnimation)
    }

    func hideAnimation() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey:userDefaultsHideAnimation)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func didReceiveResult(notification: NSNotification) {
        let result: AnyObject? = notification.userInfo[NotificationObject.Result.toRaw()]
        resultView.result = result as Bool
        resultView.hidden = false
        resultView.setNeedsDisplay()
        spinner.stopAnimating()

        if shouldShowAnimation() {
            showAnimation()
            hideAnimation()
        }
    }

    func didFailWithError(notification: NSNotification) {
        let error: AnyObject! = notification.userInfo[NotificationObject.Error.toRaw()]
        spinner.stopAnimating()
        FeedbackView.showSelfDismissingFeedback(error as String)
    }

    //    #pragma mark - Text Field Delegate methods

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === self.firstTextField) {
            if firstTextField.isAboveTextField(secondTextField) {
                secondTextField.becomeFirstResponder()
            } else {
                check(textField)
            }
        } else {
            if firstTextField.isAboveTextField(secondTextField) {
                check(textField)
            } else {
                firstTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
}