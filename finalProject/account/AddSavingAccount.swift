//
//  AddSavingAccount.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/15/20.
//

import UIKit
import RealmSwift

class AddSavingAccount: UIViewController {

    @IBOutlet weak var lblCurr: UILabel!
    @IBOutlet weak var lblBalance: UITextField!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet var mainview: UIView!
    @IBOutlet weak var bankView: UIView!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var lblDestAccName: UILabel!
    @IBOutlet weak var imgDestAcc: UIImageView!
    @IBOutlet weak var destAccountView: UIView!
    @IBOutlet weak var termView: UIView!
    @IBOutlet weak var interestPaidView: UIView!
    @IBOutlet weak var txtFreeInterest: UITextField!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var pickDateView: UIView!
    @IBOutlet weak var txtInterestRate: UITextField!
    @IBOutlet weak var termEndedView: UIView!
    @IBOutlet weak var lblInterestPaid: UILabel!
    @IBOutlet weak var txtDays: UITextField!
    @IBOutlet weak var lblTermEnded: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var currView: UIView!
    @IBOutlet weak var imgbank: UIImageView!
    @IBOutlet weak var lblNameBank: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var lblNameAccount: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var imgAccount: UIImageView!
    @IBOutlet weak var swincludeRecord: UISwitch!
    var share: Int = 0
    var interestPaid = ["Maturity","Up-front","Monthly"]
    var termEnded = ["Rollover principal and interest", "Rollover principal", "Close account"]
    @IBOutlet weak var destAccHeight: NSLayoutConstraint!
    var objSource: polyAccount? = nil
    var objDest: polyAccount? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        destAccountView.isHidden = true
        destAccHeight.constant = 0
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        mainview.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
        self.navigationItem.title = "Add saving account"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "MarkerFelt-Thin", size: 20)!
        ]
        //StartDate
        let pickDate = UITapGestureRecognizer(target: self, action: #selector(chooseDate(sender:)))
        pickDateView.addGestureRecognizer(pickDate)
        //Bank
        let pickBank = UITapGestureRecognizer(target: self, action: #selector(chooseBank(sender:)))
        bankView.addGestureRecognizer(pickBank)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBankName), name: .bankNotification, object: nil)
        //Currency
        let pickCurrency = UITapGestureRecognizer(target: self, action: #selector(chooseCurrency(sender:)))
        currView.addGestureRecognizer(pickCurrency)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrency), name: .currNotification, object: nil)
        //Term
        NotificationCenter.default.addObserver(self, selector: #selector(updateTerm), name: .termNotification, object: nil)
        let pickTerm = UITapGestureRecognizer(target: self, action: #selector(chooseTerm(sender:)))
        termView.addGestureRecognizer(pickTerm)
        //Interest paid view
        let pickInterestPaid = UITapGestureRecognizer(target: self, action: #selector(chooseInterestPaid(sender:)))
        interestPaidView.addGestureRecognizer(pickInterestPaid)
        //Term Ended
        let pickTermEnded = UITapGestureRecognizer(target: self, action: #selector(chooseTermEnded(sender:)))
        termEndedView.addGestureRecognizer(pickTermEnded)
        //Pick account
         NotificationCenter.default.addObserver(self, selector: #selector(updateAccount), name: .accNotification, object: nil)
        let pickAccount = UITapGestureRecognizer(target: self, action: #selector(chooseAccount(sender:)))
        accountView.addGestureRecognizer(pickAccount)
        //Pick Des Account
        let pickDestAccount = UITapGestureRecognizer(target: self, action: #selector(chooseDestAccount(sender:)))
        destAccountView.addGestureRecognizer(pickDestAccount)
    }
    @objc func updateAccount (notification: Notification){
        let dest = notification.userInfo!["dest"] as! Bool
        print(dest)
        if dest == false{
        objSource = notification.object as! polyAccount
            if objSource!.type == 0{
                let obj = objSource?.cashAcc
                imgAccount.image = UIImage(named: "accountType")
                lblNameAccount.text = obj?.name
            }
            else{
                let obj = objSource?.bankingAcc
                imgAccount.image = UIImage(named: obj!.name)
                lblNameAccount.text = obj?.name
            }
        
        }
        else{
            objDest = notification.object as! polyAccount
                       if objDest!.type == 0{
                           let obj = objDest?.cashAcc
                           imgDestAcc.image = UIImage(named: "accountType")
                           lblDestAccName.text = obj?.name
                       }
                       else{
                           let obj = objDest?.bankingAcc
                           imgDestAcc.image = UIImage(named: obj!.name)
                           lblDestAccName.text = obj?.name
                       }
        }
        }
    @objc func chooseAccount(sender: UITapGestureRecognizer) {
           let scr=self.storyboard?.instantiateViewController(withIdentifier: "PickAccountView") as! PickAccountView
        scr.dest = false
        self.navigationController?.pushViewController(scr, animated: true )
       // self.present(scr, animated: true, completion: nil)
       }
    @objc func chooseDestAccount(sender: UITapGestureRecognizer) {
              let scr=self.storyboard?.instantiateViewController(withIdentifier: "PickAccountView") as! PickAccountView
                  
        scr.dest = true
        self.navigationController?.pushViewController(scr, animated: true )
          // self.present(scr, animated: true, completion: nil)
          }
    @objc func chooseInterestPaid(sender: UITapGestureRecognizer) {
        share = 0
        let alert = UIAlertController(title: "Interest Paid Choices", message: "\n\n\n\n\n\n", preferredStyle: .alert)
              
              let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
              
              alert.view.addSubview(pickerFrame)
              pickerFrame.dataSource = self
              pickerFrame.delegate = self
              
              alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
              
              }))
              self.present(alert,animated: true, completion: nil )
    }
    @objc func chooseTermEnded(sender: UITapGestureRecognizer) {
        share = 1
        if lblInterestPaid.text == "Maturity"{
            termEnded = ["Rollover principal and interest", "Rollover principal", "Close account"]
        }
        else {
            termEnded = [ "Rollover principal", "Close account"]
        }
        let alert = UIAlertController(title: "Term Ended Choices", message: "\n\n\n\n\n\n", preferredStyle: .alert)
              
              let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
              
              alert.view.addSubview(pickerFrame)
              pickerFrame.dataSource = self
              pickerFrame.delegate = self
              
              alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
              
              }))
              self.present(alert,animated: true, completion: nil )
    }
    @objc func updateCurrency (notification: Notification){
        lblCurrency.text = notification.userInfo?["currency"] as! String
        if lblCurrency.text == "VND" {
            lblCurr.text = ".đ"
        }
        else {
            lblCurr.text = ".$"
        }

    }
    @objc func updateTerm(notification: Notification){
        lblTerm.text = notification.userInfo?["term"] as! String
    }
    @objc func updateBankName (notification: Notification){
        lblNameBank.text = notification.userInfo?["nameBank"] as! String
           let imgName = notification.userInfo?["imgBank"] as! String
        
        imgbank.image = UIImage(named:imgName)
       }
    @objc func chooseCurrency(sender: UITapGestureRecognizer) {
    let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
        scr.currencyMode = true
       // self.present(scr, animated: true, completion: nil)
        self.navigationController?.pushViewController(scr, animated: true)
        
    }
    @objc func chooseTerm(sender: UITapGestureRecognizer) {
    let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
        scr.termmMode = true
        //self.present(scr, animated: true, completion: nil)
        self.navigationController?.pushViewController(scr, animated: true)
        
    }
    @objc func chooseBank(sender: UITapGestureRecognizer) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
        scr.bankingMode = true
        self.navigationController?.pushViewController(scr, animated: true)
       // self.present(scr, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        if lblTerm.text != "Term"{
            let term = lblTerm.text!.components(separatedBy: " ")[1]
            if term != "months"{
                interestPaid = ["Maturity","Up-front"]
        
            }
            else {
                interestPaid = ["Maturity","Up-front","Monthly"]
            }
        }
    }
    @objc func chooseDate(sender: UITapGestureRecognizer) {
       let alert = UIAlertController(title: "Choose Date", message: "", preferredStyle: .alert)
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
        alert.view.addConstraint(height)
       let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.frame = CGRect(x: 10, y: 60, width: 250, height: 140)
        datePicker.backgroundColor = UIColor.white
        

       alert.view.addSubview(datePicker)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
           let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
        let selectedDate: String = dateFormatter.string(from: datePicker.date)
        let today: String =  dateFormatter.string(from: Date())
        if selectedDate == today{
            self.lblStartDate.text =  "Today"
        }
        else{self.lblStartDate.text =  "\(selectedDate)"}
       
        }))
        self.present(alert,animated: true, completion: nil )
    }

    @IBAction func saveAccount(_ sender: Any) {
        let realm = try! Realm()
        let acc = savingAccount()
        acc.id = acc.incrementID()
        if txtName.text! == ""{
            Notice().showAlert(content: "Please input Account name")
            return;
        }
        acc.name = txtName.text!
        if lblBalance.text! == "0"{
            Notice().showAlert(content: "Please input amount")
            return;
          }
        acc.ammount = Float(lblBalance.text!) as! Float
       
        if lblNameBank.text! == "Bank"{
           Notice().showAlert(content: "Please choose Bank")
            return;
       }
        acc.currency = lblCurrency.text!
        acc.bank = lblNameBank.text!.components(separatedBy: " ")[2]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if lblStartDate.text == "Today"{
             acc.startdate = Date()
        }
        else{
            acc.startdate = dateFormatter.date(from: lblStartDate.text!)!
        }
        acc.interestRate = Float(txtInterestRate.text!) as! Float
        acc.freeInterestRate = Float(txtFreeInterest.text!) as! Float
        if lblInterestPaid.text == "Maturity"{
            acc.interestPaid = 0
        }
        else if lblInterestPaid.text == "Up-front"{
            acc.interestPaid = 1
        }
        else {
            acc.interestPaid = 2
        }
        if lblTermEnded.text == "Rollover principal"{
            acc.termEnded = 1
        }
        else if lblTermEnded.text == "Close account" {
            acc.termEnded = 2
        }
        else {
            acc.termEnded = 0
        }
        if lblTerm.text! == "Term"{
          Notice().showAlert(content: "Please choose Term")
           return;
        }
        acc.term = lblTerm.text!
        if objSource == nil{
                  Notice().showAlert(content: "Please choose Source Account")
                   return;
              }
        acc.srcAccount = objSource
        acc.numDays = Int(txtDays.text!) as! Int
        acc.descrip = txtDescription.text!
        if swincludeRecord.isOn == true{
           acc.includeRecord = false
           
        }
       else {
           acc.includeRecord = true
       }
        if acc.interestPaid == 1 || acc.interestPaid == 2{
            if objDest == nil{
                Notice().showAlert(content: "Please choose Dest Account")
                 return;
            }
            acc.destAccount = objDest
        }
        
        if acc.srcAccount?.type == 0{
            let srcAcc = acc.srcAccount?.cashAcc
            try! realm.write {
                //Tru vao sourceAcc
                srcAcc!.expense(amount: acc.ammount)
            }
            
        }
        else if acc.srcAccount?.type == 1{
        let srcAcc = acc.srcAccount?.bankingAcc
        let transfer = Transfer()
            transfer.id = acc.id
        
        try! realm.write {
            //Tru vao sourceAcc
            srcAcc!.expense(amount: acc.ammount)
        }
        }

        if acc.interestPaid == 0 || acc.interestPaid == 2{
                
                var dateComponent = DateComponents()
                let term = acc.term
                switch term{
                case "1 week", "2 weeks", "3 weeks":
                    let addDays = Int(term.components(separatedBy: " ")[0]) as! Int
                    dateComponent.day = addDays*7
                case "1 month", "3 months", "6 months", "12 months":
                    let addMonths = Int( term.components(separatedBy: " ")[0]) as! Int
                    dateComponent.month = addMonths
                default:
                    dateComponent.day = 0
            }
                acc.nextTermDate = Calendar.current.date(byAdding: dateComponent, to: acc.startdate)!
            
            
        }
        else{
            acc.nextTermDate = acc.startdate

        }
        acc.add()
        let polyAcc = realm.objects(polyAccount.self).filter("type == 2")
        for sav in polyAcc{
            if sav.savingAcc!.id == acc.id{
                let transfer = Transfer()
                transfer.id = sav.id
                try! realm.write{
                    transfer.getData(_amount: acc.ammount, _type: 4, _descript: "", _srcAccount: acc.srcAccount!, _location: "", _srcImg: "", _date: sav.savingAcc!.startdate, _destAccount: sav, _transferFee:nil)
                }
                transfer.add()
            }
        }
       self.navigationController?.popViewController(animated: true)
       }
    }

extension AddSavingAccount: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if share == 0{
            if lblTerm.text != "Term"{
                let term = lblTerm.text!.components(separatedBy: " ")[1]
                if term != "months"{
                    interestPaid = ["Maturity","Up-front"]
                }
                else {
                    interestPaid = ["Maturity","Up-front","Monthly"]
                }
            }
            return interestPaid.count
            
        }
        return termEnded.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if share == 0{return interestPaid[row]}
        return termEnded[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if share == 0 {lblInterestPaid.text = interestPaid[row]
            if lblInterestPaid.text == "Up-front" || lblInterestPaid.text == "Monthly" {
                destAccountView.isHidden = false
                destAccHeight.constant = 60
            }
            else {
                destAccountView.isHidden = true
                destAccHeight.constant = 0
                imgDestAcc.image = UIImage(named:"bank")
                lblDestAccName.text = "Interest paid to"
                
            }
        }
        lblTermEnded.text = termEnded[row]
    }
    
}
