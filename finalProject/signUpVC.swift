//
//  signUpVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/2/21.
//

import UIKit
import RealmSwift
import FirebaseAuth
import SCLAlertView
import ProgressHUD
import GoogleSignIn

class signUpVC: UITableViewController {
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var numberPhone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var password: UITextField!
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    @IBAction func backToSignIn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickSignUp(_ sender: Any) {
        ProgressHUD.show()
        if checkPass() == false
        {
            ProgressHUD.dismiss()
            return
        }
        DispatchQueue.main.async { [self] in
        Auth.auth().createUser(withEmail: email.text!, password: password.text!){authResult, error in
            if let error = error as NSError?{
//                switch AuthErrorCode(rawValue: error.code) {
//                case :
//                    <#code#>
//                default:
//                    <#code#>
//                }
                print(error)
                SCLAlertView().showError("Sign up fail!", subTitle: error.localizedDescription)
                ProgressHUD.dismiss()
                return
            }
            else
            {
                print(authResult!.description)
//                let newUserInfo = Auth.auth().currentUser
//                let realm = try! Realm()
//                let userInfor = User()
//                userInfor.username = newUserInfo!.uid
//                userInfor.displayName = username.text ?? ""
//                try! realm.write{
//                    realm.add(userInfor)
//                }
//                toApp()
                SCLAlertView().showSuccess("Sign up successfully", subTitle: "Sign in to use app.")
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
//                    ProgressHUD.dismiss()
//                    SCLAlertView().showError("Logging out error!.", subTitle: signOutError as! String)
                    print(signOutError.localizedDescription)
                }
                //reset vc
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "signUpVC")
//                var viewcontrollers = self.navigationController!.viewControllers
//                viewcontrollers.removeLast()
//                viewcontrollers.append(vc)
//                self.navigationController?.setViewControllers(viewcontrollers, animated: false)
                ProgressHUD.dismiss()
                return
            }
        }
        }
        print("End func sign up.")
    }
    func toApp()
    {
//        let temp = yourDataVC()
//        temp.reloadDataFromFirebase()
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = mainStoryBoard.instantiateViewController(identifier: "mainTabBar") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    func checkPass() -> Bool
    {
        if isValidEmail(email.text!) == false
        {
            print("Invalid email!")
            SCLAlertView().showError("Invalid email!", subTitle: "")
            return false
        }
        if password.text == "" && password2.text == ""
        {
            print("Enter password!")
            SCLAlertView().showError("You must enter password!", subTitle: "")
            return false
        }
        if password.text!.count < 8
        {
            print("Password must contain more 7 character!")
            SCLAlertView().showError("Password must contain more 7 character!", subTitle: "")
            return false
        }
        if password.text != password2.text
        {
            print("Confirm password must be same with password!")
            SCLAlertView().showError("Confirm password must be same with password!", subTitle: "")

            return false
        }
        return true
        
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgound")!)

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        super.viewDidLoad()
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
