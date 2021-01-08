//
//  dataVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import RealmSwift
import FirebaseDatabase
import ProgressHUD
import SCLAlertView

struct accountTempClass: Codable{
    let type: Int
    let id : String
    let name: String
    let balance: Float
    let currency: String
    let active: Bool
    let bankName: String
}

class yourDataVC: UITableViewController {

    let realm = try! Realm()
    var userInfor: User? = nil
    var ref = Database.database().reference()
    let formatter = DateFormatter()
    typealias recordArrayClosure = ([polyRecord]?) -> Void
    typealias accountArrayClosure = ([polyAccount]?) -> Void

    func getUser() -> Bool {
        let temp = realm.objects(User.self)
        if temp.isEmpty
        {
            return false
        }
        else
        {
            userInfor = temp[0]
            if userInfor?.username == ""{
                return false
            }
            return true
        }
    }
    typealias connectionStt = (Bool) -> Void
    func checkConnection(comletionHanlder: @escaping connectionStt)
    {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
            comletionHanlder(true)
            return
          } else {
            comletionHanlder(false)
            return
          }
        })
    }
    @IBAction func clickSyncData(_ sender: Any) {
        print("Sync data")

        checkConnection{ [self] connectionStt in
            if connectionStt == false
            {
                SCLAlertView().showError("No connection", subTitle: "Check your internet connection and try again!")
                return
            }
            else
            {
                syncData()
            }
        }
        
    }
    func syncData(){
        ProgressHUD.show("Sync your data...")
        let accountRef = ref.child("users").child(userInfor!.username).child("accounts")
        print("Sync accounts")
//        accountRef.removeValue()
        for i in userInfor!.accounts
        {
            if i.isDeleted == true
            {
                accountRef.child(String(i.id)).removeValue()
                try! realm.write
                    {
                    switch i.type
                    {
                    case 0:
                        realm.delete(i.cashAcc!)
                    case 1:
                        realm.delete(i.bankingAcc!)
                    default:
                        realm.delete(i.savingAcc!)
                    }
                    realm.delete(i)
                }
                continue
            }
            if i.isChanged == false{
                continue
            }

            let tempRef = accountRef.child(String(i.id))
            
            switch i.type
            {
            case 0:
                let tempAcc = i.cashAcc
                tempRef.child("type").setValue(0)
                tempRef.child("id").setValue(tempAcc?.id)
                tempRef.child("name").setValue(tempAcc?.name)
                tempRef.child("balance").setValue(tempAcc?.balance)
                tempRef.child("currency").setValue(tempAcc?.currency)
                tempRef.child("active").setValue(tempAcc?.active)
                tempRef.child("descrip").setValue(tempAcc?.descrip)
            case 1:
                let tempAcc = i.bankingAcc
                tempRef.child("type").setValue(1)
                tempRef.child("id").setValue(tempAcc?.id)
                tempRef.child("name").setValue(tempAcc?.name)
                tempRef.child("balance").setValue(tempAcc?.balance)
                tempRef.child("currency").setValue(tempAcc?.currency)
                tempRef.child("active").setValue(tempAcc?.active)
                tempRef.child("descrip").setValue(tempAcc?.descrip)
                tempRef.child("bankName").setValue(tempAcc?.bankName)
            default:
                let tempAcc = i.savingAcc
                tempRef.child("type").setValue(2)
                tempRef.child("id").setValue(tempAcc?.id)
                tempRef.child("name").setValue(tempAcc?.name)
                tempRef.child("ammount").setValue(tempAcc?.ammount)
                tempRef.child("srcAccount").setValue(tempAcc?.srcAccount?.id)
                tempRef.child("destAccount").setValue(tempAcc?.destAccount?.id)


            }
            try! realm.write
                {
                i.isUploaded = true
                i.isChanged = false
            }
        }
        //upload records
        var parentRecord: [polyRecord] = []
        let recordRef = ref.child("users").child(userInfor!.username).child("records")
        print("sync records")
        for i in userInfor!.records
        {
            if i.isDeleted == true
            {
                recordRef.child(i.id).removeValue()
                try! realm.write{
                switch i.type {
                case 0:
                    realm.delete(i.expense!)
                case 1:
                    realm.delete(i.income!)
                case 2:
                    realm.delete(i.lend!)
                case 3:
                    realm.delete(i.borrow!)
                case 4:
                    realm.delete(i.transfer!)
                default:
                    realm.delete(i.adjustment!)
                }
                    realm.delete(i)
                }
                continue
            }
            //check if it changed
            if i.isChanged == false
            {
                continue
            }
            let tempRef: DatabaseReference
            if i.id == ""
            {
            tempRef = recordRef.childByAutoId()
            try! realm.write
                {
                i.id = tempRef.key!
                }
            }
            else
            {
                tempRef = recordRef.child(i.id)
            }
                        
            switch i.type {
            case 0:
                let tempRecord = i.expense
                tempRef.child("type").setValue(tempRecord?.type)
                tempRef.child("amount").setValue(tempRecord?.amount)
                tempRef.child("srcAccount").setValue(tempRecord?.srcAccount?.id)
                tempRef.child("category").setValue(tempRecord?.category)
                tempRef.child("detailCategory").setValue(tempRecord?.detailCategory)
                tempRef.child("payee").setValue(tempRecord?.payee)
                tempRef.child("event").setValue(tempRecord?.event)
                tempRef.child("location").setValue(tempRecord?.location)
                tempRef.child("descript").setValue(tempRecord?.descript)
                tempRef.child("date").setValue(tempRecord?.date.timeIntervalSince1970)
                if tempRecord?.borrowRecord != nil
                {
                    if tempRecord?.borrowRecord?.id != ""
                    {
                    tempRef.child("borrowRecord").setValue(tempRecord?.borrowRecord?.id)
                    }
                    else
                    {
                        parentRecord.append(i)
                    }
                }
                else
                {
                    tempRef.child("borrowRecord").setValue("")
                }
                
            case 1:
                let tempRecord = i.income
                tempRef.child("type").setValue(tempRecord?.type)
                tempRef.child("amount").setValue(tempRecord?.amount)

                tempRef.child("id").setValue(tempRecord?.id)
                tempRef.child("srcAccount").setValue(tempRecord?.srcAccount?.id)
                tempRef.child("category").setValue(tempRecord?.category)
                tempRef.child("payer").setValue(tempRecord?.payer)
                tempRef.child("event").setValue(tempRecord?.event)
                tempRef.child("location").setValue(tempRecord?.location)
                tempRef.child("descript").setValue(tempRecord?.descript)
                tempRef.child("date").setValue(tempRecord?.date.timeIntervalSince1970)
                if tempRecord?.lendRecord != nil
                {
                    if tempRecord?.lendRecord?.id != ""
                    {
                    tempRef.child("lendRecord").setValue(tempRecord?.lendRecord?.id)
                    }
                    else
                    {
                        parentRecord.append(i)
                    }
                }
                else
                {
                    tempRef.child("lendRecord").setValue("")
                }
            case 2:
                let tempRecord = i.lend
                tempRef.child("type").setValue(tempRecord?.type)
                tempRef.child("amount").setValue(tempRecord?.amount)
                tempRef.child("srcAccount").setValue(tempRecord?.srcAccount?.id)
                tempRef.child("borrower").setValue(tempRecord?.borrower)
                tempRef.child("remain").setValue(tempRecord?.remain)
                tempRef.child("over").setValue(tempRecord?.over)
                
                tempRef.child("location").setValue(tempRecord?.location)
                tempRef.child("descript").setValue(tempRecord?.descript)
                tempRef.child("date").setValue(tempRecord?.date.timeIntervalSince1970)
                tempRef.child("collectionDate").setValue(tempRecord?.collectionDate?.timeIntervalSince1970)
                tempRef.child("isCollected").setValue(tempRecord?.isCollected)
                
            case 3:
                let tempRecord = i.borrow
                tempRef.child("type").setValue(tempRecord?.type)
                tempRef.child("amount").setValue(tempRecord?.amount)
                tempRef.child("srcAccount").setValue(tempRecord?.srcAccount?.id)
                tempRef.child("lender").setValue(tempRecord?.lender)
                tempRef.child("remain").setValue(tempRecord?.remain)
                tempRef.child("over").setValue(tempRecord?.over)

                tempRef.child("location").setValue(tempRecord?.location)
                tempRef.child("descript").setValue(tempRecord?.descript)
                tempRef.child("date").setValue(tempRecord?.date.timeIntervalSince1970)
                tempRef.child("repaymentDate").setValue(tempRecord?.repaymentDate?.timeIntervalSince1970)
                tempRef.child("isRepayed").setValue(tempRecord?.isRepayed)
            case 4:
                let tempRecord = i.transfer
                tempRef.child("type").setValue(tempRecord?.type)
                tempRef.child("amount").setValue(tempRecord?.amount)

                tempRef.child("srcAccount").setValue(tempRecord?.srcAccount?.id)
                tempRef.child("destinationAccount").setValue(tempRecord?.destinationAccount?.id)
                tempRef.child("location").setValue(tempRecord?.location)
                tempRef.child("descript").setValue(tempRecord?.descript)
                tempRef.child("date").setValue(tempRecord?.date.timeIntervalSince1970)
                
                if tempRecord?.transferFee != nil
                {
                    if tempRecord?.transferFee?.id != ""
                    {
                    tempRef.child("transferFeeID").setValue(tempRecord?.transferFee?.id)
                    }
                    else
                    {
                        parentRecord.append(i)
                    }
                }
                else
                {
                    tempRef.child("transferFeeID").setValue("")
                }
            default:
                let tempRecord = i.adjustment
                tempRef.child("type").setValue(tempRecord?.type)
                tempRef.child("amount").setValue(tempRecord?.amount)
                tempRef.child("subType").setValue(tempRecord?.subType)
                tempRef.child("category").setValue(tempRecord?.category)
                tempRef.child("detailCategory").setValue(tempRecord?.detailCategory)
                tempRef.child("different").setValue(tempRecord?.different)
                tempRef.child("srcAccount").setValue(tempRecord?.srcAccount?.id)
                tempRef.child("location").setValue(tempRecord?.location)
                tempRef.child("descript").setValue(tempRecord?.descript)
                tempRef.child("date").setValue(tempRecord?.date.timeIntervalSince1970)
                if tempRecord?.tempRecord != nil
                {
                    if tempRecord?.tempRecord?.id != ""
                    {
                    tempRef.child("tempRecord").setValue(tempRecord?.tempRecord?.id)
                    }
                    else
                    {
                        parentRecord.append(i)
                    }
                }
                else
                {
                    tempRef.child("tempRecord").setValue("")
                }
            }
            try! realm.write
                {
                i.isUploaded = true
                i.isChanged = false
                }
        }
        for i in parentRecord
        {
            let recordRef = ref.child("users").child(userInfor!.username).child("records").child(i.id)
            switch i.type {
            case 0:
                recordRef.child("borrowRecord").setValue(i.expense?.borrowRecord?.id)
            case 1:
                recordRef.child("lendRecord").setValue(i.income?.lendRecord?.id)
            case 4:
                recordRef.child("transferFee").setValue(i.transfer?.transferFee?.id)
            case 5:
                recordRef.child("tempRecord").setValue(i.adjustment?.tempRecord?.id)
            default:
                continue
            }
        }
        let personsRef = ref.child("users").child(userInfor!.username).child("persons")
        personsRef.removeValue()
        for i in userInfor!.persons
        {
            personsRef.childByAutoId().setValue(i)
        }
        let locationRef = ref.child("users").child(userInfor!.username).child("locations")
        locationRef.removeValue()
        for i in userInfor!.locations
        {
            locationRef.childByAutoId().setValue(i)
        }
        let eventRef = ref.child("users").child(userInfor!.username).child("events")
        eventRef.removeValue()
        for i in userInfor!.events
        {
            eventRef.childByAutoId().setValue(i)
        }
        ProgressHUD.dismiss()
        SCLAlertView().showSuccess("Sync data successfully!", subTitle: "")
        print("Sync successfully!")
        return
    }
    
    func reloadAccounts(completionHandler: @escaping accountArrayClosure)
    {
        var result: [polyAccount] = []
        let accountsRef = ref.child("users").child(userInfor!.username).child("accounts")
        accountsRef.observe(.value, with: { (snapshot) in
            if let accounts = snapshot.children.allObjects as? [DataSnapshot]{
                for i in accounts
                {
                    let temp = i.value as! [String: Any]
                    let tempPolyAcc = polyAccount()
                    tempPolyAcc.id = Int(i.key)!
                    tempPolyAcc.isUploaded = true
                    tempPolyAcc.type = temp["type"] as! Int
                    if tempPolyAcc.type == 1
                    {
                        tempPolyAcc.bankingAcc = BankingAccount()
                        tempPolyAcc.bankingAcc?.id = temp["id"] as! Int
                        tempPolyAcc.bankingAcc?.name = temp["name"] as! String
                        tempPolyAcc.bankingAcc?.currency = temp["currency"] as! String
                        tempPolyAcc.bankingAcc?.balance = temp["balance"] as! Float
                        tempPolyAcc.bankingAcc?.active = temp["active"] as! Bool
                        tempPolyAcc.bankingAcc?.descrip = temp["descrip"] as! String
                        tempPolyAcc.bankingAcc?.bankName = temp["bankName"] as! String
                        
                        result.append(tempPolyAcc)
                    }
                    if tempPolyAcc.type == 0
                    {
                        tempPolyAcc.cashAcc = Account()
                        tempPolyAcc.cashAcc?.id = temp["id"] as! Int
                        tempPolyAcc.cashAcc?.name = temp["name"] as! String
                        tempPolyAcc.cashAcc?.currency = temp["currency"] as! String
                        tempPolyAcc.cashAcc?.balance = temp["balance"] as! Float
                        tempPolyAcc.cashAcc?.active = temp["active"] as! Bool
                        tempPolyAcc.cashAcc?.descrip = temp["descrip"] as! String
                        result.append(tempPolyAcc)
                    }
                }
                DispatchQueue.main.async() {
                    if result.isEmpty {
                        completionHandler(nil)
                    }
                    else
                    {
                    completionHandler(result)
                    }
                }
                }
            })
    }
    
    func reloadRecords(completionHandler: @escaping recordArrayClosure)
    {
        var result: [polyRecord] = []
        var parentIndex: [Int] = []
        var childID: [String] = []
        let recordsRef = ref.child("users").child(userInfor!.username).child("records")
        recordsRef.observe(.value, with: { [self] (snapshot) in
            if let records = snapshot.children.allObjects as? [DataSnapshot]{
                for i in records
                {
                    let temp = i.value as! [String: Any]
                    let tempRecord = polyRecord()
                    tempRecord.id = i.key
                    tempRecord.isUploaded = true
                    tempRecord.type = temp["type"] as! Int
                    switch tempRecord.type {
                    case 0:
                        let tempExpense = Expense()
                        tempExpense.type = tempRecord.type
                        tempExpense.amount = temp["amount"] as! Float
//                        find account by id
                        let srcAccountID = temp["srcAccount"] as! Int
                        tempExpense.srcAccount = userInfor?.getAccountByID(id: srcAccountID)
                        tempExpense.category = temp["category"] as! Int
                        tempExpense.detailCategory = temp["detailCategory"] as! Int
                        tempExpense.payee = temp["payee"] as! String
                        tempExpense.event = temp["event"] as! String
                        tempExpense.location = temp["location"] as! String
                        tempExpense.descript = temp["descript"] as! String
//                        get date by timeInterval
                        let tempDate = temp["date"] as! TimeInterval
                        tempExpense.date = Date(timeIntervalSince1970: tempDate)
                        let borrowRecordID = temp["borrowRecord"] as! String
                        if borrowRecordID == ""
                        {
                            tempExpense.borrowRecord = nil
                        }
                        else
                        {
                            //find tempRecord
                            parentIndex.append(result.count)
                            childID.append(borrowRecordID)
                        }
                        
                        tempRecord.expense = tempExpense
                        result.append(tempRecord)
                        
                    case 1:
                        let tempIncome = Income()
                        tempIncome.type = tempRecord.type
                        tempIncome.amount = temp["amount"] as! Float
                        //find account by id
                        let srcAccountID = temp["srcAccount"] as! Int
                        tempIncome.id = temp["id"] as! Int
                        tempIncome.srcAccount = userInfor?.getAccountByID(id: srcAccountID)
                        tempIncome.category = temp["category"] as! Int
                        tempIncome.payer = temp["payer"] as! String
                        tempIncome.event = temp["event"] as! String
                        tempIncome.location = temp["location"] as! String
                        tempIncome.descript = temp["descript"] as! String
                        let tempDate = temp["date"] as! TimeInterval
                        tempIncome.date = Date(timeIntervalSince1970: tempDate)
                        
                        let lendRecordID = temp["lendRecord"] as! String
                        if lendRecordID == ""
                        {
                            tempIncome.lendRecord = nil
                        }
                        else
                        {
                            //find tempRecord
                            parentIndex.append(result.count)
                            childID.append(lendRecordID)
                        }
                        tempRecord.income = tempIncome
                        result.append(tempRecord)
                    case 2:
                        let tempLend = Lend()
                        tempLend.type = 2
                        tempLend.amount = temp["amount"] as! Float
                        //find account by id
                        let srcAccountID = temp["srcAccount"] as! Int
                        tempLend.srcAccount = userInfor?.getAccountByID(id: srcAccountID)
                        tempLend.remain = temp["remain"] as! Float
                        tempLend.over = temp["over"] as! Float
                        tempLend.borrower = temp["borrower"] as! String
                        
                        tempLend.location = temp["location"] as! String
                        tempLend.descript = temp["descript"] as! String
//                        get date by timeInterval
                        let tempDate = temp["date"] as! TimeInterval
                        tempLend.date = Date(timeIntervalSince1970: tempDate)
                        //get collection date by timeInterval
                        if let tempCollectionDate = temp["date"] as? TimeInterval
                        {
                            tempLend.date = Date(timeIntervalSince1970: tempCollectionDate)
                        }
                        else
                        {
                            tempLend.collectionDate = nil
                        }
                        tempLend.isCollected = temp["isCollected"] as! Bool
                        tempRecord.lend = tempLend
                        result.append(tempRecord)

                    case 3:
                        let tempBorrow = Borrow()
                        tempBorrow.type = 3
                        tempBorrow.amount = temp["amount"] as! Float
                        //find account by id
                        let srcAccountID = temp["srcAccount"] as! Int
                        tempBorrow.srcAccount = userInfor?.getAccountByID(id: srcAccountID)
                        
                        tempBorrow.remain = temp["remain"] as! Float
                        tempBorrow.over = temp ["over"] as! Float
                        
                        tempBorrow.lender = temp["lender"] as! String
                        tempBorrow.location = temp["location"] as! String
                        tempBorrow.descript = temp["descript"] as! String
                        //get date by timeInterval
                        let tempDate = temp["date"] as! TimeInterval
                        tempBorrow.date = Date(timeIntervalSince1970: tempDate)
                        //get repayment date by timeInterval
                        if let tempRepaymentDate = temp["date"] as? TimeInterval
                        {
                            tempBorrow.repaymentDate = Date(timeIntervalSince1970: tempRepaymentDate)
                        }
                        else
                        {
                            tempBorrow.repaymentDate = nil
                        }
                        tempBorrow.isRepayed = temp["isRepayed"] as! Bool

                        tempRecord.borrow = tempBorrow
                        result.append(tempRecord)

                    case 4:
                        let tempTransfer = Transfer()
                        tempTransfer.type = 4
                        tempTransfer.amount = temp["amount"] as! Float
                        //find srcAccount by id
                        let srcAccountID = temp["srcAccount"] as! Int
                        tempTransfer.srcAccount = userInfor?.getAccountByID(id: srcAccountID)
                        //find destAccount by id
                        let destAccountID = temp["destinationAccount"] as! Int
                        tempTransfer.destinationAccount = userInfor?.getAccountByID(id: destAccountID)
                        tempTransfer.location = temp["location"] as! String
                        tempTransfer.descript = temp["descript"] as! String
                        //get date by timeInterval
                        let tempDate = temp["date"] as! TimeInterval
                        tempTransfer.date = Date(timeIntervalSince1970: tempDate)
                        let transferFeeID = temp["transferFeeID"] as! String
                        
                        if transferFeeID == ""
                        {
                            tempTransfer.transferFee = nil
                        }
                        else
                        {
                            parentIndex.append(result.count)
                            childID.append(transferFeeID)
                        }
                        tempRecord.transfer = tempTransfer
                        result.append(tempRecord)
                    default:
                        let tempAdjustment = Adjustment()
                        tempAdjustment.type = 5
                        tempAdjustment.amount = temp["amount"] as! Float
                        tempAdjustment.different = temp["different"] as! Float
                        tempAdjustment.subType = temp["subType"] as! Int
                        tempAdjustment.category = temp["category"] as! Int
                        tempAdjustment.detailCategory = temp["detailCategory"] as! Int
                        //find srcAccount by id
                        let srcAccountID = temp["srcAccount"] as! Int
                        tempAdjustment.srcAccount = userInfor?.getAccountByID(id: srcAccountID)
                        
                        tempAdjustment.location = temp["location"] as! String
                        tempAdjustment.descript = temp["descript"] as! String
                        //get date by timeInterval
                        let tempDate = temp["date"] as! TimeInterval
                        tempAdjustment.date = Date(timeIntervalSince1970: tempDate)
                        let childRecordID = temp["tempRecord"] as! String
                        if childRecordID == ""
                        {
                            tempAdjustment.tempRecord = nil
                        }
                        else
                        {
                            parentIndex.append(result.count)
                            childID.append(childRecordID)
                        }
                        tempRecord.adjustment = tempAdjustment
                        result.append(tempRecord)
                    }
                }
                if parentIndex.isEmpty == false
                {
                    for index in 0...parentIndex.count-1
                {
                    //get record by id
                    let temp = findRecordByID(arr: result,id: childID[index])
                        switch result[parentIndex[index]].type {
                        case 0:
                            result[parentIndex[index]].expense?.borrowRecord = temp
                        case 1:
                            result[parentIndex[index]].income?.lendRecord = temp
                        case 4:
                            result[parentIndex[index]].transfer?.transferFee = temp
                        default:
                            result[parentIndex[index]].adjustment?.tempRecord = temp
                        }
                }
                }
                DispatchQueue.main.async() {
                    if result.isEmpty {
                        completionHandler(nil)
                    }
                    else
                    {
                    completionHandler(result)
                    }
                }
                }
            })

    }
    func findRecordByID(arr: [polyRecord],id: String) -> polyRecord?
    {
        for i in arr
        {
            if i.id == id
            {
                return i
            }
        }
        return nil
    }

    func reloadUserinfor()
    {
        //get user infor
        let inforRef = ref.child("users").child(userInfor!.username).child("infor")
        //get userInfor
        inforRef.observe(.value, with: { (snapshot) in
            let data = snapshot.value
//            print(data["persons"] as! String)
            print(data)
        })
    }
    @IBAction func clickReloadData(_ sender: Any) {
        checkConnection{ [self] connectionStt in
            if connectionStt == false
            {
                SCLAlertView().showError("No connection", subTitle: "Check your internet connection and try again!")
                return
            }
            else
            {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let msg = SCLAlertView(appearance: appearance)
                msg.addButton("No", action: {
                    return
                })
                msg.addButton("Yes", action: { [self] in
                    reloadDataFromFirebase()
                })
                msg.showWarning("Reload data will delete all current data.", subTitle: "Your data will be replaced by data you had been sync last time. Do you want to continue?")
            }
        }
    }
    
    func reloadDataFromFirebase(){
        ProgressHUD.show("Reloading your data from database online...")
        try! realm.write {
            let tempUsername = userInfor!.username
            realm.deleteAll()
            userInfor = User()
            userInfor?.username = tempUsername
            realm.add(userInfor!)
        }
        
        reloadAccounts{ [self]accountArrayClosure in
            if let accounts = accountArrayClosure
            {
                try! self.realm.write{
                    realm.add(accounts)
                    userInfor?.accounts.append(objectsIn: accounts)
                }
                reloadRecords{ recordArrayClosure in
                    if let records = recordArrayClosure
                    {
                        try! realm.write{
                        realm.add(records)
                        userInfor?.records.append(objectsIn: records)
                        }
                        ProgressHUD.dismiss()
                        SCLAlertView().showSuccess("Data reloaded successfully!", subTitle: "")
                    }
                    else
                    {
                    ProgressHUD.dismiss()
                    SCLAlertView().showSuccess("Data reloaded successfully!", subTitle: "")
                    }
                }
            }
            else
            {
                ProgressHUD.dismiss()
                SCLAlertView().showSuccess("Data reloaded successfully!", subTitle: "")
            }
        }

    }
    @IBAction func clickResetData(_ sender: Any) {
        checkConnection{ [self] connectionStt in
            if connectionStt == false
            {
                SCLAlertView().showError("No connection", subTitle: "Check your internet connection and try again!")
                return
            }
            else
            {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let msg = SCLAlertView(appearance: appearance)
                msg.addButton("No", action: {
                    return
                })
                msg.addButton("Yes", action: { [self] in
                    resetAllData()
                })
                msg.showWarning("Your all data will be deleted!", subTitle: "Your data in this device and on database online. Do you want to continue?")
            }
        }
    }
    func resetAllData()  {
        ProgressHUD.show()
        try! realm.write {
            let tempUsername = userInfor!.username
            realm.deleteAll()
            userInfor = User()
            userInfor?.username = tempUsername
            realm.add(userInfor!)
        }
        //delete data ỉn firebase
        let tempRef = ref.child("users").child(userInfor!.username)
        tempRef.removeValue()
        SCLAlertView().showSuccess("All data had been deleted!", subTitle: "")
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        getUser()
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
        return 3
    }

}
