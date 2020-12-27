//
//  addRecordVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import RealmSwift
import SearchTextField

class editExOrInVCOld: UIViewController,selectCategoryDelegate,selectAccountDelegate {
    
    var historyDelegate : editRecordDelegate? = nil
    var record: polyRecord? = nil
    
    var type = -1
    
    var category = -1
    
    var detailCategory = -1
        
    let realm = try! Realm()
    var tempRecord: polyRecord? = nil
    var srcAccount: polyAccount? = nil
    var userInfor: User? = nil
    
    @IBOutlet weak var chooseTypeRecordBtn: UIButton!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    
    @IBOutlet weak var dateTime: UIDatePicker!
    
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var amount: UITextField!
    
    @IBOutlet weak var chooseAccountBtn: UIButton!
    
    @IBOutlet weak var personTF: SearchTextField!
    
    @IBOutlet weak var locationTF: SearchTextField!
    
    @IBOutlet weak var eventTF: SearchTextField!
    @IBOutlet weak var descript: UITextField!
    
    func didSelectRepayOrCollectDebt(_type: Int, temp: polyRecord) {
        type = _type
        loadData()
         
        if(type == 0)
        {
            category = 11
            detailCategory = 2
            
            tempRecord = temp
            chooseCategoryBtn.setTitle("Repayment", for: .normal)
            let borrow = temp.borrow
            amount.text = String(borrow!.remain)
            personTF.text = String(borrow!.lender)
            descript.text = "Repay for " + borrow!.lender
        }
        else
        {
            category = 0
            detailCategory = 4
            tempRecord = temp
            chooseCategoryBtn.setTitle("Collecting debt", for: .normal)
            
            let lend = temp.lend
            amount.text = String(lend!.remain)
            personTF.text = String(lend!.borrower)
            descript.text = "Collect debt from " + lend!.borrower
        }
    }
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        return
    }
    
    func didSelectCategory( section: Int, row: Int) {
        if tempRecord != nil
        {
            tempRecord = nil
        }
        category = section
        detailCategory = row
        if(type == 0)
        {
            //catch exception lend
            chooseCategoryBtn.setTitle(categoryValues().expense[section][row], for: .normal)
        }
        else
        {
            //catch exception borrow
            chooseCategoryBtn.setTitle(categoryValues().income[section][row], for: .normal)

        }
    }
    
    func loadData()  {
        
        if type == 0
        {
            let temp = record?.expense
            amount.text = String(temp!.amount)
            descript.text = temp?.descript
            category = temp!.category
            detailCategory = temp!.detailCategory
            chooseCategoryBtn.setTitle(categoryValues().expense[category][detailCategory], for: .normal)
            personTF.text = temp?.payee
            locationTF.text = temp?.location
            eventTF.text = temp?.event
            srcAccount = temp?.srcAccount
            dateTime.date = temp!.date
            if srcAccount?.type == 1
            {
                chooseAccountBtn.setTitle(srcAccount?.cashAcc?.name, for: .normal)
            }
            else
            {
                chooseAccountBtn.setTitle(srcAccount?.bankingAcc?.name, for: .normal)
            }
            //get borrow record from expense if it has
            tempRecord = temp?.borrowRecord
            
    }
        else
        {
            let temp = record?.income
            amount.text = String(temp!.amount)
            descript.text = temp?.descript
            category = 0
            detailCategory = temp!.category
            chooseCategoryBtn.setTitle(categoryValues().income[category][detailCategory], for: .normal)
            personTF.text = temp?.payer
            locationTF.text = temp?.location
            eventTF.text = temp?.event
            srcAccount = temp?.srcAccount
            dateTime.date = temp!.date
            if srcAccount?.type == 1
            {
                chooseAccountBtn.setTitle(srcAccount?.cashAcc?.name, for: .normal)
            }
            else
            {
                chooseAccountBtn.setTitle(srcAccount?.bankingAcc?.name, for: .normal)
            }
            //get lend record if it has
            tempRecord = temp?.lendRecord
        }
        var tempStr : [String] = []
        userInfor = realm.objects(User.self)[0]
        tempStr.append(contentsOf: userInfor!.persons)
        personTF.filterStrings(tempStr)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        tempStr = []
        tempStr.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        tempStr = []
        tempStr.append(contentsOf: userInfor!.events)
        eventTF.theme.font = UIFont.systemFont(ofSize: 15)
        eventTF.maxNumberOfResults = 5
        eventTF.filterStrings(tempStr)
    }

    override func viewDidLoad() {
        type = record!.type
        
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseCategory(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.delegate = self
        dest.type = type
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func chooseAccount(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func saveRecord(_ sender: Any) {
        let _amount = Float(amount.text!)
        if  _amount == 0 || amount.text == ""
        {
            print("You have to enter amount!")
            return
        }
        if category == -1
        {
            print("You have to choose category of record!")
            return
        }
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            return
        }
        //check if data changed?
        //update record and notify
        try! realm.write{
        if type == 0
        {
            let temp = record?.expense
            if srcAccount != temp?.srcAccount || _amount != temp?.amount || detailCategory != temp?.detailCategory || category != temp?.category || dateTime.date != temp?.date || descript.text != temp?.descript || personTF.text != temp?.payee || locationTF.text != temp?.location || eventTF.text != temp?.event
            {
                //undo old-record
                temp?.undoTransaction()

                //get new data and do new transaction
                temp?.getData(_amount: _amount!, _type: type, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: "", _date: dateTime.date, _category: category, _detailCategory: detailCategory, _borrowRecord: tempRecord)
                print("Updated an expense!")
            }

         }
        else
        {
            let temp = record?.income
            if srcAccount != temp?.srcAccount || _amount != temp?.amount || detailCategory != temp?.category || descript.text != temp?.descript || personTF.text != temp?.payer || locationTF.text != temp?.location || eventTF.text != temp?.event
            {
                //undo old-transaction
                temp?.undoTransaction()

                //update new value and do transaction
                temp?.getData(_amount: _amount!, _type: type, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: "", _date: dateTime.date, _category: detailCategory, _lendRecord: tempRecord)
                print("Updated an income!")
            }
//            else
//            {
//
//            }

        }
            let userInfor = realm.objects(User.self)[0]
            var tempStr = locationTF.text ?? ""
            if tempStr.isEmpty == false && userInfor.locations.contains(tempStr) == false
            {
                userInfor.locations.append(tempStr)
            }
            tempStr = personTF.text ?? ""
            if tempStr.isEmpty == false && userInfor.persons.contains(tempStr) == false
            {
                userInfor.persons.append(tempStr)
            }
            tempStr = eventTF.text ?? ""
            if tempStr.isEmpty == false && userInfor.events.contains(tempStr) == false
            {
                userInfor.events.append(tempStr)
            }
        }
        historyDelegate?.editedRecord()
        print(realm.configuration.fileURL!)
        //pop vc
            self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func clickDelete(_ sender: Any) {
        try! realm.write{
            if record?.type == 0
            {
                record?.expense?.undoTransaction()
                realm.delete((record?.expense)!)
                print("Deleted a expense!")
            }
            else
            {
                record?.income?.undoTransaction()
                realm.delete((record?.income)!)
                print("Deleted a income!")

            }
            realm.delete(record!)

        }
        
        historyDelegate?.editedRecord()
        self.navigationController?.popViewController(animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        chooseTypeRecordBtn.setTitle(categoryValues().typeRecord[type],for: .normal)
        chooseTypeRecordBtn.clipsToBounds = true
        chooseTypeRecordBtn.layer.cornerRadius = chooseTypeRecordBtn.frame.width/8
        
        if(type == 0)
        {
            self.amount.textColor = UIColor.red
            personTF.placeholder = "Payee"
        }
        else
        {
            self.amount.textColor = UIColor.green
            personTF.placeholder = "Payee"
        }
    }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


