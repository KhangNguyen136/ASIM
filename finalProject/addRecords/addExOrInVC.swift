//
//  addRecordVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import DropDown
import RealmSwift
import SearchTextField

protocol selectCategoryDelegate: class {
    func didSelectCategory(section: Int, row: Int)
    func didSelectRepayOrCollectDebt(_type: Int, temp: polyRecord)
}
protocol selectAccountDelegate: class {
    func didSelectAccount(temp: polyAccount, name: String)
}

protocol selectLendOrBorrowDelegate: class {
    func didSelectLendOrBorrow(_type: Int, temp: polyRecord)
}

class addExOrInVC: UIViewController,selectCategoryDelegate,selectAccountDelegate {
    
    var type = 0
    var category = -1
    var detailCategory = -1
    
    let realm = try! Realm()
    var tempRecord : polyRecord? = nil
    var userInfor: User? = nil
    
    var srcAccount: polyAccount? = nil
    @IBOutlet weak var chooseTypeRecordBtn: UIButton!
    
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    
    @IBOutlet weak var dateTime: UIDatePicker!
    
    @IBOutlet weak var unit: UILabel!
    
    @IBOutlet weak var amount: UITextField!
    
    @IBOutlet weak var chooseAccountBtn: UIButton!
    
    @IBOutlet weak var personTF: SearchTextField!
    
    @IBOutlet weak var locationTF: SearchTextField!
    
    @IBOutlet weak var eventTF: SearchTextField!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var descript: UITextField!
    let dropDown = DropDown()
    
    func loadData() {
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
            personTF.placeholder = "Payer"
        }
        userInfor = realm.objects(User.self)[0]
        
        var temp :[String] = []
        temp.append(contentsOf: userInfor!.persons)
        personTF.filterStrings(temp)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        temp = []
        temp.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(temp)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        temp = []
        temp.append(contentsOf: userInfor!.events)
        eventTF.filterStrings(temp)
        eventTF.theme.font = UIFont.systemFont(ofSize: 15)
        eventTF.maxNumberOfResults = 5
    }
    func resetData() {
        amount.text = ""
        descript.text = ""
        personTF.text = ""
        chooseCategoryBtn.setTitle("Select category", for: .normal)
        locationTF.text = ""
        eventTF.text = ""
    }
    override func viewDidLoad() {
        chooseTypeRecordBtn.semanticContentAttribute = .forceRightToLeft
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        return
    }
    func didSelectRepayOrCollectDebt(_type: Int,temp: polyRecord) {
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
    func didSelectCategory(section: Int, row: Int) {
        tempRecord = nil
        
        category = section
        detailCategory = row
        if(type == 0)
        {
            chooseCategoryBtn.setTitle(categoryValues().expense[section][row], for: .normal)
        }
        else
        {
            chooseCategoryBtn.setTitle(categoryValues().income[section][row], for: .normal)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {context in
            print("Rotating screen!")
        }, completion: {context in
            print("Rotated screen!")
        })
    }
    
    @IBAction func chooseCategory(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.delegate = self
        dest.type = type
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func chooseAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func saveRecord(_ sender: Any) {
        if Float(amount.text ?? "0") == 0 || amount.text == ""
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
            print("You have to choose source account")
            return
        }
        //create
        let tempAmount = (amount.text! as NSString).floatValue
        try! realm.write{
        if type == 0
        {
            //create and do transaction
            let temp = Expense()
            temp.getData(_amount: tempAmount, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: "srcImage",_date: dateTime.date, _category: category, _detailCategory: detailCategory, _borrowRecord: tempRecord)
            let temp1 = polyRecord()
                temp1.expense = temp
                temp1.type = 0
            realm.add(temp1)
            userInfor?.records.append(temp1)
        }
        else
        {
                let temp = Income()
                temp.getData(_amount: tempAmount, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: "srcImage", _date: dateTime.date, _category: detailCategory,_lendRecord: tempRecord)
                let temp1 = polyRecord()
                    temp1.income = temp
                    temp1.type = 1
                realm.add(temp1)
                userInfor?.records.append(temp1)
        }
            var tempStr = locationTF.text ?? ""
            if tempStr.isEmpty == false && userInfor?.locations.contains(tempStr) == false
            {
            userInfor?.locations.append(tempStr)
            }
            tempStr = personTF.text ?? ""
            if tempStr.isEmpty == false && userInfor?.persons.contains(tempStr) == false
            {
                userInfor?.persons.append(tempStr)
            }
            tempStr = eventTF.text ?? ""
            if tempStr.isEmpty == false && userInfor?.events.contains(tempStr) == false
            {
                userInfor?.events.append(tempStr)
            }
        }
        print(realm.configuration.fileURL!)
        
        //reset vc
        guard var viewcontrollers = self.navigationController?.viewControllers else { return }
        if viewcontrollers.count == 1
        {
        let dest = self.storyboard?.instantiateViewController(identifier: "addExOrInVC") as! addExOrInVC

        _ = viewcontrollers.popLast()
        viewcontrollers.append(dest)
        dest.type = type
        self.navigationController?.setViewControllers(viewcontrollers, animated: false)
        }
        else
        {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func chooseType(_ sender: UIButton) {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = sender // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = categoryValues().typeRecord

        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)

        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? typeRecord else { return }

           // Setup your custom UI components
           cell.logo.image = UIImage(named: "home")
        }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            if index != self?.type
            {
                switch index {
                case 0,1:
                    self!.category = -1
                    self!.detailCategory = -1
                    self?.chooseCategoryBtn.setTitle("Select category", for: .normal)
                    self?.descript.text = ""
                    self!.type = index
                    if index == 0
                    {
                        self?.amount.textColor = UIColor.red
                        self?.personTF.placeholder = "Payee"
                    }
                    else
                    {
                        self?.amount.textColor = UIColor.green
                        self?.personTF.placeholder = "Payer"
                    }
                case 2,3:
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }
                    let dest = self?.storyboard?.instantiateViewController(identifier: "addLendOrBorrowVC") as! addLendOrBorrowVC

                    _ = viewcontrollers.popLast()
                    viewcontrollers.append(dest)
                    dest.type = index
                    self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
                
                case 4:
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }

                    let dest = self?.storyboard?.instantiateViewController(identifier: "addTransferVc") as! addTransferVc

                    _ = viewcontrollers.popLast()
                    viewcontrollers.append(dest)
//                    dest.type = index
                    self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
                case 5:
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }

                    let dest = self?.storyboard?.instantiateViewController(identifier: "addAdjustmentVC") as! addAdjustmentVC

                    _ = viewcontrollers.popLast()
                    viewcontrollers.append(dest)
//                    dest.type = index
                    self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
                default:
                    return
                }
            }
            
        }
        dropDown.show()
        }
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        super.viewWillAppear(false)
    }
    }
    
