//
//  File.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/26/20.
//

import Foundation
import RealmSwift
import SCLAlertView
import FirebaseDatabase
	
struct currencyBase{
    let nameEnglish = ["Dollar ($)","Vietnamese Dong (VND)","Japanese Yen","Chinese Yuan","Euro","Korean Won"]
    let nameVietnamese = ["Đô la ($)","Việt Nam đồng (VNĐ)","Yen Nhật Bản","Nhân dân tệ","Euro","Won Hàn Quốc"]
    let symbol = ["$","VND","Yen","Yuan","Euro","Won"]
    var valueBaseDolar = [1,23255,104.5,6.5,0.84,900]
}
struct categoryValues {
    let expense = [
                    ["Food and Dining", "Bars and Coffee","Groceries","Restaurant"],
                      ["Utilities","Electricity","Internet","Mobile Phone","Water","Gas","Cable TV","Home Phone"]
                      ,["Auto and Transport","Fuel","Service and Parts","Insurance","Parking","Taxi"],
                    ["Home","Furnishing","Mortgage and Rent","Home services"],
                    ["Clothing","Clothes","Shoes","Accessories"],
                    ["Kids","Tuition","Babysitter and Daycare","Baby supplies","Toys","Allowwance"],
                      ["Gift and Donations","Charity","Gifts"],
                      ["Health and Fitness","Doctor","Pharmacy","Sports","Health Insurance"],
                      ["Entertainment","Music","Travel","Movies and DVDs"],
                      ["Personal","Education","Hobbies","Spa and Massage"],
                      ["Pets","Cat","Dog"],
                      ["Other","Transfer fee","Repayment"]
    ]
    let income = [["Bonus","Interest","Salary","Savings interesst","Collecting debts","Other"]]
    let other = [["Lend","Borrow","Repayment","Collecting debts"]]
    let typeRecord = ["Expense", "Income", "Lend","Borrow","Transfer","Adjustment"]
    
}
class User: Object{
    @objc dynamic var username: String = ""
    
    @objc dynamic var password: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var fbLink: String = ""
    
    @objc dynamic var numberPhone: String = ""
    @objc dynamic var displayName: String = ""
    @objc dynamic var birthDay: Date = Date()
    @objc dynamic var address: String = ""
    @objc dynamic var isMale: Bool = false
    @objc dynamic var job: String = ""
    
    @objc dynamic var isVietnamese: Bool = false
    @objc dynamic var defaultScreen = 0
    @objc dynamic var dateFormat = "dd/MM/yyyy"
    @objc dynamic var currency = 1
    @objc dynamic var isHideAmount = false
    
    @objc dynamic var isChangedRecords: Bool = true
    @objc dynamic var isChangedAccounts: Bool = true
    @objc dynamic var isChangedPersons: Bool = true
    @objc dynamic var isChangedLocations: Bool = true
    @objc dynamic var isChangedEvents: Bool = true
    
    @objc dynamic var lastSync: Date? = nil

    

    var records = List<polyRecord>()
    var accounts = List<polyAccount>()
    
    var persons = List<String>()
    var locations = List<String>()
    var events = List<String>()
    
