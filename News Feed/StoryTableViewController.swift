//
//  StoryTableViewController.swift
//  News Feed
//
//  Created by Ben Wu on 2016-07-10.
//  Copyright © 2016 Ben Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class StoryTableViewController: UITableViewController {

    // MARK: Properties
    
    var stories = [Story]()
    
    var loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        loadingIndicator.center = self.view.center
        self.view.addSubview(loadingIndicator)
        
        downloadStories()
        
        /*if let savedStories = getLocalStories() {
            stories = savedStories
        } else {
            downloadStories()
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "StoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StoryCell

        let story = stories[indexPath.row]

        cell.title.text = story.title
        
        
        let url = NSURL(string: story.imageUrl)
        
        if url != nil {
            cell.thumbnail.af_setImageWithURL(url!)
        }
        
        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenStory" {
            let storyViewController = segue.destinationViewController as! StoryViewController
            
            if let selectedStoryCell = sender as? StoryCell {
                let index = tableView.indexPathForCell(selectedStoryCell)!
                let selectedStory = stories[index.row]
                storyViewController.storyId = selectedStory.id
                storyViewController.navigationItem.title = selectedStory.title
            }
        }
    }

    // MARK: Loading
    
    func showLoading() {
        loadingIndicator.startAnimating()
        loadingIndicator.backgroundColor = UIColor.clearColor()
    }
    
    func hideLoadingDelayed() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(),
            {
                self.hideLoading()
            })
    }
    
    func hideLoading() {
        print("hideloading")
        loadingIndicator.stopAnimating()
        loadingIndicator.hidesWhenStopped = true
    }
    
    func saveStories() {
        debugPrint("Saving stories")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(stories, toFile: Story.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save meals...")
        }
    }
    
    func getLocalStories() -> [Story]? {
        debugPrint("Retrieving stories from local")
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Story.ArchiveURL.path!) as? [Story]
    }
    
    @IBAction func refresh(sender: AnyObject) {
        debugPrint("Refreshing")
        downloadStories()
    }
    
    func downloadStories() {
        debugPrint("Downloading stories")
        showLoading()
        
        Alamofire.request(.GET, "http://benwu.space:8000/story").responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.createStoriesFromJSON(json.arrayValue)
                }
            case .Failure(let error):
                print(error)
                self.hideLoadingDelayed()
            }
        }
    }
    
    func createStoriesFromJSON(storyItems: [JSON]) {
        if storyItems.count > 0 {
            debugPrint("Parsing \(storyItems.count) stories")
            
            stories.removeAll()
            
            for rawStory in storyItems {
                let id = rawStory["id"].string!
                let title = rawStory["title"].string!
                let status = rawStory["status"].string!
                let date = rawStory["date"].string!
                let summary = rawStory["summary"].string!
                let timestamp = rawStory["timestamp"].int!
                let imageUrl = rawStory["imageUrl"].string!
                let categories = rawStory["categories"].arrayObject as! [String]
                let newStory = Story(id: id, title: title, status: status, date: date, summary: summary, timestamp: timestamp,
                                     imageUrl: imageUrl, categories: categories)
                
                debugPrint("Saving story: \(newStory.id)")
                
                stories.append(newStory)
            }
            
            saveStories()
            
            self.tableView.reloadData()
            
        } else {
            debugPrint("No stories found")
        }
        hideLoadingDelayed()
    }
}
