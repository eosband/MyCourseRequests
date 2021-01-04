//
//  CRViewController.swift
//  MyCourseRequests
//
//  Created by Eric on 5/23/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit
import CoreData

class CRViewController: UIViewController, UITableViewDataSource {

    // Labels
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var term: UILabel!
    
    // TableViews
    @IBOutlet weak var courseTableView: UITableView!
    
    // Buttons
    @IBOutlet weak var addNewCourseButton: UIButton!
    @IBOutlet weak var plusNewCourseButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var sport: DropDown!
    @IBOutlet weak var sportTeacher: UILabel!
    @IBOutlet weak var sportDays: UILabel!
    var sportID: Int = -1
    
    @IBOutlet weak var musicLessonLength: DropDown!
    @IBOutlet weak var musicLengthLabel: UILabel!
    
    @IBOutlet weak var musicLessonInstrument: UITextField!
    
    @IBOutlet weak var musicLessonTeacher: UITextField!
    
    
    @IBOutlet weak var additionalComments: UITextField!
    
    
    @IBOutlet weak var resetSportButton: UIButton!
    
    
    var allSports:[Sports] = [Sports]()
    
    var courseGroups:[CourseGroup] = []
    var hasLoaded = false
    
    var hash_id = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        hash_id = UserDefaults.standard.string(forKey: "hash_id") ?? ""
        name.text = UserDefaults.standard.string(forKey: "name") ?? "Unknown name"
        term.text = UserDefaults.standard.string(forKey: "term") ?? "Unknown"
        
        courseTableView.dataSource = self
    
        populateSports()
        // Setup sport dropdown
        var arr:[String] = []
        for elem:Sports in allSports {
            arr.append(elem.title!) // add all sports to allSports
        }
        self.resetSport("")
        sport.optionArray = arr
        sport.didSelect{( selectedText, index, id) in
            self.sportTeacher.text = self.allSports[index].teacher
            self.sportDays.text = self.allSports[index].days
            self.sportID = Int(self.allSports[index].id)
            self.updateSaveButtonState()
            self.sport.isEnabled = false
            self.resetSportButton.isEnabled = true
        }
        sport.listDidDisappear {
            self.sport.hideList()
        }
        
        // Setup music lesson length dropdown
        musicLessonLength.optionArray = ["30 minutes", "45 minutes", "60 minutes"]
        musicLessonLength.didSelect{( selectedText, index, id) in
            self.musicLengthLabel.text = selectedText
        }
        musicLessonLength.listDidDisappear {
            self.musicLessonLength.hideList()
        }
        
        
        // Do any additional setup after loading the view.
        
        
        
        if courseGroups.count >= 5 {
            addNewCourseButton.isEnabled = false
            plusNewCourseButton.isEnabled = false
        }
        else {
            addNewCourseButton.isEnabled = true
            plusNewCourseButton.isEnabled = true
        }
        
        updateSaveButtonState()
    }
    
    @IBAction func resetSport(_ sender: Any) {
        self.sport.text = ""
        self.sportTeacher.text = ""
        self.sportDays.text = ""
        self.sport.isEnabled = true
        self.resetSportButton.isEnabled = false
    }
    
    func populateSports() {
        let request : NSFetchRequest<Sports> = Sports.fetchRequest()
        do {
            allSports = try context.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }
    }
    
    func updateSaveButtonState() {
        if courseGroups.count > 0 && sportID != -1 {
            saveButton.isEnabled = true
        }
        else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func unwindToCourseSelection(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? NewCourseViewController, let courseGroup = sourceViewController.courseGroup {
            let newIndexPath = IndexPath(row: courseGroups.count, section: 0)
            courseGroups.append(courseGroup)
            courseTableView.insertRows(at: [newIndexPath], with: .automatic)
        }

    }
  
    @IBAction func saveButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Save", message: "Are you sure to save?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Logout"), style: .cancel, handler: { _ in
            NSLog("The \"Cancel\" alert occured.")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: "Confirm Save"), style: .default, handler: { _ in
            NSLog("The \"Save\" alert occured.")
            self.handleSave()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleSave() {
        /*
        courses = content["courses"] # should be an array of the courses' IDs
        sixthCourse = content["sixthCourse"]
        topPriority = content["topPriority"]
        sport = content["sport"] # should be the sport's ID
        mL = content["musicLesson"] # should be a dict in the proper musiclesson format
        comments = content["comments"]
 */
        var courses:[[Int]] = []
        for courseGroup: CourseGroup in courseGroups {
            courses.append([courseGroup.mainCourse.id, courseGroup.alt1.id, courseGroup.alt2.id, courseGroup.alt3.id])
        }
        var paramToSend = "courses=" + courses.description
        paramToSend += "&sixthCourse=-1" // we are not using sixthCourse in this version
        paramToSend += "&topPriority=-1" // same as above
        paramToSend += "&sport=" + String(sportID)
        let mL:[String:String] = ["instrument" : musicLessonInstrument.text ?? "", "teacher": musicLessonTeacher.text ?? "", "length" : musicLengthLabel.text ?? ""]
        paramToSend += "&musicLesson=" + mL.description
        paramToSend += "&comments=" + (additionalComments.text ?? "none")
        print(mL)
//        makeURLRequest(urlString: GLOBAL.BASE_API, method: "POST", paramToSend: paramToSend)
    }
    
    func makeURLRequest(urlString: String, method: String, paramToSend: String? = "") {
        
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
            
            guard let status = serverResponse["status"] as? String else {
                print("incorrect server_response format: no status field")
                return
            }
            guard let message = serverResponse["message"] as? String else {
                print("incorrect server_response format: no message field")
                return
            }
            
            
            if (method == "POST") {
                if status == "false" { // then there was an error: code 406
                    DispatchQueue.main.async {
                        self.errorLabel.text = message
                        self.errorLabel.textColor = UIColor.red
                    }
                } else {
                    self.makeURLRequest(urlString: GLOBAL.BASE_API + "logout/", method: "GET")
                    self.performSegue(withIdentifier: "logoutStudent", sender: "")
                }
            }
//            else if (method == "PATCH") {
//                MyActivityIndicator.removeAll()
//                return
//            }
//            else if (method == "DELETE") {
//                MyActivityIndicator.removeAll()
//                return
//            }
            
            
        }
        task.resume()
    }
    
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return courseGroups.count
    }
        
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell indentifier
        let cellIdentifier = "CourseTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CourseTableViewCell else {
            fatalError("The dequeued cell is not an instance of CourseTableViewCell.")
        }
        
        // Fetches the appropriate course for the data source layout
        let courseGroup = courseGroups[indexPath.row]
        cell.mainCourse.text = courseGroup.mainCourse.title
        cell.period.text = courseGroup.mainCourse.period
        
        
        if (courseGroup.alt1.title == " ") {
            cell.alt1.text = "None"
        }
        else {
            cell.alt1.text = courseGroup.alt1.title
        }
        cell.alt1Period.text = courseGroup.alt1.period

        if (courseGroup.alt2.title == " ") {
            cell.alt2.text = "None"
        }
        else {
            cell.alt2.text = courseGroup.alt2.title
        }
        
        
        cell.alt2Period.text = courseGroup.alt2.period
    
        if (courseGroup.alt3.title == " ") {
            cell.alt3.text = "None"
        }
        else {
            cell.alt3.text = courseGroup.alt3.title
        }
        
        cell.alt3Period.text = courseGroup.alt3.period
        
        // Configure the cell...
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
