//
//  loginVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/8/21.
//

import UIKit
import FirebaseAuth
import RealmSwift
import SCLAlertView
import FirebaseUI
import ProgressHUD

class loginVC: UITableViewController {

    let realm = try! Realm()
    var userInforRealm: User? = nil
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    @IBAction func clickLogin(_ sender: Any) {
        ProgressHUD.show()
        if emailTF.text == "" || passwordTF.text == ""
        {
            SCLAlertView().showError("Error", subTitle: "You have to enter email/number phone and password!")
            ProgressHUD.dismiss()
            return
        }
        Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!, completion: { [self]  authResult,error in
            if let error = error as NSError?{
                SCLAlertView().showError("Login failed!", subTitle: error.localizedDescription)
                ProgressHUD.dismiss()
                return
            }
            else
            {
                print(authResult!.description)
                let userInfo = Auth.auth().currentUser
                userInforRealm = User()
                userInforRealm!.username = userInfo!.uid
                try! realm.write{
                    realm.add(userInforRealm!)
                }
                toApp()
                ProgressHUD.dismiss()
                SCLAlertView().showSuccess("Login successfully!", subTitle: authResult!.description)
                return
            }
        })
    }
    func toApp()
    {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = mainStoryBoard.instantiateViewController(identifier: "mainTabBar") as! UITabBarController
        tabBarController.selectedIndex = userInforRealm!.defaultScreen
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    @IBAction func clickForgetPassword(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgound")!)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
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
