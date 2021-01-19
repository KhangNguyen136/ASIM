//
//  editExOrInVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/27/20.
//

import UIKit
import RealmSwift
import SearchTextField
import SCLAlertView
import FirebaseDatabase

class editExOrInVC: UITableViewController,selectCategoryDelegate,selectAccountDelegate {
    
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
            chooseAccountBtn.setTitle(srcAccount?.getname(), for: .normal)

            dateTime.date = temp!.date

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
            chooseAccountBtn.setTitle(srcAccount?.getname(), for: .normal)

            dateTime.date = temp!.date
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
            SCLAlertView().showError("Amount must be nonzero!", subTitle: "")
            return
        }
        if category == -1
        {
            print("You have to choose category of record!")
            SCLAlertView().showError("You have to choose category!", subTitle: "")
            return
        }
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            SCLAlertView().showError("You have to choose source account!", subTitle: "")
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
            record?.isChanged = true
            SCLAlertView().showSuccess("Transaction updated!", subTitle: descript.text ?? "")
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
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let msg = SCLAlertView(appearance: appearance)
        msg.addButton("Yes", action: { [self] in
            try! self.realm.write{
                if self.record?.isUploaded == true
            {
                //mark record to be deleted and delete it when sync
                self.record?.isDeleted = true
                if self.record?.type == 0
                {
                    self.record?.expense?.undoTransaction()
                    print("Mark an expense as deleted!")
                }
                else
                {
                    self.record?.income?.undoTransaction()
                    print("Deleted ab income as deleted!")
                }
            }
            else
            {
                if self.record?.type == 0
                {
                    self.record?.expense?.undoTransaction()
                    self.realm.delete((self.record?.expense)!)
                    print("Deleted a expense!")
                }
                else
                {
                    self.record?.income?.undoTransaction()
                    self.realm.delete((self.record?.income)!)
                    print("Deleted a income!")
                }
                //remove value in database
                self.realm.delete(self.record!)
            }
            }
            SCLAlertView().showSuccess("Transaction deleted!", subTitle: "")
            self.historyDelegate?.editedRecord()
            self.navigationController?.popViewController(animated: false)
        })
        msg.addButton("No", action: {
            msg.dismiss(animated: false, completion: nil)
        })
        msg.showWarning("Attention!", subTitle: "Deleted data cannot be recovered. Do you want to continue?")
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
