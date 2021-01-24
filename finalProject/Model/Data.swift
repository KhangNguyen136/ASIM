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
struct Interest{
    let interestPaidEnglish = ["Maturity","Up-front"]
    let interestPaidVietnamese = ["Cuối kì","Đầu kì"]
    let termEndedEnglish = ["Rollover principal and interest", "Rollover principal", "Close account"]
    let termEndedVietnamese = ["Tiếp tục lãi và gốc", "Tiếp tục gốc", "Tất toán sổ"]
}
struct infoChoice{
    let typeAccountEnglish = ["Cash","Banking Account"]
    let typeAccountVietnamese = ["Tiền mặt","Tài khoản ngân hàng"]
    let abbrName = ["ACB", "TPBank","DAB","SeABank","ABBANK","BacABank","VietCapitalBank","MSB","TCB","KienLongBank","Nam A Bank","NCB","VPBank","HDBank","OCB","MB","PVcombank","VIB","SCB","SGB","SHB","STB","VAB","BVB","VietBank","PG Bank","EIB","LPB","VCB","CTG","BIDV","NHCSXH/VBSP","VDB","CB","Oceanbank","GPBank","Agribank"]
    let bankName = ["Ngân hàng Á Châu","Ngân hàng Tiên Phong","Ngân hàng Đông Á","Ngân hàng Đông Nam Á","Ngân hàng An Bình","Ngân hàng Bắc Á","Ngân hàng Bản Việt","Hàng Hải Việt Nam","Kỹ Thương Việt Nam","Kiên Long","Nam Á","Quốc Dân","Việt Nam Thịnh Vượng","Phát triển nhà Thành phố Hồ Chí Minh","Phương Đông","Quân đội","Đại chúng","Quốc tế","Sài Gòn","Sài Gòn Công Thương","Sài Gòn-Hà Nội","Sài Gòn Thương Tín","Việt Á","Bảo Việt","Việt Nam Thương Tín","Xăng dầu Petrolimex","Xuất Nhập khẩu Việt Nam","Bưu điện Liên Việt","Ngoại thương Việt Nam","Công Thương Việt Nam","Đầu tư và Phát triển Việt Nam","Ngân hàng Chính sách xã hội","Ngân hàng Phát triển Việt Nam","Ngân hàng Xây dựng","Ngân hàng Đại Dương","Ngân hàng Dầu Khí Toàn Cầu","Ngân hàng Nông nghiệp và Phát triển Nông thôn VN"]
    let bankImg = ["bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank"]
    let howLongEnglish = ["1 month", "3 months", "6 months","1 year","2 years","5 years", "10 years", "other"]
    let howLongVietnamses = ["1 tháng", "3 tháng", "6 tháng","1 năm","2 năm","5 năm", "10 năm", "khác"]

    let termEnglish = ["1 week","2 weeks", "3 weeks","1 month", "3 months", "6 months","12 months"]
    let termVietnamese = ["1 tuần","2 tuần", "3 tuần","1 tháng", "3 tháng", "6 tháng","12 tháng"]
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
    let typeRecordVietnamese = ["Khoản chi", "Thu nhập", "Mượn tiền","Cho mượn tiền","Chuyển khoản","Điều chỉnh số dư"]
    
}
class Notify: Object{
    @objc dynamic var type: Int = 0
    @objc dynamic var content: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date = Date()
    func add(){
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
    realm.objects(User.self)[0].notifyList.append(self)
        }
    }
    func del(){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
   func getData(_type: Int,_content: String,_title: String,_date: Date ) {
           
           type = _type
           content = _content
            title = _title
           date = _date
       }
    func showAll(){
           let realm = try! Realm()
        let uptodate = realm.objects(Notify.self)
        for obj in uptodate{
            if obj.date <= Date(){
                SCLAlertView().showInfo(obj.title, subTitle: obj.content)
                obj.del()
            }
            
        }
        let lend = Array(realm.objects(polyRecord.self).filter("type = 2"))
        for obj in lend{
            if obj.lend!.collectionDate != nil{
                if obj.lend!.collectionDate! <= Date(){
                    SCLAlertView().showInfo("Thu nợ", subTitle: obj.lend!.descript)
                }
            }
        }
        let borrow = Array(realm.objects(polyRecord.self).filter("type = 3"))
        for obj in borrow{
            if obj.borrow?.repaymentDate != nil{
                if obj.borrow!.repaymentDate! <= Date(){
                    SCLAlertView().showInfo("Trả nợ", subTitle: obj.borrow?.descript ?? "")
                }
            }
        }
       }
    
    
}



