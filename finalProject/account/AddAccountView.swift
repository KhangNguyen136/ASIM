//
//  AddAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/1/20.
//

import UIKit
import RealmSwift
import SCLAlertView
protocol updateDataDelegate {
    func updateTable()
}
class AddAccountView: UIViewController, UITextFieldDelegate {
    var editMode = false
    var delegate: updateDataDelegate?
    var nameAccount: String = "Account name"
    var descAccount: String = "Description"
    var currency: String = "VND"
    var account: String = "Cash"
    var bankName = "Bank Name"
    var imgName = "bank"
    //Edit mode
    var nameEdit: String = ""
    var active = true
    var balance: String = "0"

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var txtMoney: UITextField!
    var backgroundImage: UIImageView!
    override func viewDidLoad() {
        
           super.viewDidLoad()
            if editMode == true {
                lblTitle.text = "Edit Account"
        }
        txtMoney.text = balance
        txtMoney.delegate = self
           self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        tableView.backgroundColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1)
      
        //lblCurrency.backgroundColor = UIColor(red: 99, green: 0, blue: 102, alpha: 0.1)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrency), name: .currNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBankName), name: .bankNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAccountType), name: .accountNotification, object: nil)
       }
    //Chỉ nhập số cho Số tiền
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        let withDecimal = (
            string == NumberFormatter().decimalSeparator &&
            textField.text?.contains(string) == false
        )
        return isNumber || withDecimal
    }
    @IBAction func deleteBtn(_ sender: Any) {
         let realm = try! Realm()
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("OK") {
            if self.account == "Cash"{
                let obj = realm.objects(Account.self).filter("name == '\(self.nameAccount)'")
            try! realm.write {
                realm.delete(obj)
            }
        }
        else {
            let obj = realm.objects(BankingAccount.self).filter("name == '\(self.nameAccount)'")
            try! realm.write {
                realm.delete(obj)
            }
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertView.addButton("Exit") {
            
                   }
        alertView.showError("Warning", subTitle: "If you delete this Acocunt, all Record in this Account will also be removed and cannot be restored ")
        
        
    }
    @objc func updateCurrency (notification: Notification){
        currency = notification.userInfo?["currency"] as! String
        if currency == "VND" {
            lblCurrency.text = ".đ"
        }
        else {
            lblCurrency.text = ".$"
        }
        self.view.layoutIfNeeded()
        tableView.reloadData()
    }
    @objc func updateBankName (notification: Notification){
        bankName = notification.userInfo?["nameBank"] as! String
        imgName = notification.userInfo?["imgBank"] as! String
        tableView.reloadData()
    }
    @objc func updateAccountType(notification: Notification){
           account =  notification.userInfo?["accountType"] as! String
           tableView.reloadData()
       }


    @IBAction func savebtn(_ sender: Any) {
        let indexName = IndexPath(row: 0, section: 0)
        let indexDes = IndexPath(row: 3, section: 0)
        let cellName: NameAccountViewCell = self.tableView.cellForRow(at: indexName) as! NameAccountViewCell
        let cellDes: NameAccountViewCell = self.tableView.cellForRow(at: indexDes) as! NameAccountViewCell
        let name = cellName.txtNameAcocunt.text!
        let des = cellDes.txtNameAcocunt.text!
        print(des)
        if account == "Cash"{
            let acc = Account()
            acc.balance = Float(txtMoney.text!)!
            acc.currency = self.currency
            acc.name = name
            acc.descrip = des
            acc.includeReport = false
            let realm = try! Realm()
            if editMode == false{
            let tempPolyAcc = polyAccount()
                tempPolyAcc.type = 1
                tempPolyAcc.cashAcc = acc
           try! realm.write {
                realm.add(tempPolyAcc)
                let userInfor = realm.objects(User.self)[0]
                userInfor.accounts.append(tempPolyAcc)
                print(realm.configuration.fileURL)
                }
            }
            else{
            let updAccount = realm.objects(Account.self).filter("name == '\(nameEdit)'").first
            try! realm.write {
               // updAccount!.name = acc.name
                updAccount!.active = self.active
                updAccount!.balance = acc.balance
                updAccount!.currency = acc.currency
                updAccount!.descrip = acc.descrip
                }
            }
            
        }
        else if account == "Banking Account"{
            let index = IndexPath(row: 4, section: 0)
            let cellbankName: AddAcountViewCell = self.tableView.cellForRow(at: index) as! AddAcountViewCell
            let bankName = cellbankName.lblType.text!
            let acc = BankingAccount()
            acc.balance = Float(txtMoney.text!)!
            acc.currency = self.currency
            acc.name = name
            acc.descrip = des
            acc.includeReport = false
            acc.bankName = bankName
            acc.bankImg = imgName
            let realm = try! Realm()
            if editMode == false{
            let tempPolyAcc = polyAccount()
                tempPolyAcc.type = 2
                tempPolyAcc.bankingAcc = acc
            try! realm.write {
                realm.add(tempPolyAcc)
                let userInfor = realm.objects(User.self)[0]
                userInfor.accounts.append(tempPolyAcc)
                }}
            else{
                let updAccount = realm.objects(BankingAccount.self).filter("name == '\(nameEdit)'").first
                try! realm.write {
           //     updAccount!.name = acc.name
                updAccount!.active = self.active
                updAccount!.balance = acc.balance
                updAccount!.currency = acc.currency
                updAccount!.descrip = acc.descrip
                updAccount!.bankName = acc.bankName
                updAccount!.bankImg = acc.bankImg
                }
                }
            }

        else {
            delegate?.updateTable()}
        //dismiss(animated: true, completion: nil)
       self.navigationController?.popViewController(animated: true)
    }
    
}
extension AddAccountView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if account == "Banking Account" {
           return 5
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameAccountCell", for: indexPath) as! NameAccountViewCell
            cell.txtNameAcocunt.placeholder = nameAccount
           // cell.txtNameAcocunt.text = nameAccount
            cell.imgIcon.image = UIImage(named: "nameAccount")
            cell.backgroundView = UIImageView(image: UIImage(named: "row"))
            cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
            cell.layer.borderWidth = 2
            return cell
        }
        else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccountCell", for: indexPath) as! AddAcountViewCell
                cell.lblType.text = account
                cell.imgIcon.image = UIImage(named: "accountType")
            cell.backgroundView = UIImageView(image: UIImage(named: "row"))
                cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
            cell.layer.borderWidth = 2
                return cell
            }
        else if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccountCell", for: indexPath) as! AddAcountViewCell
            cell.lblType.text = currency
            cell.imgIcon.image = UIImage(named: "moneyType")
            cell.backgroundView = UIImageView(image: UIImage(named: "row"))
            cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
            cell.layer.borderWidth = 2
            return cell
        }
        else if indexPath.row == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameAccountCell", for: indexPath) as! NameAccountViewCell
            cell.txtNameAcocunt.placeholder = descAccount
     //       cell.txtNameAcocunt.text = descAccount
            cell.imgIcon.image = UIImage(named: "detailDescribe")
            cell.backgroundView = UIImageView(image: UIImage(named: "row"))
            cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
            cell.layer.borderWidth = 2
            return cell
        }
        else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccountCell", for: indexPath) as! AddAcountViewCell
            cell.lblType.text = bankName
            cell.imgIcon.image = UIImage(named: imgName)
            cell.backgroundView = UIImageView(image: UIImage(named: "row"))
            cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
            cell.layer.borderWidth = 2
            return cell
        }
          return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
            scr.accountMode = true
                   self.present(scr, animated: true, completion: nil)
        }
        else if indexPath.row == 2{
            let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
            scr.currencyMode = true
                   self.present(scr, animated: true, completion: nil)
        }
         else if indexPath.row == 4{
                   let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
                   scr.bankingMode = true
                          self.present(scr, animated: true, completion: nil)
               }
       
    }
    
}
