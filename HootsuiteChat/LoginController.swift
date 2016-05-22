//
//  LoginController.swift
//  HootsuiteChat
//
//  Created by apple on 21/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import FirebaseAuth
import TwitterKit
import TwitterCore


class LoginController : UIViewController,GIDSignInUIDelegate , FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var signInButton: GIDSignInButton?
    @IBOutlet weak var signInButtonTwitter: TWTRLogInButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        createTwitterButton()
        //createFacebookButton() PROBLEMS WORK IN SIMULATOR
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
        if let error = error {
            print(error.description)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                     accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            self.goToApp()
        }
    }
    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        if let error = error {
            print(error.description)
            return
        }
        
        let authentication = signIn.currentUser.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                     accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            self.goToApp()
        }

    }
    
    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    
    func createTwitterButton() {
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                if let authToken = session?.authToken, authTokenSecret = session?.authTokenSecret {
                    let credential = FIRTwitterAuthProvider.credentialWithToken(authToken, secret: authTokenSecret)
                    FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                        self.goToApp()
                    }
                }
            } else {
                
            }
        })
        logInButton.frame = signInButton?.frame ?? logInButton.frame
        logInButton.frame.size = CGSize(width: 230, height: 40)
        logInButton.frame.origin.y = view.center.y + 30
        logInButton.frame.origin.x = view.center.x - 115
        signInButtonTwitter = logInButton
        self.view.addSubview(logInButton)
    }
    
    func createFacebookButton() {
        let loginButton = FBSDKLoginButton()
        loginButton.frame = signInButtonTwitter?.frame ?? loginButton.frame
        loginButton.frame.size = CGSize(width: 230, height: 40)
        loginButton.frame.origin.y = loginButton.frame.origin.y + 60
        loginButton.frame.origin.x = view.center.x - 115
        loginButton.delegate = self
        view.addSubview(loginButton)    
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if let token = FBSDKAccessToken.currentAccessToken().tokenString {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token)
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                self.goToApp()
            }
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    private func goToApp(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let  vc = mainStoryboard.instantiateViewControllerWithIdentifier("MainVC") as? UINavigationController {
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}
