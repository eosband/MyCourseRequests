//
//  CourseTableViewCell.swift
//  MyCourseRequests
//
//  Created by Eric on 5/22/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var mainCourse: UILabel!
    
    @IBOutlet weak var alt1: UILabel!
    @IBOutlet weak var alt2: UILabel!
    @IBOutlet weak var alt3: UILabel!
    
    @IBOutlet weak var alt1Period: UILabel!
    @IBOutlet weak var alt2Period: UILabel!
    @IBOutlet weak var alt3Period: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
