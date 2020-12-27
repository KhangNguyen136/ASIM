//
//  addTransferVc.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/28/20.
//

import UIKit
import RealmSwift
import SearchTextField

//protocol selectDestinationAccountDelegate: class {
//    func didSelectDestAccount(temp: polyAccount,name: String)
//}

class editTransferVcOld: UIViewController,selectAccountDelegate,selectDestinationAccountDelegate {
    func didSelectDestAccount(temp: polyAccount, name: String) {
        destAccount = temp
        chooseDestAccountBtn.setTitle(name, for: .normal)
    }
    
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseSourceAccountBtn.setTitle(name, for: .normal)
        return
    }
    
    var historyDelegate: editRecordDelegate? = nil
    let realm = try! Realm()
    var src: polyRecord? = nil
    var record : Transfer? = nil
    var srcAccount: polyAccount? = nil
    var destAccount: polyAccount? = nil
    var transferFee: polyRecord? = nil
    
    var userInfor: User? = nil

    
    @IBOutlet weak var typeRecord: UIButton!
    @IBOutlet weak var chooseSourceAccountBtn: UIButton!
    @IBOutlet weak var chooseDestAccountBtn: UIButton!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var locationTF: SearchTextField!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var fee: UITextField!
    
    func loadData() {
        typeRecord.clipsToBounds = true
        typeRecord.layer.cornerRadius = typeRecord.frame.width/8
        //load data from object
        record = src?.transfer
        amount.text = String(record!.amount)
        descript.text = record?.descript
        dateTime.date = record!.date
        locationTF.text = record?.location
        
        if record?.transferFee != nil
        {
            let temp = record?.transferFee?.expense
            fee.text = String(temp!.amount)
            transferFee = record?.transferFee
        }
        
        srcAccount = record?.srcAccount
        chooseSourceAccountBtn.setTitle(srcAccount?.getname(), for: .normal)
        destAccount = record?.destinationAccount
        chooseDestAccountBtn.setTitle(destAccount?.getname(), for: .normal)
        userInfor = realm.objects(User.self)[0]
        var tempStr: [String] = []
        tempStr.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
    }
    
    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func chooseSourceAccount(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func chooseDestAccount(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate1 = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func clickSave(_ sender: Any) {
        let temp = (fee.text! as NSString).floatValue
        if (amount.text! as NSString).floatValue == 0
        {
            print("You have to enter amount!")
            return
        }
        if srcAccount == nil || destAccount == nil
        {
            print("You have to choose account for this action!")
            return
        }

        //update object
        try! realm.write{
            if record?.transferFee != nil
            {
                //delete transfer fee
                if temp == 0 || fee.text == ""
                {
                    //undo transaction
                record?.transferFee?.expense?.undoTransaction()
                realm.delete((record?.transferFee?.expense)!)
                self.realm.delete((record?.transferFee)!)
                record?.transferFee = nil
                transferFee = nil
                print("Delete a transfer fee record!")
                }
                //change amount of transfer fee
                else if temp != record?.transferFee?.expense?.amount
                {
                record?.editTransFee(_fee: temp)
                }
            }
            else{
                if temp != 0
                {
                    let tempTransferFee = Expense()
                    let tempStr = "Fee of transfer from \(srcAccount?.getname() ?? "srcAccount") to \(destAccount?.getname() ?? "destAccount")"
                    //get data and do transaction
                    tempTransferFee.getData(_amount: temp, _type: 0, _descript: tempStr, _srcAccount: srcAccount!, _person: "", _location: locationTF.text ?? "", _event: "", _srcImg: "srcImage", _date: dateTime.date, _category: categoryValues().expense.count - 1, _detailCategory: 1, _borrowRecord: nil)
                    
                    let temp2 = polyRecord()
                    temp2.expense = tempTransferFee
                    temp2.type = 0
                    realm.add(temp2)
                    userInfor?.records.append(temp2)
                    transferFee = temp2
                }
            }
            let tempStr = locationTF.text ?? ""
            if tempStr.isEmpty == false && userInfor?.locations.contains(tempStr) == false
            {
            userInfor?.locations.append(tempStr)
            }
            record?.undoTransaction()
            //get data and do transaction
            record?.getData(_amount: (amount.text! as NSString).floatValue, _type: 4, _descript: descript.text ?? "", _srcAccount: srcAccount!, _location: locationTF.text ?? "", _srcImg: "", _date: dateTime.date, _destAccount: destAccount!, _transferFee: transferFee)

        }
        print("Update a transfer")
       
        historyDelegate?.editedRecord()
        //pop after save
            self.navigationController?.popViewController(animated: false)
        
    }
    
    @IBAction func clickDelete(_ sender: Any) {
        try! realm.write{
        
            if record?.transferFee != nil
            {
                record?.transferFee?.expense?.undoTransaction()
                realm.delete((record?.transferFee?.expense)!)
                realm.delete((record?.transferFee)!)
            }
            src?.transfer?.undoTransaction()
        realm.delete((src?.transfer)!)
        realm.delete(src!)
        }
        
        print("Deleted a transfer")
        historyDelegate?.editedRecord()
        self.navigationController?.popViewController(animated: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
