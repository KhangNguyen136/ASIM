//
//  SceneDelegate.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import Firebase
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if let windowScene = scene as? UIWindowScene {

            let tempWindow = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if Auth.auth().currentUser != nil
                {
                let tempUser = Auth.auth().currentUser
                print(tempUser)
                print(tempUser?.uid)
                print(tempUser?.email)
                print(tempUser?.displayName)
                print("Singed in.")
                let realm = try! Realm()
//                let userInfor = realm.objects(User.self)[0]
                    let tabBarController = storyboard.instantiateViewController(identifier: "mainTabBar") as! UITabBarController
//                tabBarController.selectedIndex = userInfor.defaultScreen
                tempWindow.rootViewController = tabBarController
                }
                else
                {
                    print("Not singed in.")
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "loginVC")
                    let navigationController = UINavigationController(rootViewController: initialViewController)
                    tempWindow.rootViewController = navigationController
                }

            self.window = tempWindow
            tempWindow.makeKeyAndVisible()

            }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

