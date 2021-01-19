//
//  addTransferVCNew.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import DropDown
import RealmSwift
import SearchTextField
import SCLAlertView

class addTransferVc: UITableViewController ,selectAccountDelegate,selectDestinationAccountDelegate {
    func didSelectDestAccount(temp: polyAccount, name: String) {
        chooseDestAccountBtn.setTitle(name , for: .normal)
        destAccount = temp
        descript.text = "transfer to \(name)"
    }
    let realm = try! Realm()
    var userInfor: User? = nil
    var srcAccount: polyAccount? = nil
    var destAccount: polyAccount? = nil

    var type = 4
    
    @IBOutlet weak var selectTypeRecord: UIButton!
    @IBOutlet weak var chooseSourceAccountBtn: UIButton!
    @IBOutlet weak var chooseDestAccountBtn: UIButton!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var locationTF: SearchTextField!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var fee: UITextField!
    
    override func viewDidLoad() {
        userInfor = realm.objects(User.self)[0]
        var tempStr: [String] = []
        tempStr.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        
        selectTypeRecord.semanticContentAttribute = .forceRightToLeft
        selectTypeRecord.clipsToBounds = true
        selectTypeRecord.layer.cornerRadius = selectTypeRecord.frame.width/8
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        super.viewDidLoad()
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func chooseSourceAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseSourceAccountBtn.setTitle(name, for: .normal)
        return
    }
    
    @IBAction func chooseDestAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate1 = self
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
    @IBAction func clickSave(_ sender: Any) {
        if (amount.text! as NSString).floatValue == 0
        {
            print("You have to enter amount!")
            SCLAlertView().showError("Amount must be nonzero!", subTitle: "")
            return
        }
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            SCLAlertView().showError("You have to choose source account!", subTitle: "")
            return
        }
        if destAccount == nil
        {
            SCLAlertView().showError("You have to choose destination account!", subTitle: "")
            return
        }
        //create
        let transFree = (fee.text! as NSString).floatValue
        let temp = Transfer()
        var temp2 :polyRecord? = nil
        try! realm.write{
        if (transFree != 0)
        {
            let tempTransferFee = Expense()
            let tempStr = "Fee of transfer from \(srcAccount?.getname() ?? "srcAccount") to \(destAccount?.getname() ?? "destAccount")"
            //get data and do transaction
            tempTransferFee.getData(_amount: transFree, _type: 0, _descript: tempStr, _srcAccount: srcAccount!, _person: "", _location: locationTF.text ?? "", _event: "", _srcImg: "srcImage", _date: dateTime.date, _category: categoryValues().expense.count - 1, _detailCategory: 1, _borrowRecord: nil)
            
            temp2 = polyRecord()
            temp2!.expense = tempTransferFee
            temp2!.type = 0
//            temp2!.isChanged = true

            realm.add(temp2!)
            userInfor?.records.append(temp2!)
        }
        // get data and do transaction
        temp.getData(_amount: (amount.text! as NSString).floatValue, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _location: locationTF.text ?? "", _srcImg: "srcImage",_date: dateTime.date,_destAccount: destAccount!,_transferFee: temp2 )
        
        let temp1 = polyRecord()
            temp1.transfer = temp
            temp1.type = 4
//            temp1.isChanged = true

            realm.add(temp1)
            userInfor?.records.append(temp1)
            
            let tempStr = locationTF.text ?? ""
            if tempStr.isEmpty == false && userInfor?.locations.contains(tempStr) == false
            {
            userInfor?.locations.append(tempStr)
            }
        }
        SCLAlertView().showSuccess("Transaction added!", subTitle: descript.text ?? "")
        
        //reset view
        guard var viewcontrollers = self.navigationController?.viewControllers else { return }
        if viewcontrollers.count == 1
        {
        let dest = self.storyboard?.instantiateViewController(identifier: "addTransferVc") as! addTransferVc

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
        return 9
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
