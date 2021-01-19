//
//  editLendOrBorrowVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/27/20.
//

import UIKit
import RealmSwift
import SearchTextField
import DatePicker
import SCLAlertView
import FirebaseDatabase

class editLendOrBorrowVC: UITableViewController,selectAccountDelegate {
    
    var historyDelegate: editRecordDelegate? = nil
    var record: polyRecord? = nil
    var type = -1
    let realm = try! Realm()
    var srcAccount: polyAccount? = nil
    
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var personTF: SearchTextField!
    @IBOutlet weak var locationTF: SearchTextField!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    @IBOutlet weak var selectTypeRecord: UIButton!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var chooseAccountBtn: UIButton!
    var reDate: Date? = nil
    @IBOutlet weak var reDateBtn: UIButton!
    @IBOutlet weak var dateTime: UIDatePicker!
    
    @IBOutlet weak var doneValue: UISwitch!
    @IBOutlet weak var doneTitle: UILabel!
    
    var userInfor: User? = nil
    
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        return
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
            descript.text = "Borrowed money from" + personTF.text!
        }
    }
    func loadData()  {
        type = record!.type
        
        chooseCategoryBtn.setTitle(categoryValues().typeRecord[type], for: .normal)
        
        selectTypeRecord.setTitle(categoryValues().typeRecord[type],for: .normal)
        selectTypeRecord.clipsToBounds = true
        selectTypeRecord.layer.cornerRadius = selectTypeRecord.frame.width/8

        chooseCategoryBtn.setTitle(categoryValues().other[0][type-2], for: .normal)
        if type == 2 {
            amount.textColor = UIColor.red
            personTF.placeholder = "Borrower"
            doneTitle.text = "Collected"
            reDateBtn.setTitle("Collecting date", for: .normal)
        }
        else
        {
            amount.textColor = UIColor.green
            personTF.placeholder = "Lender"
            doneTitle.text = "Repayed"
            reDateBtn.setTitle("Repayment date", for: .normal)
        }
        
        
        if type == 2
        {
            let temp = record?.lend
            amount.text = String(temp!.amount)
            descript.text = temp?.descript
            dateTime.date = temp!.date
            personTF.text = temp?.borrower
            locationTF.text = temp?.location
            doneValue.isOn = temp!.isCollected
            srcAccount = temp?.srcAccount
            chooseAccountBtn.setTitle(temp?.srcAccount?.getname(), for: .normal)
            if temp?.collectionDate != nil {
                reDate = temp?.collectionDate
                reDateBtn.setTitle(reDate?.string(), for: .normal)
            }
        }
        else
        {
            let temp = record?.borrow
            amount.text = String(temp!.amount)
            descript.text = temp?.descript
            dateTime.date = temp!.date
            personTF.text = temp?.lender
            locationTF.text = temp?.location
            doneValue.isOn = temp!.isRepayed
            srcAccount = temp?.srcAccount
            chooseAccountBtn.setTitle(temp?.srcAccount?.getname(), for: .normal)
            if temp?.repaymentDate != nil
            {
                reDate = temp?.repaymentDate
                reDateBtn.setTitle(reDate?.string(), for: .normal)
            }
        }
        let userInfor = realm.objects(User.self)[0]
        var tempStr: [String] = []
        tempStr.append(contentsOf: userInfor.persons)
        personTF.filterStrings(tempStr)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        tempStr = []
        tempStr.append(contentsOf: userInfor.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
    }
    override func viewWillAppear(_ animated: Bool) {
        
        loadData()
        super.viewWillAppear(true)
    }

    @IBAction func chooseAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func clickSave(_ sender: Any) {
        if Float(amount.text ?? "0") == 0 || amount.text == ""
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
        if personTF.text == ""
        {
            var tempStr = "borrower"
            if type == 3
            {
                tempStr = "lender"
            }
            print("You have to enter name of \(tempStr)!")
            SCLAlertView().showError("You have to enter \(tempStr)'s name!", subTitle: "")
            return
        }
        //update record
        try! realm.write{
        if type == 2
        {
            let temp = record?.lend
                //undo transaction
                temp?.undoTransaction()

            temp?.updateLend(_amount: (amount.text! as NSString).floatValue, _type: 2, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text!, _location: locationTF.text ?? "", _srcImg: "", _date: dateTime.date, _collectionDate:reDate)
                
                temp?.doTransaction()
            print("Updated an lend!")
            //problem change src account
         }
        else{
            let temp = record?.borrow
                temp?.undoTransaction()
                
                temp?.updateBorrow(_amount: (amount.text! as NSString).floatValue, _type: 3, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text!, _location: locationTF.text ?? "", _srcImg: "", _date: dateTime.date, _repaymentDate:reDate)
                temp?.doTransaction()
            print("Updated an borrow!")
            }
            record?.isChanged = true
            userInfor = realm.objects(User.self)[0]
            var tempStr = locationTF.text ?? ""
            if tempStr.isEmpty == false && userInfor!.locations.contains(tempStr) == false
            {
                userInfor!.locations.append(tempStr)
            }
            tempStr = personTF.text ?? ""
            if tempStr.isEmpty == false && userInfor!.persons.contains(tempStr) == false
            {
                userInfor!.persons.append(tempStr)
            }
            SCLAlertView().showSuccess("Transaction updated!", subTitle: record?.getDescript() ?? "")
        historyDelegate?.editedRecord()
        }
        print(realm.configuration.fileURL!)
        //pop vc
            self.navigationController?.popViewController(animated: true)
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
                self.record?.isDeleted = true
                if self.record?.type == 2
                {
                    self.record?.lend?.undoTransaction()
                    print("Mark a lend as deleted!")
                }
                else
                {
                    self.record?.borrow?.undoTransaction()
                    print("Mark a borrow as deleted!")
                }
            }
            else
            {
                if self.record?.type == 2
                {
                    self.record?.lend?.undoTransaction()
                    self.realm.delete((self.record?.lend)!)
                    print("Delete a lend!")

                }
                else
                {
                    self.record?.borrow?.undoTransaction()
                    self.realm.delete((self.record?.borrow)!)
                    print("Delete a borrow!")

                }
                self.realm.delete(self.record!)
            }
        //delete data in database
        }
            print("Deleted a lend or borrow")
            SCLAlertView().showSuccess("Transaction deleted!", subTitle: "")
            self.historyDelegate?.editedRecord()
            self.navigationController?.popViewController(animated: true)
        })
        msg.addButton("No", action: {
            msg.dismiss(animated: false, completion: nil)
        })
        msg.showWarning("Attention!", subTitle: "Deleted data cannot be recovered. Do you want to continue?")
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
