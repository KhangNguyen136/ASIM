//  AppDelegate.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//
import UIKit
import Firebase
import RealmSwift
import GoogleSignIn
import FBSDKCoreKit
import ProgressHUD
import SCLAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
    var window: UIWindow?
    func toApp()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let realm = try! Realm()
        let users = realm.objects(User.self)
        if users.isEmpty
        {
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error logging out: %@", signOutError)
                SCLAlertView().showError(signOutError.localizedDescription, subTitle: "")
            }
            try! realm.write{
                realm.deleteAll()
            }
            print("To not singed in.")
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "loginVC")
            let navigationController = UINavigationController(rootViewController: initialViewController)
            window!.rootViewController = navigationController
        }
        else
        {
        print("Singed in.")
            let userInfor = users[0]
//      userInfor.reloadData()
        let tabBarController = storyboard.instantiateViewController(identifier: "mainTabBar") as! UITabBarController
        tabBarController.selectedIndex = userInfor.defaultScreen
        window!.rootViewController = tabBarController
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
//        Database.database().isPersistenceEnabled = false
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if Auth.auth().currentUser != nil
            {
                    toApp()
            }
            else
            {
                print("Not singed in.")
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "loginVC")
                let navigationController = UINavigationController(rootViewController: initialViewController)
                window!.rootViewController = navigationController
            }
        window!.makeKeyAndVisible()
        return true
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        ProgressHUD.show()
        if let error = error {
            print("Error1")
            SCLAlertView().showError(error.localizedDescription, subTitle: "")
            ProgressHUD.dismiss()
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { [self] (authResult, error) in
        if let error = error {
            print("Error2")
            SCLAlertView().showError(error.localizedDescription, subTitle: "")
            ProgressHUD.dismiss()
        } else {
            SCLAlertView().showSuccess("Login successfully", subTitle: "You had logged in with your google account.")
        //This is where you should add the functionality of successful login
        //i.e. dismissing this view or push the home view controller etc
            toApp()
        }
            ProgressHUD.dismiss()
        }
    }
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handledFB = FBSDKCoreKit.ApplicationDelegate.shared.application(app, open: url, options: options)
        let handledGoogle = GIDSignIn.sharedInstance().handle(url)
        return handledFB || handledGoogle
    }
}

