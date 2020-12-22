//
//  PickAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/21/20.
//

import UIKit
import RealmSwift

class PickAccountView: UIViewController {
    var allAccount:[displayAccout] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAccount()
    }
    
    func loadAccount(){
        let realm = try! Realm()
               let cashAccount = realm.objects(Account.self)
               let bankingAccount = realm.objects(BankingAccount.self)


               for obj in cashAccount{

               let name = obj.name
               let balance = obj.balance
               if obj.active == true{
                   allAccount.append(displayAccout(name: name, balance: balance,img: UIImage(named: "Cash")!, type: AccountType.cash))
                }}
                for obj in bankingAccount{

                let name = obj.name
                let balance = obj.balance
                if obj.active == true{
                    allAccount.append(displayAccout(name: name, balance: balance,img: UIImage(named: obj.bankImg)!, type: AccountType.banking))
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
        cell.lblname.text = allAccount[indexPath.row].name
        cell.lblBalance.text = "\(allAccount[indexPath.row].balance)"
        cell.imgIcon.image = allAccount[indexPath.row].image
                    return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accNotification"), object: allAccount[indexPath.row], userInfo: nil)
       self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
        
}
extension Notification.Name {
static let accNotification = Notification.Name("accNotification")
}



