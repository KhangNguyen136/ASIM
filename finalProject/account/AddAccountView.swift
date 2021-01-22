//
//  AddAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/1/20.
//

import UIKit
import RealmSwift
import SCLAlertView
import DPLocalization
protocol updateDataDelegate {
    func updateTable()
}
class AddAccountView: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var bankViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var lblAccType: UILabel!
    @IBOutlet weak var imgBank: UIImageView!
    @IBOutlet weak var lblBankName: UILabel!
    @IBOutlet weak var txtNameAcc: UITextField!
    @IBOutlet weak var bankView: UIView!
    @IBOutlet weak var Amount: UILabel!
    var editMode = false
    var editAcc: polyAccount = polyAccount()
    var delegate: updateDataDelegate?
    @IBOutlet weak var typeAccountView: UIView!
    @IBOutlet weak var descripView: UIView!
    @IBOutlet weak var currView: UIView!
    var currency: String = currencyBase().nameEnglish[0]
    var imgName = "bank"
    let currencyFormatter = NumberFormatter()
    
    //Edit mode
    var active = true
    var balance: String = "0"
    var bank = -1
    var isVietnamese = false
    var curr = 0
    var accType = 0
    @IBOutlet weak var lblCurr: UILabel!
    @IBOutlet weak var txtMoney: UITextField!
    var currencyList: [String] = currencyBase().nameEnglish
    var currencySymbol: [String] = currencyBase().symbol
    var typeAccList: [String] = infoChoice().typeAccountEnglish
    var typeCurrency = 0
    override func viewDidLoad() {
      
        typeAccountView.layer.borderWidth = 1
        typeAccountView.layer.borderColor = UIColor.lightGray.cgColor
        accountView.layer.borderWidth = 1
        accountView.layer.borderColor = UIColor.lightGray.cgColor
        currView.layer.borderWidth = 1
        currView.layer.borderColor = UIColor.lightGray.cgColor
        descripView.layer.borderWidth = 1
        descripView.layer.borderColor = UIColor.lightGray.cgColor
        txtMoney.delegate = self
        bankView.isHidden = true
        bankViewHeight.constant = 0
        setLanguage()
        txtNameAcc.placeholder = "Name account"
        txtDescription.placeholder = "Description"
        //Format textfield currency
        
        //
        let realm = try! Realm()
               let lang = realm.objects(User.self).first?.isVietnamese
               if lang == true{
                   isVietnamese = true
                   currencyList = currencyBase().nameVietnamese
                lblCurr.text = currencyBase().nameVietnamese[0]
                txtNameAcc.placeholder = "Tên tài khoản"
                txtDescription.placeholder = "Diễn giải"
                typeAccList = infoChoice().typeAccountVietnamese
               }
        lblCurr.text = currencyList[0]
        lblAccType.text = typeAccList[0]
       lblCurrency.text = currencySymbol[0]
        super.viewDidLoad()
        if editMode == true {
            if editAcc.type == 0{
                currency = currencyBase().nameEnglish[editAcc.cashAcc!.currency]
                lblCurrency.text = currencyBase().symbol[editAcc.cashAcc!.currency]
                balance = "\(round((editAcc.cashAcc?.balance as! Float)*Float(currencyBase().valueBaseDolar[editAcc.cashAcc!.currency])))"
                active = editAcc.cashAcc!.active
                txtNameAcc.text = editAcc.cashAcc?.name
                txtDescription.text = editAcc.cashAcc?.descrip
                
            }
            else{
                currency = currencyBase().nameEnglish[editAcc.bankingAcc!.currency]
                lblCurrency.text = currencyBase().symbol[editAcc.bankingAcc!.currency]
                balance = "\(round((editAcc.bankingAcc?.balance as! Float)*Float(currencyBase().valueBaseDolar[editAcc.bankingAcc!.currency])))"
                active = editAcc.bankingAcc!.active
                txtNameAcc.text = editAcc.bankingAcc?.name
                txtDescription.text = editAcc.bankingAcc?.descrip
            }
            
            
        }
        let pickAccType = UITapGestureRecognizer(target: self, action: #selector(chooseAccType(sender:)))
               typeAccountView.addGestureRecognizer(pickAccType)
        let pickBank = UITapGestureRecognizer(target: self, action: #selector(chooseBank(sender:)))
        bankView.addGestureRecognizer(pickBank)
        let pickCurrency = UITapGestureRecognizer(target: self, action: #selector(chooseCurrency (sender:)))
        currView.addGestureRecognizer(pickCurrency)
        txtMoney.text = balance
        
           //self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.white;
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrency), name: .currNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBankName), name: .bankNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAccountType), name: .accountNotification, object: nil)
       }
   

   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
          let withDecimal = (
              string == NumberFormatter().decimalSeparator &&
              textField.text?.contains(string) == false
          )
          return isNumber || withDecimal
      }
    func setLanguage(){
        lblBankName.setupAutolocalization(withKey: "BankName", keyPath: "text")
        Amount.setupAutolocalization(withKey: "Amount", keyPath: "text")
        }
     @objc func chooseAccType(sender: UITapGestureRecognizer) {
           let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
                      scr.accountMode = true
                      self.navigationController?.pushViewController(scr, animated: true)
       }
    @objc func chooseBank(sender: UITapGestureRecognizer) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
                   scr.bankingMode = true
                   self.navigationController?.pushViewController(scr, animated: true)
    }
    @objc func chooseCurrency(sender: UITapGestureRecognizer) {
              let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
              scr.currencyMode = true
              self.navigationController?.pushViewController(scr, animated: true)
          }
    @IBAction func deleteBtn(_ sender: Any) {
         let realm = try! Realm()
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("OK") {
            self.editAcc.del()
            self.navigationController?.popViewController(animated: true)
        }
        alertView.addButton("Exit") {
            
                   }
        alertView.showError("Warning", subTitle: "If you delete this Acocunt, all Record in this Account will also be removed and cannot be restored ")
        
        
    }
    @objc func updateCurrency (notification: Notification){
        let index = notification.userInfo!["currency"] as! String

        lblCurrency.text = currencyBase().symbol[Int(index)!]
        lblCurr.text = currencyList[Int(index)!]
        curr = Int(index)!
        
       
        
        self.view.layoutIfNeeded()
    }
    @objc func updateBankName (notification: Notification){
        let index = notification.userInfo?["bank"] as! String
        self.bank = Int(index)!
        lblBankName.text = infoChoice().bankName[Int(index)!]
        imgBank.image = UIImage(named: infoChoice().bankImg[Int(index)!] )
    }
    @objc func updateAccountType(notification: Notification){
        let index =  (notification.userInfo?["accountType"] as! String)
        accType = Int(index)!
        lblAccType.text = typeAccList[accType]
        if accType == 1{
            bankView.isHidden = false
            bankViewHeight.constant = 50
        }
        else{
            bankView.isHidden = true
            bankViewHeight.constant = 0
        }
    }


    @IBAction func savebtn(_ sender: Any) {
        let realm = try! Realm()

        let name = txtNameAcc.text!
        if name == ""{
            Notice().showAlert(content: "Please input Name Account")
            return
        }
        var Acc = realm.objects(polyAccount.self).filter("type != 2")
        Acc = Acc.filter("type != 3")
        for a in Acc{
            if name == a.getname() && editMode == false{
                Notice().showAlert(content: "Name existed")
                return
            }
        }
        let des = txtDescription.text!
        if txtMoney.text! == "0"{
            Notice().showAlert(content: "Please input balance")
            return
        }
        //Tiền mặt
        if accType == 0{
            let acc = Account()
            
            acc.currency = self.curr
            acc.balance = (Float(txtMoney.text!)!) / Float( currencyBase().valueBaseDolar[acc.currency])
            acc.name = name
            acc.descrip = des
            acc.includeReport = false
            let realm = try! Realm()
            //Nếu không phải chế độ edit thì thêm
            if editMode == false{
                acc.add()
            }
                //Nếu là chế độ edit
            else if editMode == true{
                //Tài khoản cũ là tiền mặt thì edit
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
                    //Tài khoản cũ là ngân hàng thì xoá tk cũ, thêm tk mới là tk tiền mặt
                else{
                    editAcc.del()
                    let acc = Account()
                    acc.currency = self.curr
                    acc.balance = (Float(txtMoney.text!)!) / Float( currencyBase().valueBaseDolar[acc.currency])
                    acc.name = name
                    acc.descrip = des
                    acc.includeReport = false
                    acc.add()
                }
                }
                
                
                }
        // Tài khoản sau edit là tk ngân hàng
        else if accType == 1{
            if lblBankName.text == "Bank Name" || lblBankName.text == "Tên ngân hàng"{
                Notice().showAlert(content: "Please select bank")
                return
            }

            let acc = BankingAccount()
            let currencybase = currencyBase().nameEnglish
            acc.currency = self.curr
            acc.balance = (Float(txtMoney.text!)!) / Float( currencyBase().valueBaseDolar[acc.currency])
            
            
            acc.name = name
            acc.descrip = des
            acc.includeReport = false
            acc.bank = self.bank
            if editMode == false{
                acc.add()
                
            }
            else if editMode == true{
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
                    let acc = BankingAccount()
                    acc.balance = Float(txtMoney.text!)!
                    acc.currency = self.curr
                    let currencybase = (Float(txtMoney.text!)!) / Float( currencyBase().valueBaseDolar[acc.currency])
                    acc.name = name
                    acc.descrip = des
                    acc.includeReport = false
                    acc.bank = self.bank
                    acc.add()
                }
            }

            }

        else {
            delegate?.updateTable()}
        if editMode == false{
            SCLAlertView().showSuccess("Account added!", subTitle: "")
        }
        else{
            SCLAlertView().showSuccess("Saved edit!", subTitle: "")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
}


