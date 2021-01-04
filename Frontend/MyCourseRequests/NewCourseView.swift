//
//  NewCourseView.swift
//  MyCourseRequests
//
//  Created by Eric on 5/23/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit

class NewCourseView: UIView {

    @IBOutlet weak var searchField: CustomSearchTextField!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var days: UILabel!
    
    @IBOutlet weak var hideFields: UIView!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var altSwitch: UISwitch!
    
    var course: CourseSearchItem = GLOBAL.DEFAULT_COURSE

    
    // this function is UIView's equivalent of viewDidLoad according to https://stackoverflow.com/questions/16146063/viewdidload-for-uiview/16146107
    override func awakeFromNib() {
        super.awakeFromNib()
        resetMainCourse("")
        if self.restorationIdentifier != "MainSelection" {
            hideFields.isHidden = false
            altSwitch.isOn = false
//            if NewCourseViewController.main_course.id == -1 {
//                self.isHidden = true
//
//            } else {
//                self.isHidden = false
//            }
        }
    }
    
    func updateCourse(_ crse: CourseSearchItem) {

        
        course = crse

        if self.restorationIdentifier == "MainSelection" {
            NewCourseViewController.main_course = course
        }
        else if self.restorationIdentifier == "Alt1Selection" {
            NewCourseViewController.alt1_course = course
        }
        else if self.restorationIdentifier == "Alt2Selection" {
            NewCourseViewController.alt2_course = course
        }
        else if self.restorationIdentifier == "Alt3Selection" {
            NewCourseViewController.alt3_course = course
        }
        
    }

    
    @IBAction func resetMainCourse(_ sender: Any) {
        updateCourse(GLOBAL.DEFAULT_COURSE)
        updateMainLabels("")
        searchField.isEnabled = true
        searchField.text = ""
    }
    
    // called when the course is filled out
    @IBAction func updateMainLabels(_ sender: Any) {
        self.teacher.text = self.course.teacher
        self.period.text = self.course.period
        self.room.text = self.course.room
        self.days.text = self.course.days
        if self.course.id != -1 {
            resetButton.isHidden = false
            updateCourse(self.course)
        }
        else {
            resetButton.isHidden = true
        }
        

    }
    
    @IBAction func altSwitchPressed(_ sender: Any) {
        // the restorationIdentifier cannot be MainSelection so we don't need to check for possible nil value
        if restorationIdentifier == "Alt1Selection" {
            if NewCourseViewController.main_course.id == -1 {
                altSwitch.isOn = false
                return
            }
        } else if restorationIdentifier == "Alt2Selection" {
            if NewCourseViewController.alt1_course.id == -1 {
                altSwitch.isOn = false
                return
            }
        } else if restorationIdentifier == "Alt3Selection" {
            if NewCourseViewController.alt2_course.id == -1 {
                altSwitch.isOn = false
                return
            }
        }
        
        
        if altSwitch.isOn {
            hideFields.isHidden = true
        }
        else {
            self.bringSubviewToFront(hideFields) // we need this because CustomSearchTextField brings the text field to front on its own
            resetMainCourse("")
            hideFields.isHidden = false
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
