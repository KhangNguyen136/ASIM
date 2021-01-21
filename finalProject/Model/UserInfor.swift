//
//  UserInfor.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/20/21.
//

import Foundation
import RealmSwift
import SCLAlertView
import FirebaseDatabase
import FirebaseStorage

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
    var notifyList = List<Notify>()

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
    func getIdImgClass() -> Int
    {
        var result = 0
        for i in records
        {
            if i.getImgID() > result
            {
                result = i.getImgID() + 1
            }
        }
        return result
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
                tempRef.child("bank").setValue(tempAcc?.bank)
                print("Synced an banking account.")
            case 2:
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
                
            default:
                print("Ignore accummulate")
                continue
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
    func reloadData(completionHandler: @escaping (_ result: Bool, _ currency: Int, _ isHide: Bool) -> Void)
    {
        var tempCurrency = -1
        var tempIsHide = false
        print("Begin reload infor...")
        let userRef = ref.child("users").child(username)
        userRef.observeSingleEvent(of: .value, with: { [self] snapshot in
            if snapshot.exists() == false
            {
                completionHandler(false,-1,false)
                return
            }
            let data = snapshot.value as? [String: Any]
            try! self.realm?.write{
                self.numberPhone = data!["numberPhone"] as! String
                self.address = data!["address"] as! String
                self.job = data!["job"] as! String
                self.birthDay = Date(timeIntervalSince1970: (data!["birthDay"] as! TimeInterval))
                self.isMale = data!["isMale"] as! Bool
            
                self.isVietnamese = data!["isVietnamese"] as! Bool
            tempCurrency = data!["currency"] as! Int
                self.defaultScreen = data!["defaultScreen"] as! Int
                self.dateFormat = data!["dateFormat"] as! String
            tempIsHide = data!["isHideAmount"] as! Bool
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
                    tempPolyAcc.bankingAcc?.currency = temp["currency"] as! Int
                    tempPolyAcc.bankingAcc?.balance = temp["balance"] as! Float
                    tempPolyAcc.bankingAcc?.active = temp["active"] as! Bool
                    tempPolyAcc.bankingAcc?.descrip = temp["descrip"] as! String
                    tempPolyAcc.bankingAcc?.bank = temp["bank"] as! Int
                    resultAccount.append(tempPolyAcc)
                    print("Reload an banking account.")
                }
                if tempPolyAcc.type == 0
                {
                    tempPolyAcc.cashAcc = Account()
                    tempPolyAcc.cashAcc?.id = temp["id"] as! Int
                    tempPolyAcc.cashAcc?.name = temp["name"] as! String
                    tempPolyAcc.cashAcc?.currency = temp["currency"] as! Int
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
                    tempPolyAcc.savingAcc?.currency = temp["currency"] as! Int
                    tempPolyAcc.savingAcc?.bank = temp["bank"] as! Int
                    tempPolyAcc.savingAcc?.term = temp["term"] as! String
                    tempPolyAcc.savingAcc?.interestRate = temp["interestRate"] as! Float
                    tempPolyAcc.savingAcc?.freeInterestRate = temp["freeInterestRate"] as! Float
                    tempPolyAcc.savingAcc?.numDays = temp["numDays"] as! Int
                    tempPolyAcc.savingAcc?.interestPaid = temp["interestPaid"] as! Int
                    tempPolyAcc.savingAcc?.termEnded = temp["termEnded"] as! Int
                    tempPolyAcc.savingAcc?.termEnded = temp["termEnded"] as! Int
                    let tempSrcAcc = temp["srcAccount"] as! Int
                    tempPolyAcc.savingAcc?.srcAccount = self.getAccountByID(id: tempSrcAcc)
                    let tempDestAcc = temp["destAccount"] as! Int
                    tempPolyAcc.savingAcc?.destAccount = self.getAccountByID(id: tempDestAcc)
                    tempPolyAcc.savingAcc?.descrip = temp["descrip"] as! String
                    tempPolyAcc.savingAcc?.includeRecord = temp["includeRecord"] as! Bool
                    tempPolyAcc.savingAcc?.ammount = temp["ammount"] as! Float
                    tempPolyAcc.savingAcc?.state = temp["state"] as! Bool
                    tempPolyAcc.savingAcc?.interest = temp["interest"] as! Float
                    resultAccount.append(tempPolyAcc)
                    print("Reload an saving account.")
                }
                try! self.realm?.write{
                    self.realm?.add(tempPolyAcc)
                    self.accounts.append(tempPolyAcc)
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
                let temp = self.findRecordByID(arr: recordsResult,id: childID[index])
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
            try! self.realm?.write{
                for i in recordsResult{
                    self.realm?.add(i)
                }
                self.records.append(objectsIn: recordsResult)
            }
            completionHandler(true,tempCurrency,tempIsHide)
        })
    }
    
    
}
