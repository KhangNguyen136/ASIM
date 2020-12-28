//
//  File.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/26/20.
//

import Foundation
import RealmSwift

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
    let typeRecord = ["Expense", "Income", "Lend","Borrow","Transaction","Adjustment"]
    
}
class User: Object{
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var fbLink: String = ""
    @objc dynamic var numberPhone: String = ""
    @objc dynamic var birthDay: Date = Date()
    
    var records = List<polyRecord>()
    var accounts = List<polyAccount>()
    
    var persons = List<String>()
    var locations = List<String>()
    var events = List<String>()
    
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
    
    func doTransaction() -> Void {
        print("Do transaction of expense with \(amount), category: \(categoryValues().expense[category][detailCategory])")
        srcAccount?.expense(_amount: amount)
        //repay if there's an borrow record
        if borrowRecord != nil
        {
            borrowRecord?.borrow?.repay(_amount: amount)
        }
    }
    func undoTransaction() -> Void {
        print("Undo transaction of expense with \(amount), category: \(categoryValues().expense[category][detailCategory])")
        srcAccount?.income(_amount: amount)
        if borrowRecord != nil
        {
            borrowRecord?.borrow?.undoRepay(_amount: amount)
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
        // collect debt if there is an lend record
        if lendRecord != nil
            {
            lendRecord?.lend?.collect(_amount: amount)
            }
    }
    func undoTransaction() -> Void {
        print("Undo transaction of income with \(amount), category: \(categoryValues().income[0][category])")
        srcAccount?.expense(_amount: amount)
        if lendRecord != nil
            {
            lendRecord?.lend?.undoCollect(_amount: amount)
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
    }
    func undoTransaction() -> Void {
        print("Undo transaction of borrow with \(amount)")
        srcAccount?.expense(_amount: amount)
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
    }
    func undoTransaction() -> Void {
        print("Undo transaction of lend with...")
        srcAccount?.income(_amount: amount)
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
    }
    func doTransaction() -> Void {
        print("Do transaction of transfer with...")
        srcAccount?.expense(_amount: amount)
        destinationAccount?.income(_amount: amount)

    }
    func undoTransaction() -> Void {
        print("Undo transaction of transfer with...")
        srcAccount?.income(_amount: amount)
        destinationAccount?.expense(_amount: amount)
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
            }
            else
            {
                tempRecord?.lend?.collect(_amount: different)
            }
        }
        if subType == 0
        {
            srcAccount?.expense(_amount: different)
        }
        else
        {
            srcAccount?.income(_amount: different)
        }
    }
    func undoTransaction() -> Void {
        print("Undo transaction of adjustment with...")
        if tempRecord != nil
        {
            if subType == 0
            {
                tempRecord?.borrow?.undoRepay(_amount: different)
            }
            else
            {
                tempRecord?.lend?.undoCollect(_amount: different)
            }
        }
        if subType == 0
        {
            srcAccount?.income(_amount: different)
        }
        else
        {
            srcAccount?.expense(_amount: different)
        }
    }
    
}

class polyRecord: Object{
    @objc dynamic var expense: Expense? = nil
    @objc dynamic var income: Income? = nil
    @objc dynamic var borrow: Borrow? = nil
    @objc dynamic var lend: Lend? = nil
    @objc dynamic var transfer: Transfer? = nil
    @objc dynamic var adjustment: Adjustment? = nil
    @objc dynamic var type : Int = -1
    @objc dynamic var isUploaded : Bool = false
}
class Account: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var balance: Float = 0
    @objc dynamic var descrip: String = ""
    @objc dynamic var includeReport: Bool = false
    @objc dynamic var currency: String = ""
    @objc dynamic var active: Bool = true
    override static func primaryKey() -> String? {
        return "name"
    }
    func income(amount: Float)
    {
        balance += amount
    }
    func expense(amount: Float)
    {
        balance -= amount
    }
    
}
class BankingAccount:Account {
    
     @objc dynamic var bankName: String = ""
     @objc dynamic var bankImg: String = ""

}

class polyAccount: Object{
    @objc dynamic var cashAcc: Account? = nil
    @objc dynamic var bankingAcc: BankingAccount? = nil
    @objc dynamic var type : Int = -1
    @objc dynamic var isUploaded : Bool = false

    func getname() -> String{
        if type == 1{
            return cashAcc!.name
        }
        else
        {
            return bankingAcc!.name
        }
    }
    func getBalance() -> Float{
        if type == 1{
            return cashAcc!.balance
        }
        else
        {
            return bankingAcc!.balance
        }
    }
    func income(_amount: Float)
    {
        if type == 1{
            cashAcc?.income(amount: _amount)
        }
        else
        {
            bankingAcc?.income(amount: _amount)
        }
    }
    func expense(_amount: Float)
    {
        if type == 1{
            cashAcc?.expense(amount: _amount)
        }
        else
        {
            bankingAcc?.expense(amount: _amount)
        }
    }
}
class Accumulate: Object{
    @objc dynamic var goal: String = ""
    @objc dynamic var balance: Float = 0
    @objc dynamic var addbalance: Float = 0
    @objc dynamic var includeReport: Bool = true
    @objc dynamic var currency: String = ""
    @objc dynamic var startdate: Date = Date()
    @objc dynamic var enddate: Date = Date()

}
