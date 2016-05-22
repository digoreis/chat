//
//  ViewController.swift
//  HootsuiteChat
//
//  Created by apple on 21/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Haneke

struct Channel {
    let key : String
    let id : String
    let name : String
    let topic : String
}

class MainViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet var textNameChannel : UITextField?
    @IBOutlet var footerView : UIView?
    @IBOutlet var tableView : UITableView?
    
    @IBOutlet var keyboardInputConstraint : NSLayoutConstraint?
    
    var numberChannel = 0
    var list  = [Channel]()
    var channels : FIRDatabaseReference? = nil {
        didSet {
            let messagesQuery = channels?.queryOrderedByKey()
            messagesQuery?.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
                if let id = snapshot.value?["senderId"] as? String , text = snapshot.value?["text"] as? String {
                    let topic = snapshot.value?["topic"] as? String ?? "No have topic description"
                    self.addChannel(Channel(key: snapshot.key,id : id, name : text, topic: topic))
                }
                
            }
            
            messagesQuery?.observeEventType(.ChildChanged) { (snapshot: FIRDataSnapshot) in
                if let key = snapshot.value?["text"] as? String , topic = snapshot.value?["topic"] as? String {
                    for (index, element) in self.list.enumerate() {
                        if element.name == key {
                            let item = self.list.removeAtIndex(index)
                            self.tableView?.reloadData()
                            self.addChannel(Channel(key: item.key, id: item.id, name: item.name, topic: topic))
                        }
                    }
                    
                }
                
            }
            messagesQuery?.observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot) in
                if let text = snapshot.value?["text"] as? String {
                    for (index, element) in self.list.enumerate() {
                        if element.name == text {
                            self.list.removeAtIndex(index)
                        }
                    }
                    self.tableView?.reloadData()
                }
            }

        }
    }

    private func commandButtons() {
        let right = UIBarButtonItem(image: UIImage(named: "shutdown"), style: .Plain, target: self, action: #selector(MainViewController.logout(_:)))
        right.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = right
    }
    
    func logout(sender : AnyObject?) {
        try! FIRAuth.auth()!.signOut()
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as? LoginController {
            self.navigationController?.presentViewController(vc, animated: true, completion: nil)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let database = FIRDatabase.database().reference()
        channels  =  database.child("channels")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardWasShown(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        commandButtons()
        if FIRAuth.auth()?.currentUser?.providerID.containsString("twitter") ?? false {
            twitterEmail(self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "Channels"
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0 : return list.count
            default : return 0
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell") as? ChannelCell ?? ChannelCell(style: .Subtitle , reuseIdentifier: "ChannelCell")
        cell.fill(list[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let item = list[indexPath.row]
            let database = FIRDatabase.database().reference()
            let messages  =  database.child("channels/\(item.key)/messages")
            let typings  =  database.child("channels/\(item.key)/typings")
            let storyboard = UIStoryboard(name: "ChatRoom", bundle: nil)
            if let vc = storyboard.instantiateViewControllerWithIdentifier("ChatVC") as? ChatRoomController {
                vc.messages = messages
                vc.typings = typings
                vc.title = item.name
                vc.channelKey = item.key
                vc.navigationItem.prompt = item.topic
                self.navigationController?.pushViewController(vc, animated: true)
            }
    }
    
    private func addChannel(channel : Channel) {
        list.append(channel)
        tableView?.beginUpdates()
        tableView?.insertRowsAtIndexPaths([
            NSIndexPath(forRow: list.count-1, inSection: 0)
            ], withRowAnimation: .Automatic)
        tableView?.endUpdates()
        textNameChannel?.resignFirstResponder()
        textNameChannel?.text = nil
    }
    
    @IBAction func includeNewChannel(sender : AnyObject? ){
        if let name = textNameChannel?.text, itemRef = channels?.childByAutoId() {
            let prepName = name.stringByReplacingOccurrencesOfString(" ", withString: "").lowercaseString
            let messageItem = [
                "text": prepName,
                "senderId": FIRAuth.auth()?.currentUser?.displayName ?? FIRAuth.auth()?.currentUser?.email ?? "Anonymous",
                "userID": FIRAuth.auth()?.currentUser?.email ?? "anonymous@anonymous.com",
                "topic": "No have topic description" //TODO: Put Name of USER
            ]
            itemRef.setValue(messageItem)
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.keyboardInputConstraint?.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.keyboardInputConstraint?.constant = 0
        })
    }

    //TWITTER
    func twitterEmail(sender : AnyObject?) {
        let alert = UIAlertController(title: "Twitter", message: "Sorry :( , but We need your e-mail. We don't send spam. ", preferredStyle:
            UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            if let text = alert.textFields?[0].text {
                self.changeValueTopic(text)
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    private func changeValueTopic(value : String){
        FIRAuth.auth()?.currentUser?.updateEmail(value, completion: nil)
    }
    
    private func configurationTextField(textField: UITextField!)
    {
        if let aTextField = textField {
            aTextField.placeholder = "New topic"
        }
    }

}