    func getRecordByID(id: String) -> polyRecord?
    {
        for i in records
        {
            if i.id == id
            {
                return i
            }
        }
        return nil
    }
    func getAccountByID(id: Int) -> polyAccount?
    {
        for i in accounts
        {
            if i.id == id
            {
                return i
            }
        }
        return nil
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
    var ref = Database.database().reference()
    let formatter = DateFormatter()
    
    func syncData()
    {
        let accountRef = ref.child("users").child(username).child("accounts")
        print("Begin sync accounts")
        for i in accounts
        {
            if i.isDeleted == true
            {
                accountRef.child(String(i.id)).removeValue()
                try! realm!.write
                    {
                    switch i.type
                    {
                    case 0:
                        realm!.delete(i.cashAcc!)
                    case 1:
                        realm!.delete(i.bankingAcc!)
                    default:
                        realm!.delete(i.savingAcc!)
                    }
                    realm!.delete(i)
                }
                print("Synced a deleted account.")
                continue
            }
            if i.isChanged == false{
                print("Ignored an unchanged account.")
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
                print("Synced an account.")
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
                print("Synced an banking account.")
            default:
                let tempAcc = i.savingAcc
                tempRef.child("type").setValue(2)
                tempRef.child("id").setValue(tempAcc?.id)
                tempRef.child("name").setValue(tempAcc?.name)
                tempRef.child("ammount").setValue(tempAcc?.ammount)
                tempRef.child("srcAccount").setValue(tempAcc?.srcAccount?.id)
                tempRef.child("destAccount").setValue(tempAcc?.destAccount?.id)
                tempRef.child("startdate").setValue(tempAcc?.startdate.timeIntervalSince1970)
                tempRef.child("currency").setValue(tempAcc?.currency)
                tempRef.child("bank").setValue(tempAcc?.bank)
                tempRef.child("term").setValue(tempAcc?.term)
                tempRef.child("interestRate").setValue(tempAcc?.interestRate)
                tempRef.child("freeInterestRate").setValue(tempAcc?.freeInterestRate)
                tempRef.child("numDays").setValue(tempAcc?.numDays)
                tempRef.child("interestPaid").setValue(tempAcc?.interestPaid)
                tempRef.child("termEnded").setValue(tempAcc?.termEnded)
                tempRef.child("descrip").setValue(tempAcc?.descrip)
                tempRef.child("includeRecord").setValue(tempAcc?.includeRecord)
                tempRef.child("interest").setValue(tempAcc?.interest)
                tempRef.child("nextTermDate").setValue(tempAcc?.nextTermDate.timeIntervalSince1970)
                tempRef.child("state").setValue(tempAcc?.state)
                print("Synced an saving account.")
            }
            try! realm!.write
                {
                i.isUploaded = true
                i.isChanged = false
            }
        }
        //upload records
        var parentRecord: [polyRecord] = []
        let recordRef = ref.child("users").child(username).child("records")
        print("sync records")
        for i in records
        {
            if i.isDeleted == true
            {
                recordRef.child(i.id).removeValue()
                try! realm!.write{
                switch i.type {
                case 0:
                    realm!.delete(i.expense!)
                case 1:
                    realm!.delete(i.income!)
                case 2:
                    realm!.delete(i.lend!)
                case 3:
                    realm!.delete(i.borrow!)
                case 4:
                    realm!.delete(i.transfer!)
                default:
                    realm?.delete(i.adjustment!)
                }
                    realm!.delete(i)
                }
                print("Deleted a synced record.")
                continue
            }
            //check if it changed
            if i.isChanged == false
            {
                print("Ignored an unchanged record.")
                continue
            }
            let tempRef: DatabaseReference
            if i.id == ""
            {
            tempRef = recordRef.childByAutoId()
                try! realm!.write
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
            try! realm!.write
                {
                i.isUploaded = true
                i.isChanged = false
                print("Synced a record.")
                }
        }
        for i in parentRecord
        {
            let recordRef = ref.child("users").child(username).child("records").child(i.id)
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
        let personsRef = ref.child("users").child(username).child("persons")
        personsRef.removeValue()
        for i in persons
        {
            personsRef.childByAutoId().setValue(i)
        }
        let locationRef = ref.child("users").child(username).child("locations")
        locationRef.removeValue()
        for i in locations
        {
            locationRef.childByAutoId().setValue(i)
        }
        let eventRef = ref.child("users").child(username).child("events")
        eventRef.removeValue()
        for i in events
        {
            eventRef.childByAutoId().setValue(i)
        }
        var tempRef = ref.child("users").child(username).child("birthDay")
        tempRef.removeValue()
        tempRef.setValue(birthDay.timeIntervalSince1970)
        
        tempRef = ref.child("users").child(username).child("job")
        tempRef.removeValue()
        tempRef.setValue(job)
        
        tempRef = ref.child("users").child(username).child("numberPhone")
        tempRef.removeValue()
        tempRef.setValue(numberPhone)
        
        tempRef = ref.child("users").child(username).child("address")
        tempRef.removeValue()
        tempRef.setValue(address)
        
        tempRef = ref.child("users").child(username).child("isMale")
        tempRef.removeValue()
        tempRef.setValue(isMale)
        
        tempRef = ref.child("users").child(username).child("defaultScreen")
        tempRef.removeValue()
        tempRef.setValue(defaultScreen)
        
        tempRef = ref.child("users").child(username).child("isVietnamese")
        tempRef.removeValue()
        tempRef.setValue(isVietnamese)
        
        tempRef = ref.child("users").child(username).child("dateFormat")
        tempRef.removeValue()
        tempRef.setValue(dateFormat)
        
        tempRef = ref.child("users").child(username).child("isHideAmount")
        tempRef.removeValue()
        tempRef.setValue(isHideAmount)
        
        tempRef = ref.child("users").child(username).child("currency")
        tempRef.removeValue()
        tempRef.setValue(currency)
        
        try! realm?.write{
            lastSync = Date()
        }
    }
    func deleteLocalData(){
        print("Begin delete local data...")
        try! realm!.write {
            for i in accounts
            {
                switch i.type {
                case 0:
                    realm!.delete(i.cashAcc!)
                case 1:
                    realm!.delete(i.bankingAcc!)
                default:
                    realm!.delete(i.savingAcc!)
                }
                realm!.delete(i)
            }
            for i in records
            {
                switch i.type {
                case 0:
                    realm!.delete(i.expense!)
                case 1:
                    realm!.delete(i.income!)
                case 2:
                    realm!.delete(i.lend!)
                case 3:
                    realm!.delete(i.borrow!)
                case 4:
                    realm!.delete(i.transfer!)
                default:
                    realm!.delete(i.adjustment!)
                }
                realm!.delete(i)
            }
            persons.removeAll()
            locations.removeAll()
            events.removeAll()
        }
        print("Deleted local data.")
    }
    func reloadData(completionHandler: @escaping (_ result: Bool) -> Void)
    {
        print("Begin reload infor...")
        let userRef = ref.child("users").child(username)
        userRef.observeSingleEvent(of: .value, with: { [self] snapshot in
            if snapshot.exists() == false
            {
                completionHandler(false)
                return
            }
            let data = snapshot.value as? [String: Any]
            try! realm?.write{
            numberPhone = data!["numberPhone"] as! String
            address = data!["address"] as! String
            job = data!["job"] as! String
            birthDay = Date(timeIntervalSince1970: (data!["birthDay"] as! TimeInterval))
            isMale = data!["isMale"] as! Bool
            
            isVietnamese = data!["isVietnamese"] as! Bool
            currency = data!["currency"] as! Int
            defaultScreen = data!["defaultScreen"] as! Int
            dateFormat = data!["dateFormat"] as! String
            isHideAmount = data!["isHideAmount"] as! Bool
            }
            
            let accountsData = snapshot.childSnapshot(forPath: "accounts")
            print(accountsData)
            var resultAccount: [polyAccount] = []
            print("Begin reload accounts...")
            for i in accountsData.children.allObjects as! [DataSnapshot]
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
                    resultAccount.append(tempPolyAcc)
                    print("Reload an banking account.")
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
                    resultAccount.append(tempPolyAcc)
                    print("Reload an normal account.")
                }
                if tempPolyAcc.type == 2
                {
                    tempPolyAcc.savingAcc = savingAccount()
                    tempPolyAcc.savingAcc?.name = temp["name"] as! String
                    tempPolyAcc.savingAcc?.id = temp["id"] as! Int
                    let tempStartDate = temp["startdate"] as! TimeInterval
                    tempPolyAcc.savingAcc?.startdate = Date(timeIntervalSince1970: tempStartDate)
                    let tempNextTermDate = temp["nextTermDate"] as! TimeInterval
                    tempPolyAcc.savingAcc?.nextTermDate = Date(timeIntervalSince1970: tempNextTermDate)
                    tempPolyAcc.savingAcc?.currency = temp["currency"] as! String
                    tempPolyAcc.savingAcc?.bank = temp["bank"] as! String
                    tempPolyAcc.savingAcc?.term = temp["term"] as! String
                    tempPolyAcc.savingAcc?.interestRate = temp["interestRate"] as! Float
                    tempPolyAcc.savingAcc?.freeInterestRate = temp["freeInterestRate"] as! Float
                    tempPolyAcc.savingAcc?.numDays = temp["numDays"] as! Int
                    tempPolyAcc.savingAcc?.interestPaid = temp["interestPaid"] as! Int
                    tempPolyAcc.savingAcc?.termEnded = temp["termEnded"] as! Int
                    tempPolyAcc.savingAcc?.termEnded = temp["termEnded"] as! Int
                    let tempSrcAcc = temp["srcAccount"] as! Int
                    tempPolyAcc.savingAcc?.srcAccount = getAccountByID(id: tempSrcAcc)
                    let tempDestAcc = temp["destAccount"] as! Int
                    tempPolyAcc.savingAcc?.destAccount = getAccountByID(id: tempDestAcc)
                    tempPolyAcc.savingAcc?.descrip = temp["descrip"] as! String
                    tempPolyAcc.savingAcc?.includeRecord = temp["includeRecord"] as! Bool
                    tempPolyAcc.savingAcc?.ammount = temp["ammount"] as! Float
                    tempPolyAcc.savingAcc?.state = temp["state"] as! Bool
                    tempPolyAcc.savingAcc?.interest = temp["interest"] as! Float
                    resultAccount.append(tempPolyAcc)
                    print("Reload an saving account.")
                }
                try! realm?.write{
                    realm?.add(tempPolyAcc)
                    accounts.append(tempPolyAcc)
                }
            }
            //reload records
            let recordsData = snapshot.childSnapshot(forPath: "records")
            print(recordsData)
            var recordsResult: [polyRecord] = []
            var parentIndex: [Int] = []
            var childID: [String] = []
            print("Begin reload records...")
            for i in recordsData.children.allObjects as! [DataSnapshot]
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
                    tempExpense.srcAccount = self.getAccountByID(id: srcAccountID)
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
                        parentIndex.append(recordsResult.count)
                        childID.append(borrowRecordID)
                    }
                    
                    tempRecord.expense = tempExpense
                    recordsResult.append(tempRecord)
                    
                case 1:
                    let tempIncome = Income()
                    tempIncome.type = tempRecord.type
                    tempIncome.amount = temp["amount"] as! Float
                    //find account by id
                    let srcAccountID = temp["srcAccount"] as! Int
                    tempIncome.id = temp["id"] as! Int
                    tempIncome.srcAccount = self.getAccountByID(id: srcAccountID)
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
                        parentIndex.append(recordsResult.count)
                        childID.append(lendRecordID)
                    }
                    tempRecord.income = tempIncome
                    recordsResult.append(tempRecord)
                case 2:
                    let tempLend = Lend()
                    tempLend.type = 2
                    tempLend.amount = temp["amount"] as! Float
                    //find account by id
                    let srcAccountID = temp["srcAccount"] as! Int
                    tempLend.srcAccount = self.getAccountByID(id: srcAccountID)
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
                    recordsResult.append(tempRecord)

                case 3:
                    let tempBorrow = Borrow()
                    tempBorrow.type = 3
                    tempBorrow.amount = temp["amount"] as! Float
                    //find account by id
                    let srcAccountID = temp["srcAccount"] as! Int
                    tempBorrow.srcAccount = self.getAccountByID(id: srcAccountID)
                    
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
                    recordsResult.append(tempRecord)

                case 4:
                    let tempTransfer = Transfer()
                    tempTransfer.type = 4
                    tempTransfer.amount = temp["amount"] as! Float
                    //find srcAccount by id
                    let srcAccountID = temp["srcAccount"] as! Int
                    tempTransfer.srcAccount = self.getAccountByID(id: srcAccountID)
                    //find destAccount by id
                    let destAccountID = temp["destinationAccount"] as! Int
                    tempTransfer.destinationAccount = self.getAccountByID(id: destAccountID)
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
                        parentIndex.append(recordsResult.count)
                        childID.append(transferFeeID)
                    }
                    tempRecord.transfer = tempTransfer
                    recordsResult.append(tempRecord)
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
                    tempAdjustment.srcAccount = self.getAccountByID(id: srcAccountID)
                    
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
                        parentIndex.append(recordsResult.count)
                        childID.append(childRecordID)
                    }
                    tempRecord.adjustment = tempAdjustment
                    recordsResult.append(tempRecord)
                }
            }
            if parentIndex.isEmpty == false
            {
                for index in 0...parentIndex.count-1
            {
                //get record by id
                let temp = findRecordByID(arr: recordsResult,id: childID[index])
                    switch recordsResult[parentIndex[index]].type {
                    case 0:
                        recordsResult[parentIndex[index]].expense?.borrowRecord = temp
                    case 1:
                        recordsResult[parentIndex[index]].income?.lendRecord = temp
                    case 4:
                        recordsResult[parentIndex[index]].transfer?.transferFee = temp
                    default:
                        recordsResult[parentIndex[index]].adjustment?.tempRecord = temp
                    }
            }
            }
            try! realm?.write{
                for i in recordsResult{
                    realm?.add(i)
                }
            records.append(objectsIn: recordsResult)
            }
            completionHandler(true)
        })
    }
    
    
}

