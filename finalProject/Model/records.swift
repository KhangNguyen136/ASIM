//
//  records.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/20/21.
//

import Foundation
import RealmSwift

class Record : Object {
    @objc dynamic var id: Int = 0

    @objc dynamic var amount: Float = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var descript: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var location: String = ""
    @objc dynamic var img: imgClass? = nil

    @objc dynamic var srcAccount: polyAccount? = nil
        
    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_location: String,_srcImg: imgClass?, _date: Date ) {
        
        amount = _amount
        type = _type
        descript = _descript
        srcAccount = _srcAccount
        location = _location
        date = _date
        img = _srcImg
    }
 
}

class Expense: Record{
    
    @objc dynamic var category: Int = -1
    @objc dynamic var detailCategory: Int = -1
    @objc dynamic var payee: String = ""
    @objc dynamic var event: String = ""
    @objc dynamic var borrowRecord: polyRecord? = nil


    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_event: String,_srcImg: imgClass?,_date: Date, _category: Int, _detailCategory: Int,_borrowRecord: polyRecord?)
    {
        
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg, _date: _date)
        event = _event
        payee = _person
        category = _category
        detailCategory = _detailCategory
        borrowRecord = _borrowRecord
        doTransaction()

    }

    func updateData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_event: String,_srcImg: imgClass?,_date: Date, _category: Int, _detailCategory: Int,_borrowRecord: polyRecord?)
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
    func add(){
        let realm = try! Realm()
        let record = polyRecord()
        record.type = 0
        record.expense = self
        try! realm.write{
            realm.add(self)
            realm.add(record)
            realm.objects(User.self)[0].records.append(record)
        }
    }
}

class Income: Record{
    @objc dynamic var category: Int = -1
    @objc dynamic var payer: String = ""
    @objc dynamic var event: String = ""
    @objc dynamic var lendRecord: polyRecord? = nil


    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_event: String,_srcImg: imgClass?,_date: Date, _category: Int,_lendRecord: polyRecord?)
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
            realm.objects(User.self)[0].records.append(record)
        }
    }
}

class Borrow: Record{
    @objc dynamic var remain: Float = 0
    @objc dynamic var over: Float = 0
    @objc dynamic var repaymentDate: Date? = nil
    @objc dynamic var isRepayed: Bool = false
    @objc dynamic var lender: String = ""

    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: imgClass?,_date: Date, _repaymentDate: Date?, _isRepayed: Bool)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg,_date: _date )
        remain = _amount
        lender = _person
        repaymentDate = _repaymentDate
        isRepayed = _isRepayed
        doTransaction()
    }
    func updateBorrow(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: imgClass?,_date: Date, _repaymentDate: Date?)
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
    func add(){
        let realm = try! Realm()
        let record = polyRecord()
        record.type = 2
        record.borrow = self
        try! realm.write{
            realm.add(self)
            realm.add(record)
            realm.objects(User.self)[0].records.append(record)
        }
    }
}

class Lend: Record{
    @objc dynamic var remain: Float = 0
    @objc dynamic var over: Float = 0
    @objc dynamic var collectionDate: Date? = nil
    @objc dynamic var isCollected: Bool = false
    @objc dynamic var borrower: String = ""

    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: imgClass?,_date: Date, _collectionDate: Date?,_isCollected: Bool)
    {
        super.getData(_amount: _amount, _type: _type, _descript: _descript, _srcAccount: _srcAccount, _location: _location, _srcImg: _srcImg,_date: _date)
        
        remain = _amount
        borrower = _person
        collectionDate = _collectionDate
        isCollected = _isCollected
        doTransaction()
    }
    func updateLend(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_person: String,_location: String,_srcImg: imgClass?,_date: Date, _collectionDate: Date?) {
        
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
    func add(){
        let realm = try! Realm()
        let record = polyRecord()
        record.type = 3
        record.lend = self
        try! realm.write{
            realm.add(self)
            realm.add(record)
            realm.objects(User.self)[0].records.append(record)
        }
    }
}

class Transfer: Record{
    @objc dynamic var destinationAccount: polyAccount? = nil
    @objc dynamic var transferFee: polyRecord? = nil
    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_location: String,_srcImg: imgClass?,_date: Date,_destAccount: polyAccount, _transferFee: polyRecord?)
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
            realm.objects(User.self)[0].records.append(record)
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

    func getData(_amount: Float,_type: Int,_descript: String,_srcAccount: polyAccount,_location: String,_srcImg: imgClass?,_date: Date, _subType: Int,_different: Float, _category: Int, _detailCategory: Int, _tempRecord: polyRecord?,_person: String)
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
    func add(){
        let realm = try! Realm()
        let record = polyRecord()
        record.type = 5
        record.adjustment = self
        try! realm.write{
            realm.add(self)
            realm.add(record)
            realm.objects(User.self)[0].records.append(record)
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

    func del(){
        //marked if account had been uploaded
        if isUploaded == true
        {
            isDeleted = true
            //delete infor with this account
            return
        }
        let realm = try! Realm()
        switch self.type {
        case 0:
            try! realm.write{
                realm.delete(self.expense!)
                realm.delete(self)
            }
        case 1:
        try! realm.write{
            realm.delete(self.income!)
            realm.delete(self)
        }
        case 2:
        try! realm.write{
            realm.delete(self.borrow!)
            realm.delete(self)
        }
        case 3:
        try! realm.write{
            realm.delete(self.lend!)
            realm.delete(self)
        }
        case 4:
            try! realm.write{
                realm.delete(self.transfer!)
                realm.delete(self)
            }
        default:
        try! realm.write{
            realm.delete(self.adjustment!)
            realm.delete(self)
            }
        }
    }
    func srcAccount() -> polyAccount{
        switch type {
        case 0:
            return expense!.srcAccount!
        case 1:
            return income!.srcAccount!
        case 2:
            return lend!.srcAccount!
        case 3:
            return borrow!.srcAccount!
        case 4:
            return transfer!.srcAccount!
        default:
            return adjustment!.srcAccount!
        }
    }
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
    func getImgID() -> Int {
        switch type {
        case 0:
            return expense!.img?.id ?? -1
        case 1:
            return income!.img?.id ?? -1
        case 2:
            return lend!.img?.id ?? -1
        case 3:
            return borrow!.img?.id ?? -1
        case 4:
            return transfer!.img?.id ?? -1
        default:
            return adjustment!.img?.id ?? -1
        }
        return 0
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
    func getDate() -> Date{
        switch type {
        case 0:
            return expense!.date
        case 1:
            return income!.date
        case 2:
            return lend!.date
        case 3:
            return borrow!.date
        case 4:
            return transfer!.date
        default:
            return adjustment!.date
        }
    }
}
