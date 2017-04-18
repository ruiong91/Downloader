//
//  ViewController.swift
//  ImageLoadTest
//
//  Created by Rui Ong on 15/04/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit

class Post {
    var name : String = ""
    var link : String = ""
}

class DemoViewController: UIViewController {
    
    let refresh = RefreshControl()
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testCollectionView.dataSource = self
        testCollectionView.delegate = self
        
        refresh.setUpRefreshControl(view: testCollectionView)
        
        fetchPosts()
        
    }
    
    func fetchPosts(){
        
        Downloader().fetchDataFromUrl(stringUrl: "http://pastebin.com/raw/wgkJgazE") { (json) in
            
            if let responses = json as? [[String:Any]] {
                for item in responses {
                    
                    var newPost = Post()
                    
                    if let urls = item["urls"] as? [String:String] {
                        
                        if let regular = urls["regular"] as String? {
                            newPost.link = regular
                        }
                        
                    }
                    
                    if let user = item["user"] as? [String:Any] {
                        
                        if let name = user["name"] as Any? {
                            newPost.name = name as? String ?? ""
                        }
                    }
                    
                    self.posts.append(newPost)
                    self.testCollectionView.reloadData()
                }
            }
        }
    }
    
    //This timer is just for demonstrating the loading animation.
    var seconds = 3
    var timer : Timer?
    
    func getNewData(){
        
        //Fetch new data here
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(seconds), target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if seconds < 1 {
            timer?.invalidate()
            refresh.stopRefreshing()
        } else {
            seconds -= 1
            
        }
        print(seconds)
    }
    
    @IBOutlet weak var testCollectionView: UICollectionView!
    
}


extension DemoViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DemoCollectionViewCell.cellIdentifier, for: indexPath) as? DemoCollectionViewCell else {return UICollectionViewCell()}
        
        let post = posts[indexPath.row]
        
        Downloader().fetchDataFromUrl(stringUrl: post.link) { (object) in
            
            cell.imageView.image = object as? UIImage
            
        }
        
        cell.noOfItemLabel.text = "Posted by. \(post.name)"
        
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        refresh.startRefreshing()
        getNewData()
        
    }
    
    
}
