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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"PostCell") as! PostCell
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photoView.af_setImage(withURL: url)
        return cell
    }
}
