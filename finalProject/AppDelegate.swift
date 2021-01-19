//
//  AppDelegate.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//
import UIKit
import Firebase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = false
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if Auth.auth().currentUser != nil
            {
                print("Singed in.")
                print(Realm.Configuration.defaultConfiguration.fileURL!)
                let realm = try! Realm()
//                let userInfor = realm.objects(User.self)[0]
                let userInfor = User()
                let tabBarController = storyboard.instantiateViewController(identifier: "mainTabBar") as! UITabBarController
                tabBarController.selectedIndex = userInfor.defaultScreen
                window!.rootViewController = tabBarController
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

//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

}

