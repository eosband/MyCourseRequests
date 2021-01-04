//
//  Populate_Local_Courses.swift
//  MyCourseRequests
//
//  Created by Eric on 5/23/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Populate_Local_Data {
    
    static let BASE_API = GLOBAL.BASE_API
    
    // CoreData from from https://medium.com/xcblog/core-data-with-swift-4-for-beginners-1fc067cca707
    
    
    
    static func loadAll() {
        // GET the courses from the database
        Populate_Local_Data.makeURLRequest(urlString: BASE_API + "data/", method: "GET")
        
    }
    
    static func populateCoursesSports(data:NSDictionary) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.reset()
        print("RESET")
        
        guard let courses = data["courses"] as? NSDictionary else {
            print("Error: server response had no courses key")
            return
        }
        guard let sports = data["sports"] as? NSDictionary else {
            print("Error: server response had no sports key")
            return
        }
        
        var entity = NSEntityDescription.entity(forEntityName: "Courses", in: context)
        for id in courses.allKeys {
            guard let currentCourse = courses[id] as? NSDictionary else {
                print("invalid response format: content")
                return
            }
            // the data will be arranged by keys
            guard let title = currentCourse["title"] as? String else {
                print("invalid response format: title")
                return
            }
            
            guard let period = currentCourse["period"] as? String else {
                print("invalid response format: period")
                return
            }
            guard let section = currentCourse["section"] as? String else {
                print("invalid response format: section")
                return
            }
            
            guard let teacher = currentCourse["teacher"] as? String else {
                print("invalid response format: teacher")
                return
            }
            guard let room = currentCourse["room"] as? String else {
                print("invalid response format: room")
                return
            }
            guard let days = currentCourse["days"] as? String else {
                print("invalid response format: days")
                return
            }
            guard let id = Int((id as? String )!) else {
                print("invalid response format: id")
                return
            }
            
            
            let newCourse = NSManagedObject(entity: entity!, insertInto: context)
            newCourse.setValue(title, forKey: "title")
            newCourse.setValue(period, forKey: "period")
            newCourse.setValue(teacher, forKey: "teacher")
            newCourse.setValue(section, forKey: "section")
            newCourse.setValue(room, forKey: "room")
            newCourse.setValue(days, forKey: "days")
            newCourse.setValue(id, forKey: "id")
            
            do {
                try context.save()
            } catch {
                print("Failed saving course: " + title)
                return
            }
            
            //            let newCourse = Course(id:id, title: title, period: period, teacher: teacher, section: section, room: room, days: days)
            //            allCourses.append(newCourse!)
        }
        
        entity = NSEntityDescription.entity(forEntityName: "Sports", in: context)
        
        for id in sports.allKeys {
            guard let currentSport = sports[id] as? NSDictionary else {
                print("invalid response format: content")
                return
            }
            // the data will be arranged by keys
            guard let title = currentSport["title"] as? String else {
                print("invalid response format: title")
                return
            }
            guard let descr = currentSport["description"] as? String else {
                print("invalid response format: description")
                return
            }
            guard let days = currentSport["days"] as? String else {
                print("invalid response format: days")
                return
            }
            guard let teacher = currentSport["teacher"] as? String else {
                print("invalid response format: teacher")
                return
            }
            guard let id = Int((id as? String )!) else {
                print("invalid response format: id")
                return
            }
            
            let newSport = NSManagedObject(entity: entity!, insertInto: context)
            newSport.setValue(title, forKey: "title")
            newSport.setValue(descr, forKey: "descr")
            newSport.setValue(teacher, forKey: "teacher")
            newSport.setValue(days, forKey: "days")
            newSport.setValue(id, forKey: "id")
            
            do {
                try context.save()
            } catch {
                print("Failed saving sport: " + title)
                return
            }
            //            let newSport = Sport(id:id, title: title, descr: descr, days: days, teacher: teacher)
            //            allSports.append(newSport!)
        }
        
        print("Loading complete.")
        
        GLOBAL.HAS_LOADED = true
    }
    
    
    static func makeURLRequest(urlString: String, method: String, paramToSend: String? = "") {
        
        let url = URL(string: urlString)
        let session = URLSession.shared
        
        
        let request = NSMutableURLRequest(url: url!)
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies!) // for cookies, from http://lucasjackson.io/realtime-ios-chat-with-django/
        
        request.httpMethod = method
        
        if (method == "POST" || method == "PATCH" || method == "DELETE") {
            let params: String = paramToSend ?? ""
            request.httpBody = params.data(using: String.Encoding.utf8)
        }
        
        
        let task = session.dataTask(with: request as URLRequest) { // completionHandler code is implied
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error retrieving data from server, error:")
                print(error as Any)
                DispatchQueue.main.async {
                    MyActivityIndicator.removeAll()
                }
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                DispatchQueue.main.async {
                    MyActivityIndicator.removeAll()
                }
                return
            }
            
            let json: Any?
            do {
                json = try JSONSerialization.jsonObject(with: responseData, options: [])
            }
            catch {
                print("error trying to convert data to JSON")
                print(String(data: responseData, encoding: String.Encoding.utf8) ?? "[data not convertible to string]")
                DispatchQueue.main.async {
                    MyActivityIndicator.removeAll()
                }
                return
            }
            
            guard let serverResponse = json as? NSDictionary else {
                print("error trying to convert data to NSDictionary")
                DispatchQueue.main.async {
                    MyActivityIndicator.removeAll()
                }
                return
            }
            
            if (method == "GET") {
                DispatchQueue.main.async {
                    Populate_Local_Data.populateCoursesSports(data: serverResponse)
                }
            }
            
        }
        task.resume()
    }
    
}
