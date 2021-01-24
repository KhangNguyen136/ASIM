//
//  loginVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/8/21.
//
import UIKit
import Firebase
import FirebaseUI
import RealmSwift
import SCLAlertView
import ProgressHUD
import AlertsAndPickers
import GoogleSignIn

class loginVC: UITableViewController {

    let realm = try! Realm()
    var userInforRealm: User? = nil
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
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
                self.userInforRealm = User()
                self.userInforRealm!.username = userInfo!.uid
                self.userInforRealm?.email = userInfo?.email ?? ""
                try! self.realm.write{
                    self.realm.add(self.userInforRealm!)
                }
                userInforRealm?.reloadData()
                { result, currency,isHide in
                    
                    try! self.realm.write{
                        userInforRealm?.currency = currency
                        userInforRealm?.isHideAmount = isHide
                    }
                    self.toApp()
                    ProgressHUD.dismiss()
                    SCLAlertView().showSuccess("Login successfully", subTitle: "This app had reloaded your data in server automatically.")

                    return
                }
                
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
        let alert = UIAlertController(title: "Forgot password", message: "Enter your email", preferredStyle: .alert)
        alert.addTextField{ textField in
            textField.placeholder = "Enter your email"
            textField.font = UIFont(name: "system", size: 18)
        }
        let okAction = UIAlertAction(title: "Reset password", style: .default, handler: { [self]_ in
            let emailTF = alert.textFields![0] as UITextField
            let email = emailTF.text!
            print(email)
            if email.isEmpty == false || self.isValidEmail(email) == true
            {
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    if let error = error as NSError? {
                    SCLAlertView().showError("Reset password failed", subTitle: error.localizedDescription)
                  } else
                  {
                    SCLAlertView().showSuccess("Reset password email has been successfully sent", subTitle: "Check your mail and reset password!")
                    alert.dismiss(animated: false, completion: nil)
                  }
                }
            }
            else
            {
                SCLAlertView().showError("You have to enter your email!", subTitle: "")
    
            }
        })
        alert.addAction(okAction)
        alert.addAction(title: "Cancel", style: .cancel)
        alert.show()
    }
    
    @IBAction func changeHidePass(_ sender: Any) {
        passwordTF.isSecureTextEntry = !passwordTF.isSecureTextEntry
    }
    override func viewDidLoad() {

        GIDSignIn.sharedInstance()?.presentingViewController = self
        
//        GIDSignIn.sharedInstance()?.signIn()
//        GIDSignIn.sharedInstance().delegate = self
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgound")!)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
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
        return 5
    }


}
