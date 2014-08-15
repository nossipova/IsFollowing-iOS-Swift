//
//  TwitterCommunicator.swift
//  IsFollowing
//
//  Created by Natalia Ossipova on 07.07.2014.
//  Copyright (c) 2014 Natalia Ossipova. All rights reserved.
//

import Foundation
import Accounts
import Social

class TwitterCommunicator {

    func sendRequestWithSourceName(sourceName: String, targetName: String) {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

        accountStore.requestAccessToAccountsWithType(accountType, options:nil, completion:
            {granted, error in
                if (granted) {
                    let accounts = accountStore.accountsWithAccountType(accountType)
                    if accounts.count > 0 {
                        let request = SLRequest(forServiceType:SLServiceTypeTwitter, requestMethod:SLRequestMethod.GET, URL:NSURL(string:"https://api.twitter.com/1.1/friendships/show.json"), parameters:["source_screen_name": sourceName, "target_screen_name": targetName])

                        // We can use an arbitrary account here because we are not tweeting.
                        request.account = accounts[0] as ACAccount

                        request.performRequestWithHandler(
                            {responseData, urlResponse, error in
                                var jsonParsingError: NSError?
                                if urlResponse.statusCode == 200 {
                                    let resultObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(responseData, options:NSJSONReadingOptions.AllowFragments, error:&jsonParsingError)
                                    let number = resultObject.valueForKeyPath("relationship.source.following") as? NSNumber
                                    var result: Bool
                                    if number != nil {
                                        result = number!.integerValue == 1 ? true: false
                                    } else {
                                        result = false
                                    }
                                    dispatch_async(dispatch_get_main_queue(), {
                                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.DidReceiveResult.toRaw(), object:self, userInfo:[NotificationObject.Result.toRaw(): result])
                                        })
                                } else {
                                    var parsingError: NSError?
                                    let result: AnyObject! = NSJSONSerialization.JSONObjectWithData(responseData, options:NSJSONReadingOptions.MutableContainers, error:&parsingError)
                                    var message: String!
                                    if parsingError != nil || result == nil {
                                        message = "Twitter replied with gibberish."
                                    } else {
                                        message = result.valueForKeyPath("errors.message").componentsJoinedByString("\n")
                                    }
                                    dispatch_async(dispatch_get_main_queue(), {
                                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.DidFailWithError.toRaw(), object:self, userInfo:[NotificationObject.Error.toRaw(): message])
                                        })
                                }
                            })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            NSNotificationCenter.defaultCenter().postNotificationName(Notification.DidFailWithError.toRaw(), object:self, userInfo:[NotificationObject.Error.toRaw(): "No Twitter accounts found. To add a Twitter account, please go to Settings -> Twitter -> Add Account"])
                            })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.DidFailWithError.toRaw(), object:self, userInfo:[NotificationObject.Error.toRaw(): "Access to Twitter accounts is not granted. To change this, please go to Settings and tap Privacy -> Twitter -> Is Following?"])
                        })
                }
            }
        )
    }
    
}