class Record : Object {
    @objc dynamic var id: Int = 0

    @objc dynamic var amount: Float = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var descript: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var location: String = ""

    @objc dynamic var srcAccount: polyAccount? = nil
    
//    @objc dynamic var srcImg: String = ""
    
    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_location: String,_srcImg: String, _date: Date ) {
        
        amount = _amount
        type = _type
        descript = _descript
        srcAccount = _srcAccount
        location = _location
        date = _date
//        srcImg = _srcImg
        
    }
}

class Expense: Record{
    
    @objc dynamic var category: Int = -1
    @objc dynamic var detailCategory: Int = -1
    @objc dynamic var payee: String = ""
    @objc dynamic var event: String = ""
    @objc dynamic var borrowRecord: polyRecord? = nil


    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_event: String,_srcImg: String,_date: Date, _category: Int, _detailCategory: Int,_borrowRecord: polyRecord?)
    {
        
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg, _date: _date)
        event = _event
        payee = _person
        category = _category
        detailCategory = _detailCategory
        borrowRecord = _borrowRecord
        doTransaction()

    }
    func updateData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_event: String,_srcImg: String,_date: Date, _category: Int, _detailCategory: Int,_borrowRecord: polyRecord?)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg, _date: _date)
        event = _event
        payee = _person
        category = _category
        detailCategory = _detailCategory
        borrowRecord = _borrowRecord
        doTransaction()
    }
    func doTransaction() -> Void {
        print("Do transaction of expense with \(amount), category: \(categoryValues().expense[category][detailCategory])")
        srcAccount?.expense(_amount: amount)
        srcAccount?.isChanged = true
        //repay if there's an borrow record
        if borrowRecord != nil
        {
            borrowRecord?.borrow?.repay(_amount: amount)
            borrowRecord?.isChanged = true
        }
    }
    func undoTransaction() -> Void {
        print("Undo transaction of expense with \(amount), category: \(categoryValues().expense[category][detailCategory])")
        srcAccount?.income(_amount: amount)
        srcAccount?.isChanged = true
        
        if borrowRecord != nil
        {
            borrowRecord?.borrow?.undoRepay(_amount: amount)
            borrowRecord?.isChanged = true
        }
    }
}

