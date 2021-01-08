//
//  addLendOrBorrowVCNew.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import DropDown
import RealmSwift
import SearchTextField
import DatePicker
import SCLAlertView

class addLendOrBorrowVC: UITableViewController, selectCategoryDelegate,selectAccountDelegate {

    var type = 2
    var category = -1
    let realm = try! Realm()
    var userInfor: User? = nil
    var srcAccount: polyAccount? = nil

    @IBOutlet weak var amount: UITextField!

    @IBOutlet weak var personTF: SearchTextField!
    
    @IBOutlet weak var locationTF: SearchTextField!
    
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    @IBOutlet weak var selectTypeRecord: UIButton!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var chooseAccountBtn: UIButton!
    @IBOutlet weak var dateTime: UIDatePicker!
    
    @IBOutlet weak var reDateBtn: UIButton!
    var reDate: Date? = nil
    @IBOutlet weak var doneTitle: UILabel!
    
    @IBOutlet weak var doneValue: UISwitch!
    
    
    func didSelectRepayOrCollectDebt(_type: Int, temp: polyRecord) {
            let dest = self.storyboard?.instantiateViewController(identifier: "addExpenseOrIncomeVC") as! addExpenseOrIncomeVC
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.pushViewController(viewController: dest, animated: false)
        {
            dest.didSelectRepayOrCollectDebt(_type: _type, temp: temp)
        }
    }
    
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        return
    }
    
    func didSelectCategory(section: Int, row: Int) {
        if row == category
        {
            return
        }
        category = row
        if row == 0
        {
            amount.textColor = UIColor.red
            personTF.placeholder = "Borrower"
            descript.text = personTF.text! + " took out a loan"
            type = 2
            selectTypeRecord.setTitle("Lend", for: .normal)
            chooseCategoryBtn.setTitle(categoryValues().other[0][category], for: .normal)
        }
        if row == 1
        {
            type = 3
            amount.textColor = UIColor.green
            personTF.placeholder = "Lender"
            descript.text = "Borrowed money from " + personTF.text!
            selectTypeRecord.setTitle("Borrow", for: .normal)
            chooseCategoryBtn.setTitle(categoryValues().other[0][category], for: .normal)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        userInfor = realm.objects(User.self)[0]
        
        selectTypeRecord.semanticContentAttribute = .forceRightToLeft
        selectTypeRecord.setTitle(categoryValues().typeRecord[type],for: .normal)
        selectTypeRecord.clipsToBounds = true
        selectTypeRecord.layer.cornerRadius = selectTypeRecord.frame.width/8

        category = type - 2
        chooseCategoryBtn.setTitle(categoryValues().other[0][category], for: .normal)
        if type == 2 {
            amount.textColor = UIColor.red
            personTF.placeholder = "Borrower"
            reDateBtn.setTitle("Collecting date", for: .normal)
        }
        else
        {
            amount.textColor = UIColor.green
            personTF.placeholder = "Lender"
            reDateBtn.setTitle("Repayment date", for: .normal)

        }
        var tempStr: [String] = []
        tempStr.append(contentsOf: userInfor!.persons)
        personTF.filterStrings(tempStr)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        tempStr = []
        tempStr.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        super.viewWillAppear(true)
    }

    @IBAction func chooseReDate(_ sender: UIButton) {
        let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1990)!
                let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
                // Create picker object
                let datePicker = DatePicker()
                // Setup
                datePicker.setup(beginWith: Date(), min: minDate, max: maxDate) { (selected, date) in
                    if selected , let selectedDate = date {
                        self.reDate = selectedDate
                        sender.setTitle(selectedDate.string(), for: .normal)
                    } else {
                        print("Cancel choose redate")
                    }
                }
                // Display
                datePicker.show(in: self)
    }
    @IBAction func enterPerson(_ sender: Any) {
        if personTF.text == ""
        {
            return
        }
        if type == 2
        {
            descript.text = personTF.text! + " took out a loan"
        }
        else
        {
            descript.text = "Borrowed money from " + personTF.text!
        }
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
    @IBAction func chooseTypeRecord(_ sender: UIButton) {
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
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }

                    let dest = self?.storyboard?.instantiateViewController(identifier: "addExpenseOrIncomeVC") as! addExpenseOrIncomeVC

                    _ = viewcontrollers.popLast()
                    viewcontrollers.append(dest)
                    dest.type = index
                    self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
                
                case 2,3:
                    self!.type = index
                    if index == 2
                    {
                        self!.amount.textColor = UIColor.red
                        self!.personTF.placeholder = "Borrower"

                        
                        self!.selectTypeRecord.setTitle("Lend", for: .normal)
                        self!.chooseCategoryBtn.setTitle("Lend", for: .normal)
                        self?.descript.text = ""
                    }
                    if index == 3
                    {
                        
                        self!.amount.textColor = UIColor.green
                        self!.personTF.placeholder = "Lender"

                        self!.selectTypeRecord.setTitle("Borrow", for: .normal)
                        self!.chooseCategoryBtn.setTitle("Borrow", for: .normal)
                        self?.descript.text = ""
                    }
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
//    override var shouldAutorotate: Bool{
//        get{
//            return false
//        }
//    }
    override func viewDidLoad() {
        selectTypeRecord.semanticContentAttribute = .forceRightToLeft
        userInfor = realm.objects(User.self)[0]
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func clickSave(_ sender: Any) {
        
        let _amount = Float(amount.text ?? "0")
        if _amount == 0 || amount.text == ""
        {
            print("You have to enter amount!")
            SCLAlertView().showError("Amount must be nonzero!", subTitle: "")
            return
        }
        
        if category == -1
        {
            print("You have to choose category of record!")
            SCLAlertView().showError("You have to choose category!", subTitle: "")
            return
        }
        
        if personTF.text?.isEmpty == true
        {
            print("You have to choose person")
            var tempStr = "borrower"
            if type == 3
            {
                tempStr = "lender"
            }
            SCLAlertView().showError("You have to enter \(tempStr)'s name!", subTitle: "")
            return
        }
        
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            SCLAlertView().showError("You have to choose source account!", subTitle: "")
            return
        }
        try! realm.write{
        if type == 2 {
            let temp = Lend()
                //get data and do transaction
                temp.getData(_amount: _amount!, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _person: personTF.text!, _location: locationTF.text ?? "" , _srcImg: "srcImage",_date: dateTime.date, _collectionDate: reDate,_isCollected: doneValue.isOn)
            let temp1 = polyRecord()
                temp1.lend = temp
                temp1.type = 2
//                temp1.isChanged = true
                realm.add(temp1)
                userInfor?.records.append(temp1)
                }
        else
        {
            let temp = Borrow()
            temp.getData(_amount: _amount!, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _person: personTF.text!, _location: locationTF.text ?? "", _srcImg: "srcImage",_date: dateTime.date, _repaymentDate: reDate, _isRepayed: doneValue.isOn)
                
            let temp1 = polyRecord()
                temp1.borrow = temp
                temp1.type = 3
//                temp1.isChanged = true

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
        }
        print(realm.configuration.fileURL!)
        SCLAlertView().showSuccess("Transaction added!", subTitle: descript.text ?? "")
        //reset vc
        guard var viewcontrollers = self.navigationController?.viewControllers else { return }
        if(viewcontrollers.count == 1)
        {
        let dest = self.storyboard?.instantiateViewController(identifier: "addLendOrBorrowVC") as! addLendOrBorrowVC

        _ = viewcontrollers.popLast()
        viewcontrollers.append(dest)
        dest.type = type
        self.navigationController?.setViewControllers(viewcontrollers, animated: false)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

