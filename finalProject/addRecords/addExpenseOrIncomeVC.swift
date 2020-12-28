//
//  addExpenseOrIncomeVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import SearchTextField
import DropDown
import RealmSwift

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

class addExpenseOrIncomeVC: UITableViewController,selectCategoryDelegate,selectAccountDelegate {
    
    var type = 0
    var category = -1
    var detailCategory = -1
    
    let realm = try! Realm()
    var tempRecord : polyRecord? = nil
    var userInfor: User? = nil
    
    var srcAccount: polyAccount? = nil
    
    @IBOutlet weak var amount: UITextField!
    
    @IBOutlet weak var chooseTypeRecordBtn: UIButton!
    
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    
    @IBOutlet weak var dateTime: UIDatePicker!
    
    @IBOutlet weak var unit: UILabel!
        
    @IBOutlet weak var chooseAccountBtn: UIButton!
    
    @IBOutlet weak var personTF: SearchTextField!
    
    @IBOutlet weak var locationTF: SearchTextField!
    
    @IBOutlet weak var eventTF: SearchTextField!
    
    @IBOutlet weak var descript: UITextField!
    
    @IBOutlet weak var chooseImageBtn: UIButton!
    
    var imagePicker = UIImagePickerController()

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
        if tempRecord != nil
        {
            tempRecord = nil
            descript.text = ""
            personTF.text = ""
        }
        if section == category && row == detailCategory
        {
        return
        }
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
    @IBAction func clickSave(_ sender: Any) {
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
        let dest = self.storyboard?.instantiateViewController(identifier: "addExpenseOrIncomeVC") as! addExpenseOrIncomeVC
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
    @IBAction func chooseCategory(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.getData(section: self.category, row: self.detailCategory,_type: self.type,_delegate: self)
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    @IBAction func chooseAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
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
    override func viewDidLoad() {
        loadData()
        chooseTypeRecordBtn.semanticContentAttribute = .forceRightToLeft

        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
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
