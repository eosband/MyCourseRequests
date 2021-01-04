//
//  GLOBAL.swift
//  MyCourseRequests
//
//  Created by Eric on 5/22/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import Foundation

class GLOBAL {
    // from https://stackoverflow.com/questions/26804066/does-swift-have-class-level-static-variables
    static let BASE_API = "http://localhost:8000/"// "https://final-project-database.herokuapp.com/"
    static var HAS_LOADED = true // CHANGE THIS FLAG after one run - otherwise will slow down a huge amount
    static let DEFAULT_COURSE = CourseSearchItem(id: -1, title: " ", period: " ", teacher: " ", section: " ", room: " ", days: " ")!
}
