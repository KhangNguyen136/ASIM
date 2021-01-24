//
//  AddAccumulateView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/14/20.
//

import UIKit
import RealmSwift
import SCLAlertView
protocol delegateUpdate {
    func loadTable()
}
class AddAccumulateView: UIViewController, UITextFieldDelegate {
    var delegate: delegateUpdate?
    var editGoal: String = ""
    var editMode = false
    var isVietnamese = false
    @IBOutlet weak var txtbalance: UITextField!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var notAddToReport: UILabel!
    

    @IBOutlet weak var lblgoal: UITextField!
    @IBOutlet weak var lbltitleEnd: UILabel!
    @IBOutlet weak var lblendTime: UILabel!
    @IBOutlet weak var howLongView: UIView!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var dateView: UIStackView!
    @IBOutlet weak var lblshCurrency: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var goalView: UIView!
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var includeSw: UISwitch!
    var endTimeMode = false
    @IBOutlet weak var saveEditBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var Amount: UILabel!
    var currencyList: [String] = currencyBase().nameEnglish
    var currencySymbol: [String] = currencyBase().symbol
    var typeCurrency = 0
    override func viewDidLoad() {
        let realm = try! Realm()
        let lang = realm.objects(User.self).first?.isVietnamese
        print(editGoal)
        if lang == true{
            isVietnamese = true
            currencyList = currencyBase().nameVietnamese
        }
        else{
            
        }
        lblCurrency.text = currencyList[0]
        lblshCurrency.text = currencySymbol[0]
        super.viewDidLoad()
        txtbalance.delegate = self
        //Hide Enđate
        if endTimeMode == false{
            lbltitleEnd.isHidden = true
            lblendTime.text = "For how long?"
        }
        if editMode == false {
            self.navigationItem.title = "Add accumulate account"
            if isVietnamese == true{
                self.navigationItem.title = "Thêm tích luỹ"
            }
            saveEditBtn.isHidden = true
            
        }
        else {
            self.navigationItem.title = "Edit accumulate"
            if isVietnamese == true{
                self.navigationItem.title = "Chỉnh sửa tích luỹ"
            }
            saveBtn.isHidden = true
            loadEditView()
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        let pickDate = UITapGestureRecognizer(target: self, action: #selector(chooseDate(sender:)))
        let pickTime = UITapGestureRecognizer(target: self, action: #selector(chooseTime(sender:)))
        dateView.addGestureRecognizer(pickDate)
    currencyView.addGestureRecognizer(tapGesture)
        howLongView.addGestureRecognizer(pickTime)
    NotificationCenter.default.addObserver(self, selector: #selector(updateCurrency), name: .currNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: .timeNotification, object: nil)
       setLanguage()
        
    }
    func setLanguage(){
        startDate.setupAutolocalization(withKey: "StartDate", keyPath: "text")
       Amount.setupAutolocalization(withKey: "Amount", keyPath: "text")
        lblendTime.setupAutolocalization(withKey: "howLong", keyPath: "text")
        
        notAddToReport.setupAutolocalization(withKey: "NotAddToRecord", keyPath: "text")
        lbltitleEnd.setupAutolocalization(withKey: "EndDate", keyPath: "text")
        
    }
    func loadEditView(){
        let realm = try! Realm()
        let obj = realm.objects(Accumulate.self).filter("goal == '\(editGoal)'").first!
        lblgoal.text = obj.goal
        lblCurrency.text = currencyList[obj.currency]
        let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "MM/dd/yyyy"
                
        lblStartDate.text = dateFormatter.string(from: obj.startdate)
        lblendTime.text = dateFormatter.string(from: obj.enddate)
        txtbalance.text = "\(round((obj.balance as! Float)*Float(currencyBase().valueBaseDolar[obj.currency])))"
    }
    @objc func updateCurrency (notification: Notification){
        let index = notification.userInfo?["currency"] as! String
        
            lblCurrency.text = currencyList[Int(index)!]
            lblshCurrency.text = currencySymbol[Int(index)!]
        typeCurrency = Int(index)!
        self.view.layoutIfNeeded()
    }
    @IBAction func saveEditedAccumulate(_ sender: Any) {
        let realm = try! Realm()
        let obj = realm.objects(Accumulate.self).filter("goal == '\(editGoal)'").first as! Accumulate
        //Edit accumulate
         let acc = Accumulate()
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MM/dd/yyyy"
        if txtbalance.text! == ""{
            Notice().showAlert(content: "Please input amount")
            return
        }
         acc.balance = (Float(txtbalance.text!)!) / Float( currencyBase().valueBaseDolar[typeCurrency])
         acc.currency = typeCurrency
        if lblendTime.text! == "For how long?"{
            Notice().showAlert(content: "Please input For how long ")
            return
        }
         else if lblendTime.text! == "Trong bao lâu?"{
             Notice().showAlert(content: "Please input For how long ")
             return
         }
         let strEndDate = (lblendTime.text!).components(separatedBy: " ")[0]
         acc.startdate = dateFormatter.date(from: lblStartDate.text!)!
        
         acc.enddate = dateFormatter.date(from: strEndDate)!
        if lblgoal.text! == ""{
            Notice().showAlert(content: "Please input goal")
            return
        }
         acc.goal = lblgoal.text!
         if includeSw.isOn == true{
             acc.includeReport = false
             
         }
         else {
             acc.includeReport = true
         }
        try! realm.write {
            obj.goal = acc.goal
            obj.balance = acc.balance
            obj.currency = acc.currency
            obj.startdate = acc.startdate
            obj.enddate = acc.enddate
            obj.includeReport = acc.includeReport

        }
         delegate?.loadTable()
         self.navigationController?.popViewController(animated: true)
    }
    @objc func updateTime (notification: Notification){
         let howLong = notification.userInfo?["time"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let startDate = dateFormatter.date(from: lblStartDate.text!)
        var dateComponent = DateComponents()
        var time: [String] =  infoChoice().howLongEnglish
        if isVietnamese == true{
            time = infoChoice().howLongVietnamses
        }
        switch howLong{
        case time[0]: dateComponent.month = 1
        case time[1]: dateComponent.month = 3
        case time[2]: dateComponent.month = 6
        case time[3]: dateComponent.year = 1
        case time[4]: dateComponent.year = 2
        case time[5]: dateComponent.year = 5
        case time[6]: dateComponent.year = 10
        default:
            dateComponent.month = 0
        }
        let endDate = Calendar.current.date(byAdding: dateComponent, to: startDate!)
        lblendTime.text = "\( dateFormatter.string(from: endDate!)) (\(howLong))"
        lbltitleEnd.isHidden = false
        self.view.layoutIfNeeded()
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
            scr.currencyMode = true
        self.navigationController?.pushViewController(scr, animated: true)
    }
    @objc func chooseTime(sender: UITapGestureRecognizer) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "ChoiceAccountView") as! ChoiceAccountView
            scr.timeMode = true
            //self.present(scr, animated: true, completion: nil)
        self.navigationController?.pushViewController(scr, animated: true)
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
                    
        self.lblStartDate.text =  "\(selectedDate)"
       
        }))
        self.present(alert,animated: true, completion: nil )
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        let withDecimal = (
            string == NumberFormatter().decimalSeparator &&
            textField.text?.contains(string) == false
        )
        return isNumber || withDecimal
    }

  
    @IBAction func deleteAccumulate(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("OK") {
            let realm = try! Realm()
            let transfer = realm.objects(polyRecord.self).filter("type == 4")
           for i in transfer{
            print (i.transfer?.srcAccount?.getname(),self.editGoal)
            if i.transfer?.srcAccount?.getname() == self.editGoal{
                   i.del()
               }
            else if i.transfer?.destinationAccount?.getname() == self.editGoal{
                   i.del()
               }
           }
            let obj = realm.objects(Accumulate.self).filter("goal == \(self.editGoal)")
            try! realm.write {
                        realm.delete(obj)
                    }
            self.delegate?.loadTable()
            self.navigationController?.popViewController(animated: true)
               
            }
        alertView.addButton("Exit") {
                   }
        alertView.showError("Warning", subTitle: "If you delete this Acocunt, all Record in this Accumulate will also be removed and cannot be restored ")
    }
    @IBAction func saveData(_ sender: Any) {
        let realm = try! Realm()
        let acc = Accumulate()
        acc.id = acc.incrementID()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        acc.addbalance = 0.0
        if txtbalance.text! == "0"{
           Notice().showAlert(content: "Please input amount")
           return
       }
        acc.balance = (Float(txtbalance.text!)!) / Float( currencyBase().valueBaseDolar[typeCurrency])
        
        acc.currency = typeCurrency
        if lblendTime.text! == "For how long?"{
           Notice().showAlert(content: "Please input For how long ")
           return
       }
        else if lblendTime.text! == "Trong bao lâu?"{
            Notice().showAlert(content: "Please input For how long ")
            return
        }
        let strEndDate = (lblendTime.text!).components(separatedBy: " ")[0]
        acc.startdate = dateFormatter.date(from: lblStartDate.text!)!
        acc.enddate = dateFormatter.date(from: strEndDate)!
        if lblgoal.text! == "What is the goal?"{
           Notice().showAlert(content: "Please input goal")
           return
       }
        acc.goal = lblgoal.text!
        if includeSw.isOn == true{
            acc.includeReport = false
            
        }
        else {
            acc.includeReport = true
        }
        acc.add()
        delegate?.loadTable()
       SCLAlertView().showSuccess("Accumulate added!", subTitle: "")
        self.navigationController?.popViewController(animated: true)
        }
    }
    

