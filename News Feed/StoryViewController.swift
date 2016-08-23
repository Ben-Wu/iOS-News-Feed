//
//  StoryViewController.swift
//  News Feed
//
//  Created by Ben Wu on 2016-08-13.
//  Copyright © 2016 Ben Wu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StoryViewController: UIViewController, UIWebViewDelegate {

    var scrollView = UIScrollView()
    var storyContent = UIWebView()
    var headline = UILabel()
    var headlineImageView = UIImageView()
    
    var headlineImage: UIImage?
    
    var json: JSON = JSON.null
    
    var storyId: String?
    
    var padding: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if storyId != nil {
            Alamofire.request(.GET, "http://benwu.space:8000/story/" + storyId!).responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.json = JSON(value)
                        print("Story content for \(self.json["id"]) loaded")
                        self.setupViews()
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        if json == nil || json == JSON.null {
            return
        }
        
        scrollView.frame = CGRect(x: 0, y: self.topLayoutGuide.length, width: self.view.frame.size.width, height: self.view.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        if headlineImage != nil {
            headlineImageView.frame = CGRect(x: 0, y: 0,
                                             width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
            headlineImageView.contentMode = .ScaleAspectFill
            headlineImageView.clipsToBounds = true
            headlineImageView.image = headlineImage
            
            scrollView.addSubview(headlineImageView)
        }
        
        if let title = json["headline"].string {
            headline.frame = CGRect(x: padding, y: padding + headlineImageView.frame.height, width: self.view.frame.size.width - padding * 2,
                                    height: 50)
            headline.textColor = UIColor.blackColor()
            headline.textAlignment = NSTextAlignment.Center
            headline.font = UIFont.systemFontOfSize(24)
            headline.numberOfLines = 3
            headline.adjustsFontSizeToFitWidth = true
            headline.baselineAdjustment = .AlignCenters
            headline.minimumScaleFactor = 0.6
            headline.text = title
            
            scrollView.addSubview(headline)
        }
        
        if let content = json["body"].string {
            storyContent.frame = CGRect(x: padding, y: padding + headline.frame.height + headlineImageView.frame.height,
                                        width: self.view.frame.size.width - padding * 2, height: padding)
            storyContent.loadHTMLString(content, baseURL: nil)
            storyContent.delegate = self
            storyContent.backgroundColor = UIColor.whiteColor()
            
            scrollView.addSubview(storyContent)
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        storyContent.frame = CGRect(x: padding, y: padding * 2 + headline.frame.height + headlineImageView.frame.height,
                                    width: self.view.frame.size.width - padding * 2, height: storyContent.scrollView.contentSize.height + 70)
        
        var finalHeight : CGFloat = self.topLayoutGuide.length
        scrollView.subviews.forEach { (subview) -> () in
            finalHeight += subview.frame.height
        }
        scrollView.contentSize.height = finalHeight
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