class Income: Record{
    @objc dynamic var category: Int = -1
    @objc dynamic var payer: String = ""
    @objc dynamic var event: String = ""
    @objc dynamic var lendRecord: polyRecord? = nil


    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_event: String,_srcImg: String,_date: Date, _category: Int,_lendRecord: polyRecord?)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg, _date: _date)
        event = _event
        payer = _person
        category = _category
        lendRecord = _lendRecord
        doTransaction()
    }
    func doTransaction() -> Void {
        print("Do transaction of income with \(amount), category: \(categoryValues().income[0][category])")
        srcAccount?.income(_amount: amount)
        srcAccount?.isChanged = true
        // collect debt if there is an lend record
        if lendRecord != nil
            {
            lendRecord?.lend?.collect(_amount: amount)
            lendRecord?.isChanged = true
            }
    }
    func undoTransaction() -> Void {
        print("Undo transaction of income with \(amount), category: \(categoryValues().income[0][category])")
        srcAccount?.expense(_amount: amount)
        srcAccount?.isChanged = true
        
        if lendRecord != nil
            {
            lendRecord?.lend?.undoCollect(_amount: amount)
            lendRecord?.isChanged = true
            }
    }
    func add(){
        let realm = try! Realm()
        let record = polyRecord()
        record.type = 1
        record.income = self
        try! realm.write{
            realm.add(self)
            realm.add(record)
        }
    }
}

class Borrow: Record{
    @objc dynamic var remain: Float = 0
    @objc dynamic var over: Float = 0
    @objc dynamic var repaymentDate: Date? = nil
    @objc dynamic var isRepayed: Bool = false
    @objc dynamic var lender: String = ""

    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: String,_date: Date, _repaymentDate: Date?, _isRepayed: Bool)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg,_date: _date )
        remain = _amount
        lender = _person
        repaymentDate = _repaymentDate
        isRepayed = _isRepayed
        doTransaction()
    }
    func updateBorrow(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: String,_date: Date, _repaymentDate: Date?)
    {
        //update remain, over and isRepayed
        if remain == 0
        {
            if _amount > amount + over
            {
                isRepayed = false
                remain = _amount - amount - over
                amount = _amount
                over = 0
            }
            else
            {
                over = over + amount - _amount
                amount = _amount
            }
        }
        else
        {
            let collected = amount - remain
            if _amount <= collected {
                isRepayed = true
                remain = 0
                over = collected - _amount
                amount = _amount
            }
            else
            {
                remain = _amount - collected
                amount = _amount
            }
        }
        
        lender = _person
        repaymentDate = _repaymentDate
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg,_date: _date )
    }
    
    func repay(_amount: Float) {
        if(_amount>=remain)
        {
            over = _amount - remain
            remain = 0
            isRepayed = true
            return
        }
        remain = remain - _amount
    }
    func undoRepay(_amount: Float) {
        if _amount > over
        {
            remain = remain + _amount - over
            over = 0
            isRepayed = false
        }
        else
        {
            over = over - _amount
        }
    }
    func doTransaction() -> Void {
        print("Do transaction of borrow with \(amount)")
        srcAccount?.income(_amount: amount)
        srcAccount?.isChanged = true
    }
    func undoTransaction() -> Void {
        print("Undo transaction of borrow with \(amount)")
        srcAccount?.expense(_amount: amount)
        srcAccount?.isChanged = true
    }
}

