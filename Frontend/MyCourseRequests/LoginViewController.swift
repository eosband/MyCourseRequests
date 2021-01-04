//
//  LoginViewController.swift
//  MyCourseRequests
//
//  Created by Eric on 5/14/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit
import AudioToolbox

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _login_button: UIButton!
    @IBOutlet weak var _newUserButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    var isAuthenticated = false
//    let BASE_API = "https://fullstack-project-2.herokuapp.com/"
    let BASE_API = GLOBAL.BASE_API
    
    var hash_id = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let _ = UserDefaults.standard.data(forKey: "hash_id") {
            LoginDone()
        }


        
        _password.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)

        
        updateLoginButtonState()
    }
    
    // help from https://www.youtube.com/watch?v=y2hiaoaRBQ0
    @IBAction func LoginButton(_ sender: Any) {
        let username = _username.text
        let password = _password.text
        if (username == "") {
            changeBorderColor(field: _username, color: UIColor.red)
            return
        }
        else {
            changeBorderColor(field: _username, color: UIColor.clear)
        }
        
        if (password == "") {
            changeBorderColor(field: _username, color: UIColor.red)
            return
        }
        else {
            changeBorderColor(field: _username, color: UIColor.clear)
        }
        
        
        doLogin(username!, password!)
    }
    
    func changeBorderColor(field: UITextField, color: UIColor) {
        DispatchQueue.main.async {
            field.layer.borderColor = color.cgColor
            field.layer.borderWidth = 1.0
            field.layer.cornerRadius = 5.0
        }
    }
    
    
    func doLogin(_ user: String, _ psw: String) { // gets called when login is touched up inside
        _username.isEnabled = false // disables both buttons
        _password.isEnabled = false
        
        MyActivityIndicator.activityIndicator(title: "Securely logging in...", view: self.view)

        
        let url = URL(string: BASE_API + "login/")
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let paramToSend = "username=" + user + "&password=" + psw
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies!) // for cookies, from http://lucasjackson.io/realtime-ios-chat-with-django/
        let task = session.dataTask(with: request as URLRequest) { // completionHandler code is implied
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error retrieving data from server, error:")
                print(error as Any)
                self.LoginToDo()
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                self.LoginToDo()
                return
            }
            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("unexpected response")
//                self.LoginToDo()
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
                self.LoginToDo()
                return
            }
            
            guard let server_response = json as? NSDictionary else {
                print("error trying to convert data to NSDictionary")
                self.LoginToDo()
                return
            }

            
            guard let status = server_response["status"] as? String else {
                print("incorrect server_response format: no status field")
                self.LoginToDo()
                return
            }
            guard let message = server_response["message"] as? String else {
                print("incorrect server_response format: no message field")
                self.LoginToDo()
                return
            }
            
            if status == "false" { // then there was an error: code 406
                DispatchQueue.main.async {
                    self.errorLabel.text = message
                    self.errorLabel.textColor = UIColor.red
                }
                self.LoginToDo()
                return
            }
            
            // otherwise all good
            
            
            let preferences = UserDefaults.standard
            guard let hash_id = server_response["hash_id"] as? String else {
                print("Error: hash_id in incorrect format")
                return
            }
            guard let name = server_response["name"] as? String else {
                print("Error: name in incorrect format")
                return
            }
            guard let term = server_response["term"] as? String else {
                print("Error: term in incorrect format")
                return
            }
            preferences.set(hash_id, forKey: "hash_id") // updates userDefaults to this hash_id, which stores the user's hash_id
            preferences.set(name, forKey:"name")
            preferences.set(term, forKey:"term")
            self.hash_id = hash_id
            DispatchQueue.main.async (
                execute: self.LoginDone
            )
        }
        
        task.resume()
    }
    
    
    func LoginToDo() {
        self.isAuthenticated = false
        DispatchQueue.main.async {
            MyActivityIndicator.removeAll()
            self._username.isEnabled = true
            self._password.isEnabled = true
        }
        changeBorderColor(field: _username, color: UIColor.red)
        changeBorderColor(field: _password, color: UIColor.red)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) // vibrates phone
    }
    
    func LoginDone() {
        self.isAuthenticated = true
        DispatchQueue.main.async {
            MyActivityIndicator.removeAll()
            self._username.isEnabled = false
            self._password.isEnabled = false
            self._login_button.isEnabled = false
        }
        changeBorderColor(field: _username, color: UIColor.green)
        changeBorderColor(field: _password, color: UIColor.green)
        
        // Add a delay from: https://stackoverflow.com/questions/38031137/how-to-program-a-delay-in-swift-3
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.performSegue(withIdentifier: "userLoggedInSegue", sender: self)
        }
    }
    
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "userLoggedInSegue" {
                if self.isAuthenticated != true { // so that the segue won't perform if it isn't authenticated
                    return false
                }
            }
        }
        return true
    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "userLoggedInSegue" {
            guard let destination = segue.destination as? CRViewController else {
                print("Destination is not CRViewController")
                return
            }
            
//            destination.hash_id = self.hash_id
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
            
    }
 */
 
    
 
    
    @IBAction func goToNewUser(_ sender: UIButton) {
            performSegue(withIdentifier: "newUserSegue", sender: self)

    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // implements the return key
        if textField == _username {
            //change cursor from username to password textfield
            _password.becomeFirstResponder()
        } else if textField == _password {
            //attempt to login when we press enter on password field
            LoginButton("") // mimics the login button being pressed
        }
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateLoginButtonState()
    }

    
    //MARK: Private Methods
    @objc private func updateLoginButtonState(){
        // Disable the save button if the text field is empty.
        let username = _username.text ?? ""
        let password = _password.text ?? ""
        _login_button.isEnabled = !(username.isEmpty && password.isEmpty)
    }

}
