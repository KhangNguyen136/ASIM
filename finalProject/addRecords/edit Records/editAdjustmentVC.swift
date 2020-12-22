//
//  addAdjustmentVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/28/20.
//

import UIKit
import RealmSwift
import SearchTextField

class editAdjustmentVC: UIViewController,selectAccountDelegate,selectCategoryDelegate {
    func didSelectRepayOrCollectDebt(_type: Int, temp: polyRecord) {
        tempRecord = temp
        if(_type == 0)
        {
            category = 11
            detailCategory = 2
            
            tempRecord = temp
            chooseCategoryBtn.setTitle("Repayment", for: .normal)
            let borrow = temp.borrow
            descript.text = "Repay for " + borrow!.lender
        }
        else
        {
            category = 0
            detailCategory = 4
            tempRecord = temp
            chooseCategoryBtn.setTitle("Collecting debt", for: .normal)
            let lend = temp.lend
            descript.text = "Collect debt from " + lend!.borrower
        }
    }

    let realm = try! Realm()
    var historyDelegate : editRecordDelegate? = nil
    var record: polyRecord? = nil
    var tempRecord: polyRecord? = nil
    var srcAccount: polyAccount? = nil

    var _acttualBalance: Float = 0
    var _currentBalance: Float = 0
    var _different: Float = 0
    var type = 5
    var subtype = -1
    var category = -1
    var detailCategory = -1
    
    @IBOutlet weak var typeReccord: UIButton!
    @IBOutlet weak var chooseAccountBtn: UIButton!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var acctualBalance: UITextField!
    @IBOutlet weak var currentBalance: UILabel!
    @IBOutlet weak var different: UILabel!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var locationTF: SearchTextField!
    
    func loadData()  {
        if record == nil
        {
            return
        }
        let temp = record?.adjustment
        acctualBalance.text = String(temp!.amount)
        locationTF.text = temp?.location ?? ""
        dateTime.date = temp?.date ?? Date()
        descript.text = temp?.descript
        srcAccount = temp?.srcAccount
        subtype = temp!.subType
        category = temp!.category
        detailCategory = temp!.detailCategory
        tempRecord = temp?.tempRecord
        
        _acttualBalance = (record?.adjustment!.amount)!
        acctualBalance.text = String(_acttualBalance)
        
        _currentBalance = (srcAccount?.getBalance())!
        currentBalance.text = String(_currentBalance) + "$"
        
        _different = temp!.different
        different.text = String(_different) + "$"
        if subtype == 0
        {
            different.textColor = UIColor.red
        }
        else
        {
            different.textColor = UIColor.green
        }
        let userInfor = realm.objects(User.self)[0]
        var tempStr : [String] = []
        tempStr.append(contentsOf: userInfor.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
    }
    override func viewDidLoad() {
        typeReccord.clipsToBounds = true
        typeReccord.layer.cornerRadius = typeReccord.frame.width/8
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func didSelectCategory( section: Int, row: Int) {
        if section == category && row == detailCategory
        {
        return
        }
        category = section
        detailCategory = row

        if subtype == 0
        {
            chooseCategoryBtn.setTitle(categoryValues().expense[category][detailCategory], for: .normal)
        }
        else
        {
            chooseCategoryBtn.setTitle(categoryValues().income[0][detailCategory], for: .normal)
        }
    }
    
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        _currentBalance = (srcAccount?.getBalance())!
        currentBalance.text = String(_currentBalance) + "$"
        
        if _currentBalance == _acttualBalance
        {
        _different = 0
        different.text = "0 $"
        subtype = 1
        }
        else if _currentBalance < _acttualBalance
            {
            if subtype == 0
            {
                category = -1
                detailCategory = -1
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                subtype = 1
            }
            _different = _acttualBalance - _currentBalance
            different.text = String(_different) + "$"
            different.textColor = UIColor.green
        }
        else{
            if subtype == 1
            {
                category = -1
                detailCategory = -1
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                subtype = 0
            }
            _different = _currentBalance - _acttualBalance
            different.text = String(_different) + "$"
            different.textColor = UIColor.red
        }
    }
    @IBAction func chooseAccount(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func chooseCategory(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.delegate = self
        dest.type = self.subtype
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func changedAcctualBalance(_ sender: Any) {
        _acttualBalance = (acctualBalance.text! as NSString).floatValue
        if _currentBalance == _acttualBalance
        {
        _different = 0
        different.text = "0 $"
        subtype = 1
        }
        else if _currentBalance < _acttualBalance
            {
            if subtype == 0
            {
                category = -1
                detailCategory = -1
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                subtype = 1
            }
            _different = _acttualBalance - _currentBalance
            different.text = String(_different)
            different.textColor = UIColor.green
        }
        else{
            if subtype == 1
            {
                category = -1
                detailCategory = -1
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                subtype = 0
            }
            _different = _currentBalance - _acttualBalance
            different.text = String(_different)
            different.textColor = UIColor.red
        }
    }
    
    @IBAction func clickSaveRecord(_ sender: Any) {
        if _different == 0
        {
            print("You have to enter changed amount of source account!")
            return
        }
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            return
        }
        if category == -1 || detailCategory == -1
        {
            print("You have to choose category for this action!")
            return
        }
        
        try! realm.write{
            record?.adjustment?.undoTransaction()
            
            record?.adjustment?.getData(_amount: _acttualBalance, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _location: locationTF.text ?? "", _srcImg: "srcImage",_date: dateTime.date,_subType: subtype, _different: _different,_category: category,_detailCategory: detailCategory,_tempRecord: tempRecord)
            let userInfor = realm.objects(User.self)[0]
            let tempStr = locationTF.text ?? ""
            if tempStr.isEmpty == false && userInfor.locations.contains(tempStr) == false
            {
                userInfor.locations.append(tempStr)
            }
        }
        print("Update a adjustment")
       
        historyDelegate?.editedRecord()
        //pop after save
            self.navigationController?.popViewController(animated: false)
        
    }
    
    

    @IBAction func clickDelte(_ sender: Any) {
        try! realm.write{
        
            if tempRecord != nil
            {
                if subtype == 0
                {
                    tempRecord?.borrow?.undoRepay(_amount: (record?.adjustment!.different)!)
                }
                else
                {
                    tempRecord?.lend?.undoCollect(_amount: (record?.adjustment!.different)!)
                }
            }
            record?.adjustment?.undoTransaction()
        realm.delete((record?.adjustment)!)
        realm.delete(record!)
        }
        
        print("Deleted a adjustment")
        historyDelegate?.editedRecord()
        self.navigationController?.popViewController(animated: false)
    }
}