class Lend: Record{
    @objc dynamic var remain: Float = 0
    @objc dynamic var over: Float = 0
    @objc dynamic var collectionDate: Date? = nil
    @objc dynamic var isCollected: Bool = false
    @objc dynamic var borrower: String = ""

    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: String,_date: Date, _collectionDate: Date?,_isCollected: Bool)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg,_date: _date)
        
        remain = _amount
        borrower = _person
        collectionDate = _collectionDate
        isCollected = _isCollected
        doTransaction()
    }
    func updateLend(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: String,_date: Date, _collectionDate: Date?) {
        
        borrower = _person
        collectionDate = _collectionDate
        
        //update remain, over and isCollected
        if remain == 0
        {
            if _amount > amount + over
            {
                isCollected = false
                remain = _amount - amount - over
                amount = _amount
                over = 0
            }
            else
            {
                over = over + amount - _amount
                amount = _amount
            }
        }
        else
        {
            let payed = amount - remain
            if _amount <= payed {
                isCollected = true
                remain = 0
                over = payed - _amount
                amount = _amount
            }
            else
            {
                remain = _amount - payed
                amount = _amount
            }
        }
        borrower = _person
        collectionDate = _collectionDate
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg,_date: _date)
    }
    func collect(_amount: Float)
    {
        
        if(_amount>=remain)
        {
            over = _amount - remain
            remain = 0
            isCollected = true
            return
        }
        remain = remain - _amount
    }
    func undoCollect(_amount: Float)
    {
        if _amount > over
        {
        isCollected = false
        remain += _amount - over
        over = 0
        }
        else
        {
            over = over - _amount
        }
    }
    func doTransaction() -> Void {
        print("Do transaction of lend with...")
        srcAccount?.expense(_amount: amount)
        srcAccount?.isChanged = true
    }
    func undoTransaction() -> Void {
        print("Undo transaction of lend with...")
        srcAccount?.income(_amount: amount)
        srcAccount?.isChanged = true
    }
}

class Transfer: Record{
    @objc dynamic var destinationAccount: polyAccount? = nil
    @objc dynamic var transferFee: polyRecord? = nil
    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_location: String,_srcImg: String,_date: Date,_destAccount: polyAccount, _transferFee: polyRecord?)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg, _date: _date)
        
        destinationAccount = _destAccount
        if(_transferFee != nil)
        {
            transferFee = _transferFee
        }
        doTransaction()
    }
    func editTransFee(_fee: Float)  {
        transferFee?.expense?.amount = _fee
        transferFee?.isChanged = true
    }
    func doTransaction() -> Void {
        print("Do transaction of transfer with...")
        srcAccount?.expense(_amount: amount)
        srcAccount?.isChanged = true
        destinationAccount?.income(_amount: amount)
        destinationAccount?.isChanged = true
    }
    func undoTransaction() -> Void {
        print("Undo transaction of transfer with...")
        srcAccount?.income(_amount: amount)
        srcAccount?.isChanged = true
        destinationAccount?.expense(_amount: amount)
        destinationAccount?.isChanged = true
    }
    func add(){
        let realm = try! Realm()
        let record = polyRecord()
        record.type = 4
        record.transfer = self
        try! realm.write{
            realm.add(self)
            realm.add(record)
        }
    }
}

class Adjustment: Record{

    @objc dynamic var subType: Int = -1
    @objc dynamic var different: Float = -1
    @objc dynamic var category: Int = -1
    @objc dynamic var detailCategory: Int = -1
    @objc dynamic var tempRecord: polyRecord? = nil
    @objc dynamic var person: String = ""

    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_location: String,_srcImg: String,_date: Date, _subType: Int,_different: Float, _category: Int, _detailCategory: Int, _tempRecord: polyRecord?,_person: String)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg,_date: _date)
        subType = _subType
        different = _different
        tempRecord = _tempRecord
        category = _category
        detailCategory = _detailCategory
        person = _person
        doTransaction()
    }
    func doTransaction() -> Void {
        print("Do transaction of adjustment with...")
        if tempRecord != nil
        {
            if subType == 0
            {
                tempRecord?.borrow?.repay(_amount: different)
                tempRecord?.isChanged = true
            }
            else
            {
                tempRecord?.lend?.collect(_amount: different)
                tempRecord?.isChanged = true
            }
        }
        if subType == 0
        {
            srcAccount?.expense(_amount: different)
            srcAccount?.isChanged = true
        }
        else
        {
            srcAccount?.income(_amount: different)
            srcAccount?.isChanged = true
        }
    }
    func undoTransaction() -> Void {
        print("Undo transaction of adjustment with...")
        if tempRecord != nil
        {
            if subType == 0
            {
                tempRecord?.borrow?.undoRepay(_amount: different)
                tempRecord?.isChanged = true
            }
            else
            {
                tempRecord?.lend?.undoCollect(_amount: different)
                tempRecord?.isChanged = true
            }
        }
        if subType == 0
        {
            srcAccount?.income(_amount: different)
            srcAccount?.isChanged = true
        }
        else
        {
            srcAccount?.expense(_amount: different)
            srcAccount?.isChanged = true
        }
    }
    
}

