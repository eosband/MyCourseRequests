//
//  NewUserViewController.swift
//  MyCourseRequests
//
//  Created by Eric on 5/14/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit
import AudioToolbox

class NewUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var advisorEmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var allFields:[UITextField?] = []
    
    var isAuthenticated = false
    //    let BASE_API = "https://fullstack-project-2.herokuapp.com/"
    let BASE_API = GLOBAL.BASE_API
    
    let badColor: UIColor = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.3)
    let goodColor: UIColor = UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 0.3)
    var validFirstName: Bool = false
    var validLastName: Bool = false
    var validEmail: Bool = false
    var validAdvisorEmail: Bool = false
    var validPassword: Bool = false
    var invalidEmails: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFields = [firstName, lastName, email, advisorEmail, password, confirmPassword]
        saveButton.isEnabled = false
        firstName.addTarget(self, action: #selector(checkForValidFirstName), for: .editingChanged)
        lastName.addTarget(self, action: #selector(checkForValidLastName), for: .editingChanged)
        email.addTarget(self, action: #selector(checkForValidEmail), for: .editingChanged)
        advisorEmail.addTarget(self, action: #selector(checkForValidAdvisorEmail), for: .editingChanged)
        password.addTarget(self, action: #selector(checkForValidPassword), for: .editingChanged)
        confirmPassword.addTarget(self, action: #selector(checkForSamePassword), for: .editingChanged)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveNewUser(_ sender: Any) {
        for field in allFields {
            field!.isEnabled = false
        }
        
        
        // then go to activity monitor
        
        // then send data to database
        // then return to login page, preferably with new user hidden
        self.doCreateNewUser()
    }
    
    
    func doCreateNewUser() { // gets called when login is touched up inside
        let fname = firstName.text
        let lname = lastName.text
        let eml = email.text
        let aEml = advisorEmail.text
        let psw = password.text
        
        MyActivityIndicator.activityIndicator(title: "Securely creating user...", view: self.view)
        
        let url = URL(string: BASE_API + "newStudent/")
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let param1 = "firstname=" + fname! + "&lastname=" + lname!
        let param2 = "&email=" + eml! + "&advisorEmail=" + aEml! + "&password=" + psw!
        let paramToSend = param1 + param2 // compiler requires this for some reason
        
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { // completionHandler code is implied
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error retrieving data from server, error:")
                print(error as Any)
                self.newUserToDo()
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                self.newUserToDo()
                return
            }
            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("unexpected response")
//                self.newUserToDo()
//                return
//            }
            
            // let code = httpResponse.statusCode // we may want to do something with this at some point
            
            let json: Any?
            do {
                json = try JSONSerialization.jsonObject(with: responseData, options: [])
            }
            catch {
                print("error trying to convert data to JSON")
                print(String(data: responseData, encoding: String.Encoding.utf8) ?? "[data not convertible to string]")
                self.newUserToDo()
                return
            }
            
            guard let server_response = json as? NSDictionary else {
                print("error trying to convert data to NSDictionary")
                self.newUserToDo()
                return
            }
 
            
            guard let status = server_response["status"] as? String else {
                print("incorrect server_response format: no status field")
                self.newUserToDo()
                return
            }
            guard let message = server_response["message"] as? String else {
                print("incorrect server_response format: no message field")
                self.newUserToDo()
                return
            }
            
            if status == "false" { // then there was an error: code 406
                DispatchQueue.main.async {
                    self.errorLabel.text = message
                    self.errorLabel.textColor = UIColor.red
                }
                
                self.newUserToDo()
                
                return
            } else {
            // otherwise all good
                DispatchQueue.main.async (
                    execute: self.newUserDone
                )
            }
        }
        
        task.resume()
    }
    
    
    
    func newUserToDo() {
        self.isAuthenticated = false
        DispatchQueue.main.async {
            MyActivityIndicator.removeAll()
            for field in self.allFields {
                field!.isEnabled = true
            }
            self.saveButton.isEnabled = false
            if self.errorLabel.text!.contains("email") { // crude way of determining if error involves username
                self.changeBorderColor(field: self.email, color: UIColor.red)
                self.invalidEmails.append(self.email.text!)
            }
        
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) // vibrates phone
    }
    
    func newUserDone() {
        self.isAuthenticated = true
        DispatchQueue.main.async {
            MyActivityIndicator.removeAll()
            for field in self.allFields {
                field!.isEnabled = false
            }
        }

        // Add a delay from: https://stackoverflow.com/questions/38031137/how-to-program-a-delay-in-swift-3
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.performSegue(withIdentifier: "saveNewUserSegue", sender: self)
        }
    }
    
    
    func changeBorderColor(field: UITextField, color: UIColor) {
        DispatchQueue.main.async {
            field.layer.borderColor = color.cgColor
            field.layer.borderWidth = 1.0
            field.layer.cornerRadius = 5.0
        }
    }
    
    @objc func checkForValidFirstName() {
        if isLetters(str: firstName.text!) {
            self.validFirstName = true
            changeBorderColor(field: firstName, color: UIColor.green)
        }
        else {
            self.validFirstName = false
            changeBorderColor(field: firstName, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
    
    @objc func checkForValidLastName() {
        if isLetters(str: lastName.text!) {
            self.validLastName = true
            changeBorderColor(field: lastName, color: UIColor.green)
        }
        else {
            self.validLastName = false
            changeBorderColor(field: lastName, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
 
    
    @objc func checkForValidEmail() {
        if (isEmailFormat(str: email.text!) && !invalidEmails.contains(email.text!)) {
            self.validEmail = true
            changeBorderColor(field: email, color: UIColor.green)
        }
        else {
            self.validEmail = false
            changeBorderColor(field: email, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
    @objc func checkForValidAdvisorEmail() {
        if (isEmailFormat(str: advisorEmail.text!)) {
            self.validAdvisorEmail = true
            changeBorderColor(field: advisorEmail, color: UIColor.green)
        }
        else {
            self.validAdvisorEmail = false
            changeBorderColor(field: advisorEmail, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
    
    func isEmailFormat(str: String) -> Bool {
        if let i = str.firstIndex(of: "@") {
            if str[Range(uncheckedBounds: (lower: str.startIndex, upper: i))] != "" && str[Range(uncheckedBounds: (lower: i, upper: str.endIndex))] == "@andover.edu" {
                return true
            }
            return false
        }
        return false
    }
    
    
    @objc func checkForValidPassword() {
        if (isAlphanumeric(str: password.text!)) {
            self.validPassword = true
            changeBorderColor(field: password, color: UIColor.green)
        }
        else {
            self.validPassword = false
            changeBorderColor(field: password, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
    
    @objc func checkForSamePassword() {
        if confirmPassword.text == "" || confirmPassword.text != password.text {
            confirmPassword.backgroundColor = self.badColor
            saveButton.isEnabled = false
        }
        else {
            confirmPassword.backgroundColor = self.goodColor
            saveButton.isEnabled = self.validFirstName && self.validLastName && self.validEmail && self.validAdvisorEmail && self.validPassword
        }
    }
    
    
    
    func isAlphanumeric(str: String) -> Bool { // Relative expression from https://stackoverflow.com/questions/35992800/check-if-a-string-is-alphanumeric-in-swift
        return !str.isEmpty && str.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    func isLetters(str: String) -> Bool{
        return !str.isEmpty && str.range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // implements the return key
        
        // Hide the keyboard
        textField.resignFirstResponder()
        if textField == firstName {
            //change cursor from username to password textfield
            lastName.becomeFirstResponder()
        } else if textField == lastName {
            email.becomeFirstResponder()
        } else if textField == email {
            advisorEmail.becomeFirstResponder()
        } else if textField == advisorEmail {
            password.becomeFirstResponder()
        } else if textField == password {
            confirmPassword.becomeFirstResponder()
        } else if textField == confirmPassword {
            saveNewUser("") // mimics the save button being pressed
        }
        else {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "saveNewUserSegue" {
                if !self.isAuthenticated {
                    return false
                }
            }
        }
        return true
    }

}
