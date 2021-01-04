//
//  Course.swift
//  MyCourseRequests
//
//  Created by Eric on 5/14/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import Foundation
import os.log
import UIKit


class CourseSearchItem: NSObject {
    
    //MARK: Properties
    
    var attributedTitle: NSMutableAttributedString?
    var attributedTeacher: NSMutableAttributedString?
    var allAttributedName : NSMutableAttributedString?
    
    var id: Int
    
    var title: String
    var period: String
    var teacher: String
    var section: String
    var room: String
    var days: String
    
    var number: String // the 6-8 character key, i.e. INT540CN
    var desc: String // short for description, everything other than the number above
    
    
    //MARK: Initializers
    public init?(id: Int, title: String, period: String, teacher: String, section: String, room: String, days: String){
        // Will expect to be initialized with all of the above in the proper formats, as read from the excel spreadsheet
        
        // None of the above must not be empty or negative
        guard !(title.isEmpty || period.isEmpty || teacher.isEmpty || section.isEmpty || room.isEmpty || days.isEmpty) else {
            return nil
        }
        
        // Initialize Stored Properties
        self.id = id
        self.title = title
        if let i = title.firstIndex(of: ":") {
            // substring from https://useyourloaf.com/blog/swift-string-cheat-sheet/
            self.number = String(title[Range(uncheckedBounds: (lower: title.startIndex, upper: i))])
            self.desc = String(title[Range(uncheckedBounds: (lower: i, upper: title.endIndex))])
        }
        else {
            self.number = "unknown"
            self.desc = title
        }
        self.period = period
        self.teacher = teacher
        self.section = section
        self.room = room
        self.days = days
    }
    
    public func getFormattedText() -> NSMutableAttributedString{
        allAttributedName = NSMutableAttributedString()
        allAttributedName!.append(attributedTitle!)
        
        let newString = NSMutableAttributedString()
        
        newString.append(NSMutableAttributedString(string: " ("))
        newString.append(attributedTeacher!)
        newString.append(NSMutableAttributedString(string: ")"))
        
        newString.setAttributes([.font: UIFont.italicSystemFont(ofSize: 10), .strokeColor: UIColor.darkGray], range: NSMakeRange(0, newString.length))
//        // alignment 2 is right
//        newString.setAlignment(2, NSMakeRange(0, newString.length))
        allAttributedName!.append(newString)
        return allAttributedName!
    }
    
    public func getStringText() -> String{
        return self.title
    }

}