class polyRecord: Object{
    @objc dynamic var id: String = ""
    @objc dynamic var expense: Expense? = nil
    @objc dynamic var income: Income? = nil
    @objc dynamic var borrow: Borrow? = nil
    @objc dynamic var lend: Lend? = nil
    @objc dynamic var transfer: Transfer? = nil
    @objc dynamic var adjustment: Adjustment? = nil
    @objc dynamic var type : Int = -1
    @objc dynamic var isUploaded : Bool = false
    @objc dynamic var isChanged : Bool = true
    @objc dynamic var isDeleted : Bool = false

    func getDescript() -> String {
        switch type {
        case 0:
            return expense!.descript
        case 1:
            return income!.descript
        case 2:
            return lend!.descript
        case 3:
            return borrow!.descript
        case 4:
            return transfer!.descript
        default:
            return adjustment!.descript
        }
    }
    func getCategory() -> String {
        switch type {
        case 0:
            return categoryValues().expense[expense!.category][expense!.detailCategory]
        case 1:
            return categoryValues().income[0][income!.category]
        case 2:
            return "Lend"
        case 3:
            return "Borrow"
        case 4:
            return "Transfer"
        default:
            if adjustment!.subType == 0
            {
                return categoryValues().expense[adjustment!.category][adjustment!.detailCategory]
            }
            return categoryValues().income[0][adjustment!.detailCategory]
        }
    }
    func getTypeRecord() -> String {
        switch type {
        case 0:
            return "expense"
        case 1:
            return "income"
        case 2:
            return "lend"
        case 3:
            return "borrow"
        case 4:
            return "transfer"
        default:
            return "adjustment"
        }
    }
    func getPerson() -> String {
        switch type {
        case 0:
            return expense!.payee
        case 1:
            return income!.payer
        case 2:
            return lend!.borrower
        case 3:
            return borrow!.lender
        case 4:
            return ""
        default:
            return adjustment!.person
        }
    }
}
class Account: Object{
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var balance: Float = 0
    @objc dynamic var descrip: String = ""
    @objc dynamic var includeReport: Bool = false
    @objc dynamic var currency: String = ""
    @objc dynamic var active: Bool = true
    func incrementID() -> Int {
          let realm = try! Realm()
          return (realm.objects(Account.self).max(ofProperty: "id") as Int? ?? 0) + 1
   }
    func income(amount: Float)
    {
        balance += amount
    }
    func expense(amount: Float)
    {
        balance -= amount
    }
    func add(){
        self.id = self.incrementID()
        let realm = try! Realm()
        let polyAcc = polyAccount()
        polyAcc.id = polyAccount().incrementID()
        polyAcc.cashAcc = self
        polyAcc.type = 0
        try! realm.write {
            realm.add(self)
            realm.add(polyAcc)
            realm.objects(User.self)[0].accounts.append(polyAcc)
        }
    }
}
class BankingAccount:Account {
     @objc dynamic var bankName: String = ""
    override func add(){
        self.id = self.incrementID()
        let realm = try! Realm()
        let polyAcc = polyAccount()
        polyAcc.id = polyAccount().incrementID()
        polyAcc.bankingAcc = self
        polyAcc.type = 1
        try! realm.write {
            realm.add(self)
            realm.add(polyAcc)
            realm.objects(User.self)[0].accounts.append(polyAcc)
        }
    }
}
class polyAccount: Object{
    
    @objc dynamic var id: Int = -1
    @objc dynamic var cashAcc: Account? = nil
    @objc dynamic var bankingAcc: BankingAccount? = nil
    @objc dynamic var savingAcc: savingAccount? = nil

    @objc dynamic var type : Int = -1
    @objc dynamic var isUploaded : Bool = false
    @objc dynamic var isChanged : Bool = true
    @objc dynamic var isDeleted : Bool = false

