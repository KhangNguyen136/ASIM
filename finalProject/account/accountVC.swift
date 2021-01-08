//
//  accountVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import RealmSwift

class accountVC: UIViewController {
    var backgroundImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
                      // Do any additional setup after loading the view.
        self.navigationItem.title = "Choose Account Type"
        self.navigationController?.navigationBar.titleTextAttributes = [
                          .foregroundColor: UIColor.white,
                          .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
       print(Realm.Configuration.defaultConfiguration.fileURL!)
        let realm = try! Realm()
       // try! realm.write {
          //  realm.deleteAll()
        //}
        //self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Times New Roman ", size: 30)!]
        // Do any additional setup after loading the view.
    }
 /*   override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backgroundImage.frame = self.view.bounds


    }*/

    

}