class Account: Object{
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var balance: Float = 0
    @objc dynamic var descrip: String = ""
    @objc dynamic var includeReport: Bool = false
    @objc dynamic var currency: Int = 0
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
    @objc dynamic var bank: Int = 0
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
    @objc dynamic var accumulate: Accumulate? = nil

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
        case 2:
            return savingAcc!.name
        default:
            return accumulate!.goal
        }
    }
    func getBalance() -> Float{
        switch type {
        case 0:
            return cashAcc!.balance
        case 1:
            return bankingAcc!.balance
        case 2:
            return savingAcc!.ammount
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
        try! realm?.write{
        if isUploaded == true
        {
            isDeleted = true
            //delete infor with this account
            return
        }
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
        else if type == 2 {
            try! realm.write{
                realm.delete(self.savingAcc!)
                realm.delete(self)
            }
        }
        else{
            try! realm.write{
                realm.delete(self.accumulate!)
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
    @objc dynamic var currency: Int = 0
    @objc dynamic var startdate: Date = Date()
    @objc dynamic var enddate: Date = Date()
    func add(){
        let realm = try! Realm()
        let polyAcc = polyAccount()
        polyAcc.accumulate = self
        polyAcc.id = polyAccount().incrementID()
        polyAcc.type = 3
        try! realm.write {
            realm.add(self)
            realm.add(polyAcc)
            realm.objects(User.self)[0].accounts.append(polyAcc)
        }
    }
}
class savingAccount: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var id: Int = 0
    override static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var startdate: Date = Date()
    @objc dynamic var currency: Int = 0
    @objc dynamic var bank: Int = 0
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
                        newincome.getData(_amount: finalInterest, _type: 1, _descript: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate*100) %", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: nil, _date: nextTerm, _category: 3, _lendRecord: nil)
                    }
                    let notify = Notify()
                    try! realm.write {
                        notify.getData(_type: 0, _content: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate*100) % (\(dateFormatter.string(from: nextTerm)))", _title: "Saving interest", _date: nextTerm)
                    }
                    notify.add()
                    
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
                        let notify = Notify()
                        try! realm.write {
                            notify.getData(_type: 0, _content: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate*100) % (\(dateFormatter.string(from: nextTerm)))", _title: "Saving interest", _date: nextTerm)
                        }
                        notify.add()
                     try! realm.write{
                        newincome.getData(_amount: finalInterest, _type: 1, _descript: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate*100) %", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: nil, _date: nextTerm, _category: 3, _lendRecord: nil)
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
                        let notify = Notify()
                         try! realm.write {
                             notify.getData(_type: 0, _content: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate*100) % (\(dateFormatter.string(from: nextTerm)))", _title: "Saving interest", _date: nextTerm)
                         }
                         notify.add()
                        try! realm.write{
                            newincome.getData(_amount: finalInterest, _type: 1, _descript: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate) %", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: nil, _date: nextTerm, _category: 3, _lendRecord: nil)
                            transfer.getData(_amount: obj.savingAcc!.ammount, _type: 4, _descript: "", _srcAccount: obj, _location: "", _srcImg: nil, _date: endDate, _destAccount: obj.savingAcc!.srcAccount!, _transferFee: nil)
                        }
                     if srcAcc?.type == 0{
                         try! realm.write {
                            obj.savingAcc!.state = true
                         }
                        newincome.add()
                        transfer.add()
                     }
                     else{
                         try! realm.write {
                            srcAcc?.bankingAcc?.income(amount: finalInterest)
                            obj.savingAcc!.state = true
                            
                         }
                        newincome.add()
                        transfer.add()
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
                        let notify = Notify()
                        try! realm.write {
                            notify.getData(_type: 0, _content: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate*100) % (\(dateFormatter.string(from: nextTerm)))", _title: "Saving interest", _date: nextTerm)
                        }
                        notify.add()
                         //Tạo income
                        try! realm.write{
                            newincome.getData(_amount: finalInterest, _type: 1, _descript: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate) %", _srcAccount: (obj.savingAcc?.destAccount)!, _person: "", _location: "", _event: "", _srcImg: nil, _date: nextTerm, _category: 3, _lendRecord: nil)
                        }
                         
                         nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                         if destAcc?.type == 0{
                             try! realm.write {
                                destAcc?.cashAcc?.income(amount: finalInterest)
                                 obj.savingAcc!.nextTermDate = nextTerm
                             }
                            newincome.add()
                         }
                         else{
                             try! realm.write {
                                destAcc?.bankingAcc?.income(amount: finalInterest)
                                 obj.savingAcc!.nextTermDate = nextTerm
                             }
                            newincome.add()
                         }
                         
                    }
                    while(Date() >= nextTerm)
                }
                    //close account
                else{
                    if(Date() >= nextTerm){
                  let notify = Notify()
                  try! realm.write {
                    notify.getData(_type: 0, _content: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate*100) % (\(dateFormatter.string(from: nextTerm)))", _title: "Saving interest", _date: nextTerm)
                  }
                  notify.add()
                     nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                        let transfer = Transfer()
                     if srcAcc?.type == 0{
                         try! realm.write {
                             obj.savingAcc!.nextTermDate = nextTerm
                            obj.savingAcc!.state = true
                            
                            transfer.getData(_amount: obj.savingAcc!.ammount, _type: 4, _descript: "Interest from \(obj.savingAcc?.name as! String) rate \(interestRate) %", _srcAccount: obj, _location: "", _srcImg: nil, _date: endDate, _destAccount: obj.savingAcc!.srcAccount!, _transferFee: nil)
                         }
                        transfer.add()
                     }
                     else{
                         try! realm.write {
                             obj.savingAcc!.nextTermDate = nextTerm
                            obj.savingAcc!.state = true
                            
                            transfer.getData(_amount: obj.savingAcc!.ammount, _type: 4, _descript: "", _srcAccount: obj, _location: "", _srcImg: nil, _date: endDate, _destAccount: obj.savingAcc!.srcAccount!, _transferFee: nil)
                         }
                        transfer.add()
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
                         newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: nil, _date: nextTerm, _category: 3, _lendRecord: nil)
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
                        newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: nil, _date: nextTerm, _category: 3, _lendRecord: nil)
                    }
                    newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: nil, _date: nextTerm, _category: 3, _lendRecord: nil)
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