    func incrementID() -> Int {
           let realm = try! Realm()
           return (realm.objects(polyAccount.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    func getname() -> String{
        switch type {
        case 0:
            return cashAcc!.name
        case 1:
            return bankingAcc!.name
        default:
            return savingAcc!.name
        }
    }
    func getBalance() -> Float{
        switch type {
        case 0:
            return cashAcc!.balance
        case 1:
            return bankingAcc!.balance
        default:
            return 0
        }
    }
    func income(_amount: Float)
    {

        switch type {
        case 0:
            cashAcc?.income(amount: _amount)
        case 1:
            bankingAcc?.income(amount: _amount)
        default:
            return
        }
    }
    func expense(_amount: Float)
    {
        switch type {
        case 0:
            cashAcc?.expense(amount: _amount)
        case 1:
            bankingAcc?.expense(amount: _amount)
        default:
            return
        }
    }
    func del(){
        //marked if account had been uploaded
        if isUploaded == true
        {
            isDeleted = true
            
            //delete infor with this account
            return
        }
        let realm = try! Realm()
        if self.type == 0{
            try! realm.write{
                realm.delete(self.cashAcc!)
                realm.delete(self)
            }
        }
        else if type == 1{
            try! realm.write{
                realm.delete(self.bankingAcc!)
                realm.delete(self)
            }
        }
        else {
            try! realm.write{
                realm.delete(self.savingAcc!)
                realm.delete(self)
            }
        }
    }
}
class Accumulate: Object{
    @objc dynamic var id: Int = 0
    override static func primaryKey() -> String? {
        return "id"
    }
    func incrementID() -> Int {
           let realm = try! Realm()
           return (realm.objects(Accumulate.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    @objc dynamic var goal: String = ""
    @objc dynamic var balance: Float = 0
    @objc dynamic var addbalance: Float = 0
    @objc dynamic var includeReport: Bool = true
    @objc dynamic var currency: String = ""
    @objc dynamic var startdate: Date = Date()
    @objc dynamic var enddate: Date = Date()

}
class savingAccount: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var id: Int = 0
    override static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var startdate: Date = Date()
    @objc dynamic var currency: String = "VND"
    @objc dynamic var bank: String = ""
    @objc dynamic var term: String = ""
    @objc dynamic var interestRate: Float = 0
    @objc dynamic var freeInterestRate: Float = 0
    @objc dynamic var numDays: Int = 365
    @objc dynamic var interestPaid: Int = 0
    @objc dynamic var termEnded: Int = 0
    @objc dynamic var srcAccount: polyAccount? = nil
    @objc dynamic var destAccount: polyAccount? = nil
    @objc dynamic var descrip: String = ""
    @objc dynamic var includeRecord: Bool = false
    @objc dynamic var ammount: Float = 0
    @objc dynamic var state: Bool = false //1: Done, 0: not finish
    @objc dynamic var interest: Float = 0
    @objc dynamic var nextTermDate: Date = Date()
    func add(){
        self.id = self.incrementID()
        let realm = try! Realm()
        let polyAcc = polyAccount()
        polyAcc.id = polyAccount().incrementID()
        polyAcc.savingAcc = self
        polyAcc.type = 2
        try! realm.write {
            realm.add(self)
            realm.add(polyAcc)
            realm.objects(User.self)[0].accounts.append(polyAcc)
        }
        
    }
    func income(amount: Float)
       {
           ammount += amount
       }
       func expense(amount: Float)
       {
           ammount -= amount
       }
    func incrementID() -> Int {
           let realm = try! Realm()
           return (realm.objects(savingAccount.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }

    func updateInterest(){
        let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "MM/dd/yyyy"
        let realm = try! Realm()
        let allAccount = realm.objects(polyAccount.self).filter("type == 2")
        for obj in allAccount{
            if obj.savingAcc?.state == false{
            let startDate =  obj.savingAcc!.startdate
            let term = obj.savingAcc!.term
            var dateComponent = DateComponents()
            switch term{
            case "1 week", "2 weeks", "3 weeks":
                let addDays = Int(term.components(separatedBy: " ")[0]) as! Int
                dateComponent.day = addDays*7
            case "1 month", "3 months", "6 months", "12 months":
                let addMonths = Int( term.components(separatedBy: " ")[0]) as! Int
                dateComponent.month = addMonths
            default:
                dateComponent.day = 0
            }
             let endDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            var nextTerm = obj.savingAcc!.nextTermDate
            let termEnded = obj.savingAcc!.termEnded
            let interestPaid = obj.savingAcc!.interestPaid
            let srcAcc = obj.savingAcc!.srcAccount
            let destAcc = obj.savingAcc!.destAccount
            let interestRate = obj.savingAcc!.interestRate*0.01
            //Số ngày tính từ thời điểm bắt đầu đến kì hạn
            let timeTerm = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
            let termDays = timeTerm.day!
            //Số ngày tính lãi 1 năm
            let numDays = obj.savingAcc!.numDays
            //
            let amount = obj.savingAcc!.ammount
            //Maturity
            if interestPaid == 0{
                //Gốc, gửi lãi về tài khoản mỗi cuối kì, gửi gốc + phần lãi freeInterest khi đóng
                if termEnded == 1{
                    //Tăng kì hạn lên
                   while(Date() >= nextTerm){
                    let finalInterest = Float(termDays)/Float(numDays)*interestRate*amount
                    let newincome = Income()
                    newincome.id = obj.id
                    //Tạo income
                    try! realm.write{
                        newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)
                    }
                    
                    nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                    if srcAcc?.type == 0{
                        try! realm.write {
                            obj.savingAcc!.nextTermDate = nextTerm
                        }
                        newincome.add()
                    }
                    else{
                        try! realm.write {
                           srcAcc?.bankingAcc?.income(amount: finalInterest)
                            obj.savingAcc!.nextTermDate = nextTerm
                        }
                        newincome.add()
                    }
                    
                   }
                }
                // Gốc + lãi tính vào lãi, gửi tiền về tài khoản khi đóng tài khoản
                else if termEnded == 0{
                    while(Date() >= nextTerm){
                     let timeTerm = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
                     //So ngay tinh thoi thoi diem hien tai tru di ngay bat dau
                    let termDays = timeTerm.day!
                    let termInterest = Float(termDays)/Float(numDays)*interestRate
                    //Số ngày tính từ thời điểm bắt đầu đến hiện tại
                    let timePass = Calendar.current.dateComponents([.day], from: startDate, to: nextTerm)
                    let passDays = timePass.day!
                    //số kì đã qua
                    let temp1 = Float(passDays/termDays)
                    let finalInterest = pow(1+termInterest,temp1)*amount-amount
                     let newincome = Income()
                        newincome.id = obj.id
                     try! realm.write{
                          newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)
                     }
                    nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                     if srcAcc?.type == 0{
                         try! realm.write {
                            srcAcc?.cashAcc?.income(amount: finalInterest)
                             obj.savingAcc!.nextTermDate = nextTerm
                         }
                        newincome.add()
                     }
                        else{
                       try! realm.write {
                          srcAcc?.bankingAcc?.income(amount: finalInterest)
                           obj.savingAcc!.nextTermDate = nextTerm
                       }
                        newincome.add()
                   }
                     
                    }
                }
                //Close account
                else{
                    if(Date() >= nextTerm){
                     let finalInterest = Float(termDays)/Float(numDays)*interestRate*amount
                        //Tạo income
                     let newincome = Income()
                    newincome.id = obj.id
                        //Tạo transfer
                    let transfer = Transfer()
                    transfer.id = obj.id
                    
                        try! realm.write{
                             newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)
                            transfer.getData(_amount: obj.savingAcc!.ammount, _type: 4, _descript: "", _srcAccount: obj, _location: "", _srcImg: "", _date: endDate, _destAccount: obj.savingAcc!.srcAccount!, _transferFee: nil)
                        }
                    
                        
                     if srcAcc?.type == 0{
                         try! realm.write {
                            obj.savingAcc!.state = true
                            realm.add(newincome)
                            realm.add(transfer)
                         }
                     }
                     else{
                         try! realm.write {
                            srcAcc?.bankingAcc?.income(amount: finalInterest)
                            obj.savingAcc!.state = true
                             realm.add(newincome)
                            realm.add(transfer)
                            
                         }
                     }
                       
                    }
                }
              
            
            }
                //Up-front
            else if obj.savingAcc!.interestPaid == 1{
                //Gốc, gửi lãi về tài khoản mỗi đầu kì, gửi gốc - lãi Interst + phần lãi freeInterest khi đóng
                if termEnded == 1{
                    repeat{
                         let finalInterest = Float(termDays)/Float(numDays)*interestRate*amount
                         let newincome = Income()
                       newincome.id = obj.id
                         //Tạo income
                        try! realm.write{
                             newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)
                        }
                         
                         nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                         if destAcc?.type == 0{
                             try! realm.write {
                                destAcc?.cashAcc?.income(amount: finalInterest)
                                 obj.savingAcc!.nextTermDate = nextTerm
                                 realm.add(newincome)
                             }
                         }
                         else{
                             try! realm.write {
                                destAcc?.bankingAcc?.income(amount: finalInterest)
                                 obj.savingAcc!.nextTermDate = nextTerm
                                 realm.add(newincome)
                             }
                         }
                         
                    }
                    while(Date() >= nextTerm)
                }
                    //close account
                else{
                    if(Date() >= nextTerm){
                 
                     nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                     if srcAcc?.type == 0{
                         try! realm.write {
                            srcAcc?.cashAcc?.income(amount: amount)
                             obj.savingAcc!.nextTermDate = nextTerm
                            obj.savingAcc!.state = true
                         }
                     }
                     else{
                         try! realm.write {
                            srcAcc?.bankingAcc?.income(amount: amount)
                             obj.savingAcc!.nextTermDate = nextTerm
                            obj.savingAcc!.state = true
                         }
                     }
                     
                    }
                }
            }
                //Monthly
            else if obj.savingAcc!.interestPaid == 2{
                let timeTerm = Calendar.current.dateComponents([.day], from: nextTerm, to: Calendar.current.date(byAdding: dateComponent, to: nextTerm)!)
                let termDays = timeTerm.day!
                dateComponent.month = 1
                //Close account
                if termEnded == 2{
                    while(endDate >= nextTerm){
                    let finalInterest = Float(termDays)/Float(numDays)*interestRate*amount
                    let newincome = Income()
                    newincome.id = obj.id
                    //Tạo income
                    try! realm.write{
                         newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)
                    }
                    
                    nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                    if srcAcc?.type == 0{
                        try! realm.write {
                           srcAcc?.cashAcc?.income(amount: finalInterest)
                            obj.savingAcc!.nextTermDate = nextTerm
                            realm.add(newincome)
                        }
                    }
                    else{
                        try! realm.write {
                           srcAcc?.bankingAcc?.income(amount: finalInterest)
                            obj.savingAcc!.nextTermDate = nextTerm
                            realm.add(newincome)
                        }
                    }
                    }
                }
                else{
                    while(Date() >= nextTerm){
                    let finalInterest = Float(termDays)/Float(numDays)*interestRate*amount
                    let newincome = Income()
                    newincome.id = obj.id
                    //Tạo income
                    try! realm.write{
                        newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)
                    }
                    newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)
                    nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                    if srcAcc?.type == 0{
                        try! realm.write {
                           srcAcc?.cashAcc?.income(amount: finalInterest)
                            obj.savingAcc!.nextTermDate = nextTerm
                            realm.add(newincome)
                        }
                    }
                    else{
                        try! realm.write {
                           srcAcc?.bankingAcc?.income(amount: finalInterest)
                            obj.savingAcc!.nextTermDate = nextTerm
                            realm.add(newincome)
                        }
                    }
                    }
                }
                
                

            }
           
        }
    }
    }

 }
class Notice{
    func showAlert(content: String){
        let timer = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 3.0, timeoutAction: {})
       let appearance = SCLAlertView.SCLAppearance(
           showCloseButton: false
       )
       let alertView = SCLAlertView(appearance: appearance)
       alertView.showWarning("", subTitle: content,timeout: timer)
    }
}
