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
    var editID: Int = 0
    var editMode = false
    @IBOutlet weak var txtbalance: UITextField!
    

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
    @IBOutlet weak var deleteBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtbalance.delegate = self
        //Hide Enđate
        if endTimeMode == false{
            lbltitleEnd.isHidden = true
            lblendTime.text = "For how long?"
        }
        if editMode == false {
            self.navigationItem.title = "Add accumulate account"
            saveEditBtn.isHidden = true
            deleteBtn.isHidden = true
            
        }
        else {
            self.navigationItem.title = "Edit accumulate"
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
       
        
    }
    func loadEditView(){
        let realm = try! Realm()
        let obj = realm.objects(Accumulate.self).filter("id == \(editID)").first as! Accumulate
        lblgoal.text = obj.goal
        lblCurrency.text = obj.currency
        let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "MM/dd/yyyy"
                
        lblStartDate.text = dateFormatter.string(from: obj.startdate)
        lblendTime.text = dateFormatter.string(from: obj.enddate)
        txtbalance.text = "\(obj.balance)"
    }
    @objc func updateCurrency (notification: Notification){
        let currency = notification.userInfo?["currency"] as! String
        if currency == "VND" {
            lblCurrency.text = "VND"
            lblshCurrency.text = "đ"
        }
        else {
            lblCurrency.text = "USD"
            lblshCurrency.text = "$"
        }
        self.view.layoutIfNeeded()
    }
    @IBAction func saveEditedAccumulate(_ sender: Any) {
        let realm = try! Realm()
        let obj = realm.objects(Accumulate.self).filter("id == \(editID)").first as! Accumulate
        //Edit accumulate
         let acc = Accumulate()
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MM/dd/yyyy"
        if txtbalance.text! == ""{
            Notice().showAlert(content: "Please input amount")
            return
        }
         acc.balance = Float(txtbalance.text!)!
         acc.currency = lblCurrency.text!
         let strEndDate = (lblendTime.text!).components(separatedBy: " ")[0]
         acc.startdate = dateFormatter.date(from: lblStartDate.text!)!
        if strEndDate == ""{
            Notice().showAlert(content: "Please input For how long ")
            return
        }
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
        switch howLong{
        case "1 month": dateComponent.month = 1
        case "3 months": dateComponent.month = 3
        case "6 months": dateComponent.month = 6
        case "1 year": dateComponent.year = 1
        case "2 years": dateComponent.year = 2
        case "5 years": dateComponent.year = 5
        case "10 years": dateComponent.year = 10
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
            let obj = realm.objects(Accumulate.self).filter("id == \(self.editID)")
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
        acc.balance = Float(txtbalance.text!)!
        acc.currency = lblCurrency.text!
        if lblendTime.text! == "For how long?"{
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
       try! realm.write {
            realm.add(acc)
            }
        delegate?.loadTable()
       //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        }
    }
    

