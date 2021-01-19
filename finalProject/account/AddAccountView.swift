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
    var editAcc: polyAccount = polyAccount()
    var delegate: updateDataDelegate?
    var nameAccount: String = "Account name"
    var descAccount: String = "Description"
    var currency: String = "Vietnamese Dong (VND)"
    var account: String = "Cash"
    var bankName = "Bank Name"
    var imgName = "bank"
    //Edit mode
    var active = true
    var balance: String = "0"
    var bank = 0
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var txtMoney: UITextField!
    var backgroundImage: UIImageView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if editMode == true {
            let currencybase = currencyBase().nameEnglish
            
            if editAcc.type == 0{
                currency = currencyBase().nameEnglish[editAcc.cashAcc!.currency]
                lblCurrency.text = currencyBase().symbol[editAcc.cashAcc!.currency]
                account = "Cash"
                balance = "\(round((editAcc.cashAcc?.balance as! Float)*Float(currencyBase().valueBaseDolar[editAcc.cashAcc!.currency])))"
                nameAccount = editAcc.cashAcc!.name
                active = editAcc.cashAcc!.active
                
            }
            else{
                currency = currencyBase().nameEnglish[editAcc.bankingAcc!.currency]
                lblCurrency.text = currencyBase().symbol[editAcc.bankingAcc!.currency]
                account = "Banking Account"
                bankName = infoChoice().bankName[editAcc.bankingAcc!.bank]
                balance = "\(round((editAcc.bankingAcc?.balance as! Float)*Float(currencyBase().valueBaseDolar[editAcc.bankingAcc!.currency])))"
                nameAccount = editAcc.bankingAcc!.name
                active = editAcc.bankingAcc!.active
            }
            
            
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
        let index = notification.userInfo!["currency"] as! String

        lblCurrency.text = currencyBase().symbol[Int(index)!]
        currency = currencyBase().nameEnglish[Int(index)!]
       
        
        self.view.layoutIfNeeded()
        tableView.reloadData()
    }
    @objc func updateBankName (notification: Notification){
        let index = notification.userInfo?["bank"] as! String
        self.bank = Int(index)!
        bankName = infoChoice().bankName[Int(index)!]
        imgName = infoChoice().bankImg[Int(index)!]
        tableView.reloadData()
    }
    @objc func updateAccountType(notification: Notification){
           account =  notification.userInfo?["accountType"] as! String
           tableView.reloadData()
       }


    @IBAction func savebtn(_ sender: Any) {
        let realm = try! Realm()
        let indexName = IndexPath(row: 0, section: 0)
        let indexDes = IndexPath(row: 3, section: 0)
        let cellName: NameAccountViewCell = self.tableView.cellForRow(at: indexName) as! NameAccountViewCell
        let cellDes: NameAccountViewCell = self.tableView.cellForRow(at: indexDes) as! NameAccountViewCell
        let name = cellName.txtNameAcocunt.text!
        if name == ""{
            Notice().showAlert(content: "Please input Name Account")
            return
        }
        let Acc = realm.objects(polyAccount.self).filter("type != 2")
        for a in Acc{
            if name == a.getname(){
                Notice().showAlert(content: "Name existed")
                return
            }
        }
        let des = cellDes.txtNameAcocunt.text!
        if txtMoney.text! == "0"{
            Notice().showAlert(content: "Please input balance")
            return
        }
        if account == "Cash"{
            let acc = Account()
            
            let currencybase = currencyBase().nameEnglish
            print(self.currency)
            switch self.currency {
            case currencybase[0]:
                acc.currency = 0
            case currencybase[1]:
                acc.currency = 1
            case currencybase[2]:
            acc.currency = 2
            case currencybase[3]:
            acc.currency = 3
            case currencybase[4]:
            acc.currency = 4
            
            default:
                acc.currency = 5
            }
            acc.balance = (Float(txtMoney.text!)!) / Float( currencyBase().valueBaseDolar[acc.currency])
            acc.name = name
            acc.descrip = des
            acc.includeReport = false
            let realm = try! Realm()
            if editMode == false{
                acc.add()
            }
            else{
                if editAcc.type == 0{

                try! realm.write {
                    editAcc.cashAcc?.name = acc.name
                    editAcc.cashAcc?.active = self.active
                    editAcc.cashAcc?.balance = acc.balance
                    editAcc.cashAcc?.currency = acc.currency
                    editAcc.cashAcc?.descrip = acc.descrip
                
                    editAcc.isChanged = true
                    }
                }
                else{
                    editAcc.del()
                    let index = IndexPath(row: 4, section: 0)
                    let cellbankName: AddAcountViewCell = self.tableView.cellForRow(at: index) as! AddAcountViewCell
                    let bankName = cellbankName.lblType.text!
                    let acc = BankingAccount()
                    acc.balance = Float(txtMoney.text!)!
                    let currencybase = currencyBase().nameEnglish
                    switch self.currency {
                    case currencybase[0]:
                        acc.currency = 0
                    case currencybase[1]:
                        acc.currency = 1
                    case currencybase[2]:
                    acc.currency = 2
                    case currencybase[3]:
                    acc.currency = 3
                    case currencybase[4]:
                    acc.currency = 4
                    
                    default:
                        acc.currency = 5
                    }
                    acc.name = name
                    acc.descrip = des
                    acc.includeReport = false
                    acc.bank = bank
                    acc.add()
                }
                    //let updAccount = 
                }
                
                
                }
            
        else if account == "Banking Account"{
            if bankName == "Bank Name"{
                Notice().showAlert(content: "Please select bank")
                return
            }
            let index = IndexPath(row: 4, section: 0)
            let cellbankName: AddAcountViewCell = self.tableView.cellForRow(at: index) as! AddAcountViewCell
            let bankName = cellbankName.lblType.text!
            let acc = BankingAccount()
            let currencybase = currencyBase().nameEnglish
            switch self.currency {
            case currencybase[0]:
                acc.currency = 0
            case currencybase[1]:
                acc.currency = 1
            case currencybase[2]:
            acc.currency = 2
            case currencybase[3]:
            acc.currency = 3
            case currencybase[4]:
            acc.currency = 4
            default:
                acc.currency = 5
            }
            acc.balance = (Float(txtMoney.text!)!) / Float( currencyBase().valueBaseDolar[acc.currency])
            
            
            acc.name = name
            acc.descrip = des
            acc.includeReport = false
            acc.bank = bank
            if editMode == false{
                acc.add()
                
            }
            else{
                if editAcc.type == 1{
                    try! realm.write {
                        editAcc.bankingAcc?.name = acc.name
                        editAcc.bankingAcc?.active = self.active
                        editAcc.bankingAcc?.balance = acc.balance
                        editAcc.bankingAcc?.currency = acc.currency
                        editAcc.bankingAcc?.descrip = acc.descrip
                        editAcc.bankingAcc?.bank = acc.bank
                        
                        editAcc.isChanged = true
                    }
                }
                else{
                    editAcc.del()
                    let acc = Account()
                    acc.balance = Float(txtMoney.text!)!
                    let currencybase = currencyBase().nameEnglish
                    switch self.currency {
                    case currencybase[0]:
                        acc.currency = 0
                    case currencybase[1]:
                        acc.currency = 1
                    case currencybase[2]:
                    acc.currency = 2
                    case currencybase[3]:
                    acc.currency = 3
                    case currencybase[4]:
                    acc.currency = 4
                    
                    default:
                        acc.currency = 5
                    }
                    acc.name = name
                    acc.descrip = des
                    acc.includeReport = false
                    acc.add()
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
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
            scr.accountMode = true
                  // self.present(scr, animated: true, completion: nil)
            self.navigationController?.pushViewController(scr, animated: true)
        }
        else if indexPath.row == 2{
            let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
            scr.currencyMode = true
            //self.present(scr, animated: true, completion: nil)
            self.navigationController?.pushViewController(scr, animated: true)
        }
         else if indexPath.row == 4{
                   let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
                   scr.bankingMode = true
                    //self.present(scr, animated: true, completion: nil)
            self.navigationController?.pushViewController(scr, animated: true)
               }
       
    }
    
}
