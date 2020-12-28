//
//  addAdjustmentVCn.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import DropDown
import RealmSwift
import SearchTextField

class addAdjustmentVC: UITableViewController,selectAccountDelegate,selectCategoryDelegate {
    
    let realm = try! Realm()
    var userInfor: User? = nil
    var srcAccount: polyAccount? = nil
    var tempRecord: polyRecord? = nil
    var _acttualBalance: Float = 0
    var _currentBalance: Float = 0
    var _different: Float = 0

    var type = 5
    var subtype = -1
    var category = -1
    var detailCategory = -1
    
    @IBOutlet weak var selectTypeRecord: UIButton!
    @IBOutlet weak var chooseAccountBtn: UIButton!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var locationTF: SearchTextField!
    @IBOutlet weak var acctualBalance: UITextField!
    @IBOutlet weak var currentBalance: UILabel!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var different: UILabel!
    @IBOutlet weak var subTypeTitle: UILabel!
    
    @IBOutlet weak var personTF: SearchTextField!
    
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
            personTF.text = borrow?.lender
        }
        else
        {
            category = 0
            detailCategory = 4
            
            tempRecord = temp
            chooseCategoryBtn.setTitle("Collecting debt", for: .normal)
            
            let lend = temp.lend
            descript.text = "Collect debt from " + lend!.borrower
            personTF.text = lend?.borrower
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
        changedAcctualBalance(UIButton())
    }

    override func viewDidLoad() {
        userInfor = realm.objects(User.self)[0]
        var tempStr : [String] = []
        tempStr.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        
        tempStr = []
        tempStr.append(contentsOf: userInfor!.persons)
        personTF.filterStrings(tempStr)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        
        selectTypeRecord.semanticContentAttribute = .forceRightToLeft
        selectTypeRecord.clipsToBounds = true
        selectTypeRecord.layer.cornerRadius = selectTypeRecord.frame.width/8
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func chooseAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    @IBAction func chooseCategory(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.getData(section: self.category, row: self.detailCategory,_type: self.subtype,_delegate: self)
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
                default:
                    return
                }
            }
            
        }
        dropDown.show()
    }
    @IBAction func changedAcctualBalance(_ sender: Any) {
        _acttualBalance = (acctualBalance.text! as NSString).floatValue
        if _currentBalance == _acttualBalance
        {
        _different = 0
        different.text = "0 $"
            subTypeTitle.text = "Difference"
            different.textColor = UIColor.black
        subtype = -1
        }
        else if _currentBalance < _acttualBalance
            {
            if subtype != 1
            {
                category = -1
                detailCategory = -1
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                personTF.placeholder = "Payee"
                descript.text = ""
                subtype = 1
            }
            _different = _acttualBalance - _currentBalance
            different.text = String(_different)
            different.textColor = UIColor.green
            subTypeTitle.text = "Income"
        }
        else{
            if subtype != 0
            {
                category = -1
                detailCategory = -1
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                personTF.placeholder = "Payer"
                descript.text = ""
                subtype = 0
            }
            _different = _currentBalance - _acttualBalance
            different.text = String(_different)
            different.textColor = UIColor.red
            subTypeTitle.text = "Expense"
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
        //create
        let temp = Adjustment()
        try! realm.write{
            temp.getData(_amount: _acttualBalance, _type: type, _descript: descript.text ?? "", _srcAccount: srcAccount!, _location: locationTF.text ?? "", _srcImg: "srcImage",_date: dateTime.date,_subType: subtype, _different: _different,_category: category,_detailCategory: detailCategory,_tempRecord: tempRecord,_person: personTF.text ?? "")
        let temp1 = polyRecord()
            temp1.adjustment = temp
            temp1.type = 5
        
        realm.add(temp1)
        userInfor?.records.append(temp1)
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
        
        //reset view
        guard var viewcontrollers = self.navigationController?.viewControllers else { return }
        if viewcontrollers.count == 1
        {
        let dest = self.storyboard?.instantiateViewController(identifier: "addAdjustmentVC") as! addAdjustmentVC

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
