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


struct Message {
    let userID : String
    let text : String
    let sendIn : Double
    let avatarURL : String
}

struct Typing {
    let name : String
    let key : String
}
class ChatRoomController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var list = [Message]()
    var typing = [Typing]()
    
    private var channel : FIRDatabaseReference? = nil
    var channelKey : String? = nil {
        didSet {
            let database = FIRDatabase.database().reference()
            channel  =  database.child("channels/\(channelKey!)")
        }
    }
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var messageInput : UITextView?
    @IBOutlet var typingLabel : UILabel?
    @IBOutlet var sendButton : UIButton?
    
    
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
                    } else {
                        self.typingLabel?.text = ""
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
                            } else {
                                self.typingLabel?.text = ""
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
        tableView?.estimatedRowHeight = 160.0
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatTextCell") as? ChatTextCell ?? ChatTextCell(style: .Subtitle, reuseIdentifier: "ChatTextCell")
        cell.fill(list[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        goToBottom()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
        goToBottom()
    }
    
    private func startTyping(name : String) {
        
        if let itemRef = typings?.childByAutoId() {
            let messageItem = [
                "name": name
            ]
            itemRef.setValue(messageItem)
        }
    }
    
    private func stopTyping(name : String) {
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
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.keyboardInputConstraint?.constant = keyboardFrame.size.height
        }) { status in
            if status {
                self.goToBottom()
            }
        }
    }
    
    func keyboardHide(notification: NSNotification) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.keyboardInputConstraint?.constant = 0
        }) { status in
            if status {
                self.goToBottom()
            }
        }
        
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect.zero)
        headerView.userInteractionEnabled = false
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let size = tableView.frame.height -  CGFloat(list.count * 100)
        return size
    }
    
    
    private func goToBottom(){
            tableView?.scrollToBottom()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
        startTyping(FIRAuth.auth()?.currentUser?.displayName ?? "Anonymous")
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Say anything ..."
        }
        stopTyping(FIRAuth.auth()?.currentUser?.displayName ?? "Anonymous")
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let changeValue = textView.contentSize.height  - (inputTextHeight?.constant ?? 0)
        inputTextHeight?.constant = textView.contentSize.height
        viewInputTextHeight?.constant = (viewInputTextHeight?.constant ?? 0) + changeValue
        UIView.animateWithDuration(0.33) {
            self.view.layoutIfNeeded()
        }
        
        if ((textView.text.characters.count + text.characters.count) <= 200) {
            return true
        }
 
        return false
    }

}

extension UITableView {
    
    func scrollToBottom(){
        let offSetY = self.contentSize.height - self.frame.size.height + self.contentInset.bottom
        UIView.animateWithDuration(0.33) { 
            self.setContentOffset(CGPoint(x: 0, y: offSetY), animated: false)
        }
    }
}
