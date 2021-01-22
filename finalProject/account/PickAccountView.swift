//
//  PickAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/21/20.
//

import UIKit
import RealmSwift

class PickAccountView: UIViewController {
    var dest = false
    var allAccount:[polyAccount] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAccount()

    }
    func loadAccount(){
        let realm = try! Realm()
               let account = realm.objects(polyAccount.self)
               for obj in account{
                if obj.type == 0{
                    if obj.cashAcc?.active == true{
                         allAccount.append(obj)
                    }
                }
                else{
                    if obj.bankingAcc?.active == true{
                    allAccount.append(obj)
                    }
                }
                }
        
                   
    }
}
    

extension PickAccountView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "PickAccountCell", for: indexPath) as! PickAccountCell
        if allAccount[indexPath.row].type == 0{
            let obj = allAccount[indexPath.row].cashAcc
            cell.lblname.text = obj?.name
            cell.lblBalance.text = "\(obj!.balance)"
            cell.imgIcon.image = UIImage(named: "accountType")
        }
        else{
            let obj = allAccount[indexPath.row].bankingAcc
            cell.lblname.text = obj?.name
            cell.lblBalance.text = "\(obj!.balance)"
            cell.imgIcon.image = UIImage(named: obj!.name)
        }
        
                return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accNotification"), object: allAccount[indexPath.row], userInfo: ["dest":dest])
       self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
extension Notification.Name {
static let accNotification = Notification.Name("accNotification")
}



