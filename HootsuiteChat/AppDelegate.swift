//
//  AppDelegate.swift
//  HootsuiteChat
//
//  Created by apple on 21/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import TwitterKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()!.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        Twitter.sharedInstance().startWithConsumerKey("lCN30gPXlT77AcdkJQPEwLeEG", consumerSecret: "JnLnVU6OrtSeUt2bCTgegWtguLLWHIEdWxvYtoZlRKMC7WjJGX")
    
        
        if FIRAuth.auth()?.currentUser == nil {
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let mainStoryboard = UIStoryboard(name: "Login", bundle: nil)
            window?.rootViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginVC")
            window?.makeKeyAndVisible()
        } else {
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainVC")
            window?.makeKeyAndVisible()
        }
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    //GOOGLE
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                     accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            print(error?.description)
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let  vc = mainStoryboard.instantiateViewControllerWithIdentifier("MainVC") as? MainViewController {
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

