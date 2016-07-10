//
//  Story.swift
//  News Feed
//
//  Created by Ben Wu on 2016-07-10.
//  Copyright © 2016 Ben Wu. All rights reserved.
//

import UIKit

class Story: NSObject, NSCoding {

    // MARK: Properties

    var id: String;
    var title: String;
    var thumbUrl: String;
    var summary: String;
    
    struct PropertyKey {
        static let idKey = "id"
        static let titleKey = "title"
        static let thumbUrlKey = "urlKey"
        static let summaryKey = "summary"
    }
    
    // MARK: Initialization
    
    init(id: String, title: String, thumbUrl: String, summary: String) {
        self.id = id
        self.title = title
        self.thumbUrl = thumbUrl
        self.summary = summary
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: PropertyKey.idKey)
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(thumbUrl, forKey: PropertyKey.thumbUrlKey)
        aCoder.encodeObject(summary, forKey: PropertyKey.summaryKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObjectForKey(PropertyKey.idKey) as! String
        let title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        let thumbUrl = aDecoder.decodeObjectForKey(PropertyKey.thumbUrlKey) as! String
        let summary = aDecoder.decodeObjectForKey(PropertyKey.summaryKey) as! String
        
        self.init(id: id, title: title, thumbUrl: thumbUrl, summary: summary)
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("story")

}