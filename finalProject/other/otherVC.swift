//
//  otherVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import RealmSwift
import SCLAlertView
import FirebaseAuth
import FirebaseDatabase
import ProgressHUD

class otherVC: UIViewController {

    @IBOutlet weak var listTv: UITableView!
    let realm = try! Realm()
    var userInfor: User!
    
    var titleRow = ["Personal information","Setting","Your data","Account link","Change password","Share app","Rate app","Your feedback","Help and information","Log out"]
   
    
    let imgName = ["person.fill","gearshape.fill","doc.text.fill","link.circle","lock.rotation","point.fill.topleft.down.curvedto.point.fill.bottomright.up","star.leadinghalf.fill","envelope.badge.fill","info.circle.fill","person.fill.xmark"]
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
       
        if userInfor.password != ""
        {
            titleRow[4] = "Set password"
        }
        print(realm.configuration.fileURL)
    }
    
    typealias connectionStt = (Bool) -> Void
    func checkConnection(comletionHanlder: @escaping connectionStt)
    {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
            comletionHanlder(true)
            return
          } else {
            comletionHanlder(false)
            return
          }
        })
    }
    func logOut()
    {
        ProgressHUD.show()
//        checkConnection{ connectionStt in
//            if connectionStt == false
//            {
//                SCLAlertView().showError("No connection.", subTitle: "Check your internet connection and try again!")
//            }
//        }

        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error logging out: %@", signOutError)
            ProgressHUD.dismiss()
            SCLAlertView().showError("Logging error!.", subTitle: signOutError as! String)
            return
        }
        try! realm.write{
            realm.deleteAll()
        }
        SCLAlertView().showSuccess("Logging out successfully!", subTitle: "")
        ProgressHUD.dismiss()
        toLoginVC()
        return
    }
    func toLoginVC () {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destVC = mainStoryBoard.instantiateViewController(identifier: "loginVC") as! loginVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = UINavigationController(rootViewController: destVC)
        appDelegate.window?.rootViewController = navigationController
    }
    override func viewDidLoad() {
        loadData()
        listTv.register(otherCell.self, forCellReuseIdentifier: "otherCell")
        loadLang()
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .updateNotification, object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.white;
       
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
    }
    func loadLang(){
        let lang = self.realm.objects(User.self).first?.isVietnamese
               if lang == true{
                  titleRow = ["Thông tin cá nhân","Cài đặt chung","Dữ liệu của bạn","Đường dẫn tài khoản","Đổi mật khẩu","Chia sẻ ứng dụng","Đánh giá ứng dụng","Góp ý với nhà phát triển","Trợ giúp và thông tin","Đăng xuất"]
                self.navigationItem.title = "Khác"
               }
               else{
              titleRow = ["Personal information","Setting","Your data","Account link","Change password","Share app","Rate app","Your feedback","Help and information","Log out"]
                self.navigationItem.title = "Other"
        }
       
    }
    @objc func updateView(notification: Notification){
        loadLang()
        listTv.reloadData()
    
    }

}
extension otherVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleRow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTv.dequeueReusableCell(withIdentifier: "otherRow") as! otherCell
        cell.getData(imgName: imgName[indexPath.row], title: titleRow[indexPath.row], _row: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = listTv.cellForRow(at: indexPath)  as! otherCell
        temp.click(temp.content!)
    }
    
}

class otherCell: UITableViewCell {

    var row = -1
    @IBOutlet weak var content: UIButton!
    
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func click(_ sender: Any) {
        switch row {
        case 0:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "personInforVC") as! personInforVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 1:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "settingVC") as! settingVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 2:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "yourDataVC") as! yourDataVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 3:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "accountLinkVC") as! accountLinkVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 4:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "passwordVC") as! passwordVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 7:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "FeebackView") as! FeebackView
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 9:
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let msg = SCLAlertView(appearance: appearance)
            msg.addButton("No", action: {
                return
            })
            msg.addButton("Yes", action: { [self] in
                let temp = self.parentViewController as! otherVC
                temp.logOut()
                return
            })
            msg.showWarning("Log out warning", subTitle: "Your data will lost if you have't synced to server!")
        default:
            print(content.currentTitle!)

        }

    }
    func getData(imgName: String, title: String, _row: Int)  {
        img.image = UIImage(systemName: imgName)
        content.setTitle(title, for: .normal)
        row = _row
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
