//
//  loginVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/12/20.
//

import UIKit
import RealmSwift

class loginVC: UIViewController {

    @IBAction func clickUseAsGuest(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
        let dest = self.storyboard?.instantiateViewController(identifier: "mainTabBar") as! UITabBarController

//        _ = viewcontrollers.popLast()
            self.present(dest, animated: false, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
