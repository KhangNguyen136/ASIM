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
    
    var imagePicker = UIImagePickerController()
    @IBAction func testImgPicker(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    print("Button capture")

                    imagePicker.delegate = self
                    imagePicker.sourceType = .savedPhotosAlbum
                    imagePicker.allowsEditing = false

                    present(imagePicker, animated: true, completion: nil)
                }
    }
}
extension loginVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Pick an img")
    }
}
