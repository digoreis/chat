//
//  ChatRoomController.swift
//  HootsuiteChat
//
//  Created by apple on 21/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ChatRoomController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var list = [Message]()
    var typing = [Typing]()
    
    private var channel : FIRDatabaseReference? = nil {
        didSet {
            messages = channel?.child("messages")
            typings = channel?.child("typings")
        }
    }
    var chat : ChatRoom? = nil {
        didSet {
            if let item = chat {
                let database = FIRDatabase.database().reference()
                channel  =  database.child(item.chatID)
                self.title = item.title
                self.navigationItem.prompt = item.topic
            }
        }
    }
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var messageInput : UITextView?
    @IBOutlet var typingLabel : UILabel?
    @IBOutlet var sendButton : UIButton?
    @IBOutlet var keyboardICon : UIImageView?
    
    
    @IBOutlet var keyboardInputConstraint : NSLayoutConstraint?
    @IBOutlet var inputTextHeight : NSLayoutConstraint?
    @IBOutlet var viewInputTextHeight : NSLayoutConstraint?
    
    var messages : FIRDatabaseReference? = nil {
        didSet {
            let messagesQuery = messages?.queryOrderedByKey()
            messagesQuery?.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
                if let id = snapshot.value?["userName"] as? String , text = snapshot.value?["text"] as? String , sendIn = snapshot.value?["sendIn"] as? Double, avatar = snapshot.value?["avatar"] as? String {
                    self.addMessage(Message(userID : id, text : text, sendIn: sendIn, avatarURL: avatar))
                    self.tableView?.reloadData()
                    self.goToBottom()
                }
                
            }
            messagesQuery?.observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot) in
                if let text = snapshot.value?["text"] as? String {
                    for (index, element) in self.list.enumerate() {
                        if element.text == text {
                            self.list.removeAtIndex(index)
                        }
                    }
                    self.tableView?.reloadData()
                    self.goToBottom()
                }
            }
        }
    }
    
    var typings : FIRDatabaseReference? = nil {
        didSet {
            typings?.onDisconnectRemoveValue()
            let typingsQuery = typings?.queryOrderedByKey()
            typingsQuery?.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
                if let id = snapshot.value?["name"] as? String  {
                    self.typing.append(Typing(name : id, key: snapshot.key))
                    if let names = self.generateTypingString() {
                        self.typingLabel?.text = "Typing \(names)"
                        self.keyboardICon?.hidden = false
                    } else {
                        self.typingLabel?.text = ""
                        self.keyboardICon?.hidden =  true
                    }
                }
                
            }
            typingsQuery?.observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot) in
                if let text = snapshot.value?["name"] as? String {
                    for (index, element) in self.typing.enumerate() {
                        if element.name == text {
                            self.typing.removeAtIndex(index)
                            if let names = self.generateTypingString() {
                                self.typingLabel?.text = "Typing \(names)"
                                self.keyboardICon?.hidden = false
                            } else {
                                self.typingLabel?.text = ""
                                self.keyboardICon?.hidden = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func generateTypingString() -> String? {
        let arrNames = typing.flatMap({ $0.name})
        let names = arrNames.joinWithSeparator(",")
        return (names.isEmpty) ? nil : names
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomController.keyboardWasShown(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomController.keyboardHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        navigationController?.navigationBar.topItem?.title = " "
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        goToBottom()
        commandButtons()
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 280.0
        let origImage = UIImage(named: "speech-ballon");
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        sendButton?.setImage(tintedImage, forState: .Normal)
        sendButton?.tintColor = UIColor.whiteColor()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        stopTyping(FIRAuth.auth()?.currentUser?.displayName ?? "Anonymous")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func commandButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: #selector(ChatRoomController.changeTopic(_:)))
    }
    
    func changeTopic(sender : AnyObject?) {
        let alert = UIAlertController(title: "Topic", message: "Change chat topic : ", preferredStyle:
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
        navigationItem.prompt = value
        channel?.updateChildValues(["topic" : value])
    }
    
    private func configurationTextField(textField: UITextField!)
    {
        if let aTextField = textField {
            aTextField.placeholder = "New topic"
        }
    }
    

    private func addMessage(message : Message) {
        list.append(message)
        tableView?.beginUpdates()
        tableView?.insertRowsAtIndexPaths([
            NSIndexPath(forRow: list.count-1, inSection: 0)
            ], withRowAnimation: .Automatic)
        tableView?.endUpdates()
        messageInput?.resignFirstResponder()
        messageInput?.text = "Say anything ..."
        inputTextHeight?.constant = 30
        viewInputTextHeight?.constant = 50
        goToBottom()
    }
    
    func startTyping(name : String) {
        
        if let itemRef = typings?.childByAutoId() {
            let messageItem = [
                "name": name
            ]
            itemRef.setValue(messageItem)
        }
    }
    
    func stopTyping(name : String) {
        if let item = typing.filter({ $0.name == name}).first {
            let delete = typings?.child(item.key)
            delete?.removeValue()
        }
    }
    
    @IBAction func includeNewMessage(sender : AnyObject? ){
        if let text = messageInput?.text, itemRef = messages?.childByAutoId()  where text != "Say anything ..." {
            let messageItem = [
                "text": text,
                "userName": FIRAuth.auth()?.currentUser?.displayName ?? FIRAuth.auth()?.currentUser?.email ?? "Anonymous",
                "userID": FIRAuth.auth()?.currentUser?.email ?? "anonymous@anonymous.com",
                "avatar" : FIRAuth.auth()?.currentUser?.photoURL?.absoluteString ?? "NO-IMAGE",
                "sendIn": NSDate().timeIntervalSince1970
            ]
            itemRef.setValue(messageItem)
        } else {
            messageInput?.resignFirstResponder()
        }
    }
    
    

    
    
}
