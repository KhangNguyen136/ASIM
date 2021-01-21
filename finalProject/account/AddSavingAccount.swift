//
//  AddSavingAccount.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/15/20.
//

import UIKit
import RealmSwift

class AddSavingAccount: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var StartDate: UILabel!
    @IBOutlet weak var FreeInterestRate: UILabel!
    @IBOutlet weak var numOfDayForInterest: UILabel!
    @IBOutlet weak var InterestRate: UILabel!
    @IBOutlet weak var RateYear1: UILabel!
    @IBOutlet weak var TransferMoneyFrom: UILabel!
    @IBOutlet weak var Bank: UILabel!
    @IBOutlet weak var Amount: UILabel!
    @IBOutlet weak var RateYear: UILabel!
    @IBOutlet weak var Day: UILabel!
    @IBOutlet weak var InterestPaidTo: UILabel!
    @IBOutlet weak var NotAddToRecord: UILabel!
    @IBOutlet weak var TermEnded: UILabel!
    @IBOutlet weak var InterestPaid: UILabel!
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
    var isVietNamese = false
    var bank = 0
    var share: Int = 0
    var currency = 0
    var interestPaid: [String] = Interest().interestPaidEnglish
    var termEnded: [String] = Interest().termEndedEnglish
    @IBOutlet weak var destAccHeight: NSLayoutConstraint!
    var objSource: polyAccount? = nil
    var objDest: polyAccount? = nil
    override func viewDidLoad() {
        //Tiêu đề
        self.navigationItem.title = "Add saving account"
        //Kiểm tra language
        let realm = try! Realm()
        let lang = realm.objects(User.self).first?.isVietnamese
        if lang == true{
            interestPaid = Interest().interestPaidVietnamese
            termEnded = Interest().termEndedVietnamese
            lblCurrency.text = currencyBase().nameVietnamese[0]
            lblTermEnded.text = Interest().termEndedVietnamese[0]
            lblInterestPaid.text = Interest().interestPaidVietnamese[0]
            self.navigationItem.title = "Thêm tài khoản tiết kiệm"
            isVietNamese = true
            lblStartDate.text == "Hôm nay"
        }
        else{
            lblCurrency.text = currencyBase().nameEnglish[0]
            lblTermEnded.text = Interest().termEndedEnglish[0]
             lblInterestPaid.text = Interest().interestPaidEnglish[0]
            
        }
        lblCurr.text = currencyBase().symbol[0]
        setLanguage()
        txtFreeInterest.delegate = self
        txtInterestRate.delegate = self
        lblBalance.delegate = self
        super.viewDidLoad()
        destAccountView.isHidden = true
        destAccHeight.constant = 0
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        mainview.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        let withDecimal = (
            string == NumberFormatter().decimalSeparator &&
            textField.text?.contains(string) == false
        )
        return isNumber || withDecimal
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
    func setLanguage(){
       
        InterestRate.setupAutolocalization(withKey: "InterestRate", keyPath: "text")
InterestPaid.setupAutolocalization(withKey: "InterestPaid", keyPath: "text")
        InterestPaid.setupAutolocalization(withKey: "InterestPaid", keyPath: "text")
        InterestPaidTo.setupAutolocalization(withKey: "InterestPaidTo", keyPath: "text")
        FreeInterestRate.setupAutolocalization(withKey: "FreeInterestRate", keyPath: "text")
         TermEnded.setupAutolocalization(withKey: "TermEnded", keyPath: "text")
        numOfDayForInterest.setupAutolocalization(withKey: "numOfDayForInterest", keyPath: "text")
        TransferMoneyFrom.setupAutolocalization(withKey: "TransferMoneyFrom", keyPath: "text")
        NotAddToRecord.setupAutolocalization(withKey: "NotAddToRecord", keyPath: "text")
        
        RateYear.setupAutolocalization(withKey: "RateYear", keyPath: "text")
        RateYear1.setupAutolocalization(withKey: "RateYear", keyPath: "text")
        Day.setupAutolocalization(withKey: "Day", keyPath: "text")
        Bank.setupAutolocalization(withKey: "Bank", keyPath: "text")
        Amount.setupAutolocalization(withKey: "Amount", keyPath: "text")
        StartDate.setupAutolocalization(withKey: "StartDate", keyPath: "text")
        lblTerm.setupAutolocalization(withKey: "Term", keyPath: "text")
        
        
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
        if self.isVietNamese == true{
            if lblInterestPaid.text == interestPaid[0]{
           termEnded = Interest().termEndedVietnamese    }
       else {
           var temp = Interest().termEndedVietnamese
           temp.removeFirst()
           termEnded = temp
       }
        }
        else{
            if lblInterestPaid.text == interestPaid[0]{
                termEnded = Interest().termEndedEnglish     }
            else {
                var temp = Interest().termEndedEnglish
                temp.removeFirst()
                termEnded = temp
            }
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
        let index = notification.userInfo?["currency"] as! String
        self.currency = Int(index)!
        lblCurrency.text = currencyBase().nameEnglish[Int(index)!]
            lblCurr.text = currencyBase().symbol[Int(index)!]
    }
    @objc func updateTerm(notification: Notification){
        lblTerm.text = notification.userInfo?["term"] as! String
    }
    @objc func updateBankName (notification: Notification){
        let index = notification.userInfo?["bank"] as! String
        self.bank = Int(index)!
        lblNameBank.text = infoChoice().bankName[Int(index)!]
        imgbank.image = UIImage(named:infoChoice().bankImg[Int(index)!] )
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
            if self.isVietNamese == true{
                self.lblStartDate.text =  "Hôm nay"
            }
            
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
        acc.ammount = (Float(lblBalance.text!) as! Float) / Float( currencyBase().valueBaseDolar[self.currency])
        print(acc.ammount)
       
        if lblNameBank.text! == "Bank"{
           Notice().showAlert(content: "Please choose Bank")
            return;
       }
        acc.currency = self.currency
        acc.bank = self.bank
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if lblStartDate.text == "Today"{
             acc.startdate = Date()
        }
        else if lblStartDate.text == "Hôm nay"{
             acc.startdate = Date()
        }
        else{
            acc.startdate = dateFormatter.date(from: lblStartDate.text!)!
        }
        acc.interestRate = Float(txtInterestRate.text!) as! Float
        acc.freeInterestRate = Float(txtFreeInterest.text!) as! Float
        if lblInterestPaid.text == interestPaid[0]{
            acc.interestPaid = 0
        }
        else if lblInterestPaid.text == interestPaid[1]{
            acc.interestPaid = 1
        }
        else {
            acc.interestPaid = 2
        }
        print(lblTermEnded.text)
        print(termEnded)
        if lblTermEnded.text! == termEnded[1]{
            acc.termEnded = 1
        }
        else if lblTermEnded.text! == termEnded[2] {
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
        if acc.interestPaid == 1{
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
       
        try! realm.write {
            //Tru vao sourceAcc
            srcAcc!.expense(amount: acc.ammount)
        }
        }

        if acc.interestPaid == 0 || acc.interestPaid == 2{
                
                var dateComponent = DateComponents()
            var listTerm: [String] = infoChoice().termEnglish
            if isVietNamese == true {
                listTerm = infoChoice().termVietnamese
            }
                let term = acc.term
                switch term{
                case listTerm[0], listTerm[1], listTerm[2]:
                    let addDays = Int(term.components(separatedBy: " ")[0]) as! Int
                    dateComponent.day = addDays*7
                case listTerm[3], listTerm[4], listTerm[5], listTerm[6]:
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
            if sav.savingAcc!.name == acc.name{
                let transfer = Transfer()
               
                try! realm.write{
                    transfer.getData(_amount: acc.ammount, _type: 4, _descript: "Create a deposit account", _srcAccount: acc.srcAccount!, _location: "", _srcImg: nil, _date: sav.savingAcc!.startdate, _destAccount: sav, _transferFee:nil)
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
            if lblInterestPaid.text == interestPaid[1]{
                destAccountView.isHidden = false
                destAccHeight.constant = 60
            }
            else {
                destAccountView.isHidden = true
                destAccHeight.constant = 0
                imgDestAcc.image = UIImage(named:"bank")
                if isVietNamese == true{
                    lblDestAccName.text = "Tiền lãi được chuyển đến TK"
                }
                else{
                    lblDestAccName.text = "Interest paid to"
                }
                                
            }
        }
        lblTermEnded.text = termEnded[row]
    }
    
}
