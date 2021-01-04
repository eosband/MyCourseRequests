//
//  Sport.swift
//  MyCourseRequests
//
//  Created by Eric on 5/23/19.
//  Copyright © 2019 Eric. All rights reserved.
//


import Foundation
import os.log


class SportSelection: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: Int
    
    var title: String
    var descr: String
    var days: String
    var teacher: String

    
    //MARK: Archiving Points
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("sports")
    
    
    //MARK: Types
    
    struct PropertyKey{
        static let id = "id"
        static let title = "title"
        static let descr = "descr"
        static let days = "days"
        static let teacher = "teacher"
    }
    
    //MARK: Initializers
    init?(id: Int, title: String, descr: String, days: String, teacher: String){
        // Will expect to be initialized with all of the above in the proper formats, as read from the excel spreadsheet
        
        // None of the above must not be empty or negative
        guard !(title.isEmpty) else {
            return nil
        }
        
        // Initialize Stored Properties
        self.id = id
        self.title = title
        self.descr = descr
        self.days = days
        self.teacher = teacher
        
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(descr, forKey: PropertyKey.descr)
        aCoder.encode(days, forKey: PropertyKey.days)
        aCoder.encode(teacher, forKey: PropertyKey.teacher)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The title is required. If we cannot decode a title string, the initializer should fail.
        
        guard let id = aDecoder.decodeObject(forKey: PropertyKey.id) as? Int
            else {
                os_log("Unable to decode the id for a Sport object.", log: OSLog.default,
                       type: .debug)
                return nil
        }
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String
            else {
                os_log("Unable to decode the title for a Sport object.", log: OSLog.default,
                       type: .debug)
                return nil
        }
        guard let descr = aDecoder.decodeObject(forKey: PropertyKey.descr) as? String
            else {
                os_log("Unable to decode the descr for a Sport object.", log: OSLog.default,
                       type: .debug)
                return nil
        }
        guard let days = aDecoder.decodeObject(forKey: PropertyKey.days) as? String
            else {
                os_log("Unable to decode the days for a Sport object.", log: OSLog.default,
                       type: .debug)
                return nil
        }
        guard let teacher = aDecoder.decodeObject(forKey: PropertyKey.teacher) as? String
            else {
                os_log("Unable to decode the teacher for a Sport object.", log: OSLog.default,
                       type: .debug)
                return nil
        }

        // Must call designated initializer.
        self.init(id: id, title: title, descr: descr, days: days, teacher: teacher)
    }
}
