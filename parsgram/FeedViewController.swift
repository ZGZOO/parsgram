//
//  FeedViewController.swift
//  parsgram
//
//  Created by Zhijie (Jenny) Xu on 10/1/20.
//  Copyright © 2020 Codepath. All rights reserved.
//


// ALL THE COMMENTED OUT IS WHAT Ebuka (TA) on 10/3/2020
//protocol newProtocol {
//    func getme()
//}
//
//class nEWp {
//    var delegate : newProtocol?
//
//    func getsME(){
//        print("getme")
//        delegate?.getme()
//    }
//}
//
//class hgfuyewgfiw : newProtocol{
//    func getme() {
//        print("kbwefjhbfjhb is controlling me")
//    }
//
//    init() {
//        let nn = nEWp()
//        nn.delegate = self
//        nn.getsME()
//    }
//}

//class FeedViewController: UIViewController ,newProtocol {
//    func getme() {
//        print("this is what i want")
//    }
//
//    @IBOutlet weak var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let nn = nEWp()
//        nn.delegate = self
//        nn.getsME()
//
//        print("another part")
//        let h = hgfuyewgfiw()
//
//        //tableView.delegate = self
//        //tableView.dataSource = self
//        // Do any additional setup after loading the view.
//    }
    
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 25
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
//        //cell.textLabel?.text = "i am here"
//
//        return cell
//
//    }
//
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//}


//class exampleCell : UITableViewCell {
//
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: true)
//    }
//}

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    var numberOfPost: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        tableView.keyboardDismissMode = .interactive
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)
            ), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts")
        numberOfPost = 10
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = numberOfPost
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    
    func loadMorePosts(){
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = numberOfPost + 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
        }
        tableView.reloadData()
        
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier:"PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af_setImage(withURL: url)
            return cell
        }else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let scene = UIApplication.shared.connectedScenes.first
        if let delegate : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            delegate.window?.rootViewController = loginViewController
        }
    }
}
