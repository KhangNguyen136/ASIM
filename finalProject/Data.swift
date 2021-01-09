//
//  File.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/26/20.
//

import Foundation
import RealmSwift
import SCLAlertView

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
    @objc dynamic var isVietnamDong = false
    @objc dynamic var isHideAmount = false
    
    @objc dynamic var isChangedRecords: Bool = true
    @objc dynamic var isChangedAccounts: Bool = true
    @objc dynamic var isChangedPersons: Bool = true
    @objc dynamic var isChangedLocations: Bool = true
    @objc dynamic var isChangedEvents: Bool = true

    
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
