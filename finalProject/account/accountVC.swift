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
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
                      // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                          .foregroundColor: UIColor.white,
                          .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
       print(Realm.Configuration.defaultConfiguration.fileURL!)
        let realm = try! Realm()
        Notify().showAll()
       let lang = realm.objects(User.self).first?.isVietnamese
       if lang == true{
       self.navigationItem.title = "Chọn loại tài khoản"
       }
       else{
        self.navigationItem.title = "Choose Account Type"
        }
}
}
