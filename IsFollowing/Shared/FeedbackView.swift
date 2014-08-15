//
//  FeedbackView.swift
//  IsFollowing
//
//  Created by Natalia Ossipova on 09.07.2014.
//  Copyright (c) 2014 Natalia Ossipova. All rights reserved.
//

import UIKit

class FeedbackView: UIView {

    let fontSize: CGFloat = 14.0
    let horizontalPadding: CGFloat = 40.0
    let verticalPadding: CGFloat = 30.0

    let controlView: UIControl
    var message: String = ""
    var showSpinner: Bool = false

    required init(coder aDecoder: NSCoder!) {
        controlView = UIControl(frame: CGRectZero)
        super.init(coder: aDecoder)
        controlView = UIControl(frame: frame)
    }

    override init(frame: CGRect) {
        controlView = UIControl(frame: frame)
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        controlView.backgroundColor = UIColor.clearColor()
    }

    class func feedback(message: String) -> FeedbackView {
        let feedbackView = FeedbackView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        feedbackView.message = message
        return feedbackView
    }

    class func showFeedback(message: String, showSpinner: Bool) -> FeedbackView {
        let feedbackView = feedback(message)
        feedbackView.showSpinner = showSpinner
        UIApplication.sharedApplication().delegate.window!!.addSubview(feedbackView)
        return feedbackView
    }

    class func showFeedback(message: String) -> FeedbackView {
        return showFeedback(message, showSpinner: false)
    }

    class func showProgressFeedback(message: String) -> FeedbackView {
        return showFeedback(message, showSpinner: true)
    }

    class func showInteractiveFeedback(message: String) {
        let feedbackView = feedback(message)
        feedbackView.addTarget(feedbackView, action:Selector("dismiss"), controlEvents:UIControlEvents.TouchDown)
        UIApplication.sharedApplication().delegate.window!!.addSubview(feedbackView)
    }

    class func showSelfDismissingFeedback(message: String) {
        let feedbackView = feedback(message)
        UIApplication.sharedApplication().delegate.window!!.addSubview(feedbackView)
        feedbackView.dismissAfterDelay(3.0)
    }

    func addTarget(target: AnyObject, action: Selector, controlEvents: UIControlEvents) {
        controlView.addTarget(target, action:action, forControlEvents:controlEvents)
    }

    func dismissAfterDelay(delay: NSTimeInterval) {
        UIView.animateWithDuration(0.5, delay: delay, options: UIViewAnimationOptions.CurveEaseOut|UIViewAnimationOptions.AllowUserInteraction, animations:
            {
                self.alpha = 0.0
            }, completion:
            {_ in
                self.removeFromSuperview()
            })
    }

    func dismiss() {
        dismissAfterDelay(NSTimeInterval(0.0))
    }

    func textSize(text: String) -> CGSize {
        return (text as NSString).boundingRectWithSize(CGSizeMake(220.0, 9999.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize), NSForegroundColorAttributeName: UIColor.whiteColor()], context: nil).size
    }

    override func drawRect(rect: CGRect) {
        let computedTextSize = textSize(message)

        var spinner: UIActivityIndicatorView!
        var backgroundFrame: CGRect!
        if showSpinner {
            spinner = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.White)
            backgroundFrame = CGRectMake(0.0, 0.0, computedTextSize.width + horizontalPadding, computedTextSize.height + 2.0 * verticalPadding + spinner.frame.size.height)
        } else {
            backgroundFrame = CGRectMake(0.0, 0.0, computedTextSize.width + horizontalPadding, computedTextSize.height + verticalPadding)
        }

        let labelBackground = UIView(frame: backgroundFrame)
        labelBackground.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        labelBackground.layer.cornerRadius = 5.0
        labelBackground.layer.masksToBounds = true
        labelBackground.center = center
        addSubview(labelBackground)

        let label = UILabel(frame: CGRectMake(0.0, 0.0, computedTextSize.width, computedTextSize.height))
        label.text = message
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(fontSize)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()

        if showSpinner {
            spinner.frame.origin.x = center.x - spinner.frame.size.width / 2.0
            spinner.frame.origin.y = CGRectGetMaxY(labelBackground.frame) - 0.8 * verticalPadding - spinner.frame.size.height
            spinner.startAnimating()
            addSubview(spinner)
            label.center = CGPointMake(center.x, CGRectGetMaxY(labelBackground.frame) - 1.4 * verticalPadding - spinner.frame.size.height - label.frame.size.height / 2.0)
        } else {
            label.center = center
        }
        
        addSubview(label)
        addSubview(controlView)
    }
}
