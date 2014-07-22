//
//  InfoViewController.swift
//  IsFollowing
//
//  Created by Natalia Ossipova on 07.07.2014.
//  Copyright (c) 2014 Natalia Ossipova. All rights reserved.
//

import UIKit
import Foundation

class InfoViewController: UIViewController {

    @IBOutlet var version: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if (countElements(version.text!) == 0) {
            version.text = NSLocalizedString("Version", comment: "Version") + (NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"]! as String)
        }

        let recognizer = UISwipeGestureRecognizer(target:self, action:Selector("dismiss"))
        recognizer.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(recognizer)
    }

    //    #pragma mark - Interface Builder Actions

    func openHomepage(sender: AnyObject) {
        let url = NSURL(scheme:"http", host:"www.nataliaossipova.net", path:"/")
        UIApplication.sharedApplication().openURL(url)
    }

    func openTwitter(sender: AnyObject) {
        let application = UIApplication.sharedApplication()

        let twitterURL = NSURL(string:"twitter://user?screen_name=nossipova")
        if application.canOpenURL(twitterURL) {
            application.openURL(twitterURL)
            return
        }

        let tweetbotURL = NSURL(string:"tweetbot:///user_profile/nossipova")
        if application.canOpenURL(tweetbotURL) {
            application.openURL(tweetbotURL)
            return
        }

        let webURL = NSURL(string:"http://www.twitter.com/nossipova")
        application.openURL(webURL)
    }

    //    #pragma mark - Controller logic methods

    func dismiss() {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
}