//
//  ChoiceAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/2/20.
//

import UIKit
import RealmSwift

class ChoiceAccountView: UIViewController {
    var currencyMode:Bool = false
    var accountMode:Bool = false
    var bankingMode:Bool = false
    var timeMode: Bool = false
    var termmMode: Bool = false
    var currencyLabel = currencyBase().nameEnglish
    var accountLabel = infoChoice().typeAccountEnglish
    var abbrName = infoChoice().abbrName
    var bankName = infoChoice().bankName
    var bankImg = infoChoice().abbrName
    var howLong = infoChoice().howLongEnglish
    var  term = infoChoice().termEnglish
    //var backgroundImage: UIImageView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        let realm = try! Realm()
               let lang = realm.objects(User.self).first?.isVietnamese
               if lang == true{
                   currencyLabel = currencyBase().nameVietnamese
                   accountLabel = infoChoice().typeAccountVietnamese
                   howLong = infoChoice().howLongVietnamses
                   term = infoChoice().termVietnamese
                   if bankingMode == true {
                    self.navigationItem.title = "Chọn ngân hàng"
                   }
                   else if currencyMode == true {
                        self.navigationItem.title = "Chọn đơn vị tiền tệ"
                   }
                   else if accountMode == true {
                        self.navigationItem.title = "Chọn tài khoản"
                   }
                   else if timeMode == true {
                        self.navigationItem.title = "Trong bao lâu"
                   }
                   else if termmMode == true{
                        self.navigationItem.title = "Chọn kỳ hạn"
                   }
               }
               else{
                  if bankingMode == true {
                   self.navigationItem.title = "Choose Bank"
                  }
                  else if currencyMode == true {
                       self.navigationItem.title = "Choose Currency"
                  }
                  else if accountMode == true {
                       self.navigationItem.title = "Choose Account"
                  }
                  else if timeMode == true {
                       self.navigationItem.title = "For how long"
                  }
                  else if termmMode == true{
                       self.navigationItem.title = "Choose term"
                  }
               }
       
    }
        

}
extension ChoiceAccountView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currencyMode == true {
            return currencyLabel.count
        }
        else if accountMode == true{
            return accountLabel.count
        }
        else if bankingMode == true {
            return bankName.count
        }
        else if timeMode == true{
            return howLong.count
        }
        else if termmMode == true{
            return term.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if currencyMode == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = currencyLabel[indexPath.row]
            print("currency\([indexPath.row])")
            cell.imgIcon.image = UIImage(named: "currency\(indexPath.row)")
            return cell
               }
               else if accountMode == true{
           let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = accountLabel[indexPath.row]
            cell.imgIcon.image = UIImage(named: accountLabel[indexPath.row])
                      return cell
               }
         else if bankingMode == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankingCell", for: indexPath) as! BankingCell
            cell.lblTitle.text = abbrName[indexPath.row]
            cell.lblInfo.text = bankName[indexPath.row]
            cell.imgIcon.image = UIImage(named: "Banking Account")
                      return cell
        }
        else if timeMode == true {
           let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = howLong[indexPath.row]
            cell.imgIcon.image = UIImage(named: "date")
            return cell
        }
         else if termmMode == true{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = term[indexPath.row]
            cell.imgIcon.image = UIImage(named: "date")
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currencyMode == true {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currNotification"), object: nil, userInfo: ["currency": "\(indexPath.row)"])
             self.navigationController?.popViewController(animated: true)
        }
        else if bankingMode == true{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bankNotification"), object: nil, userInfo: ["bank": "\(indexPath.row)"])
            self.navigationController?.popViewController(animated: true)
        }
        else if accountMode == true{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accountNotification"), object: nil, userInfo: ["accountType": "\(indexPath.row)"])
            self.navigationController?.popViewController(animated: true)
        }
        else if timeMode == true{
            if indexPath.row != 7{ NotificationCenter.default.post(name: NSNotification.Name(rawValue: "timeNotification"), object: nil, userInfo: ["time": howLong[indexPath.row]])}
           // dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        else if termmMode == true{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "termNotification"), object: nil, userInfo: ["term": term[indexPath.row]])
            //dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
            
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if bankingMode == true {
                    return 80
        }
        return 50
    }
    
}
extension Notification.Name {
static let currNotification = Notification.Name("currNotification")
static let bankNotification = Notification.Name("bankNotification")
static let accountNotification = Notification.Name("accountNotification")
static let timeNotification = Notification.Name("timeNotification")
static let termNotification = Notification.Name("termNotification")
static let updateNotification = Notification.Name("updateNotification")
}
