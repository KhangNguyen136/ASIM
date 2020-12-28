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
    override var shouldAutorotate: Bool{
        get{
            return false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundImage = UIImageView(image: UIImage(named: "background-1"))
        self.backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(self.backgroundImage, at: 0)
       print(Realm.Configuration.defaultConfiguration.fileURL!)
        let realm = try! Realm()
       // try! realm.write {
          //  realm.deleteAll()
        //}
        //self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Times New Roman ", size: 30)!]
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backgroundImage.frame = self.view.bounds


    }

    

}
