//
//  StoryTableViewController.swift
//  News Feed
//
//  Created by Ben Wu on 2016-07-10.
//  Copyright © 2016 Ben Wu. All rights reserved.
//

import UIKit

class StoryTableViewController: UITableViewController {

    // MARK: Properties
    
    var stories = [Story]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedStories = getLocalStories() {
            stories = savedStories
        } else {
            downloadStories()
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Loading
    
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
        downloadStories()
    }
    
    func downloadStories() {
        debugPrint("Downloading stories")
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.cbc.ca/json/cmlink/7.4195/")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            if error != nil {
                debugPrint(error?.localizedDescription)
            } else {
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                    
                    if let contentList = result["contentlist"] {
                        if let contentItems = contentList["contentitems"] {
                            self.createStoriesFromJSON(contentItems as! NSArray)
                        }
                    } else {
                        debugPrint("Couldn't parse JSON")
                    }
                } catch {
                    debugPrint("Couldn't parse JSON")
                }
            }
        }
        task.resume()
    }
    
    func createStoriesFromJSON(jsonArr: NSArray) {
        if jsonArr.count > 0 {
            debugPrint("Parsing stories")
            
            for rawStory in jsonArr {
                
                let storyAsDictionary = rawStory as! NSDictionary
                
                let id = storyAsDictionary["id"] as! String
                let title = storyAsDictionary["title"] as! String
                let thumbUrl = "http://i.cbc.ca/1.3672538.1468167948!/fileImage/httpImage/image.jpg_gen/derivatives/16x9_460/britain-wimbledon-tennis.jpg"
                let summary = storyAsDictionary["description"] as! String
                
                debugPrint("Saving story: id: \(id), title: \(title), thumbUrl: \(thumbUrl), summary: \(summary)")
                
                stories.append(Story(id: id, title: title, thumbUrl: thumbUrl, summary: summary))
            }
            
            saveStories()
            
            self.tableView.reloadData()
            
        } else {
            debugPrint("No stories found")
        }
    }

}
