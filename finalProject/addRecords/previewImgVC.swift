//
//  previewImgVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/20/21.
//

import UIKit


class previewImgVC: UIViewController {

    var delegate: delteImageDelegate? = nil
    @IBOutlet weak var img: UIImageView!
    
    
    @IBAction func clickDelete(_ sender: Any) {
        delegate?.didDeletedImage()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
