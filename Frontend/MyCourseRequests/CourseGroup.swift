//
//  Course.swift
//  MyCourseRequests
//
//  Created by Chris Ward on 5/27/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit
import os.log

class CourseGroup {
    
    //MARK: Properties
    
    var mainCourse: CourseSearchItem!
    var alt1: CourseSearchItem!
    var alt2: CourseSearchItem!
    var alt3: CourseSearchItem!
    var id: Int?
    
    //MARK: Archiving Points
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("memories")
    
  
    //MARK: Initializers
    init?(mainCourse: CourseSearchItem, alt1: CourseSearchItem, alt2: CourseSearchItem, alt3: CourseSearchItem){
        
        // Initialize Stored Properties
        self.mainCourse = mainCourse
        self.alt1 = alt1
        self.alt2 = alt2
        self.alt3 = alt3
        
        // id will start as -1 and will be set when memory is POSTed or from GET of all memories
        self.id = -1
    }
    
}
