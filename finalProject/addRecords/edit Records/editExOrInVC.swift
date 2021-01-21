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
import ProgressHUD

class editExOrInVC: UITableViewController,selectCategoryDelegate,selectAccountDelegate,settingDelegate {
    
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
    @IBOutlet weak var categoryImg: UIImageView!
    
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
            categoryImg.image = UIImage(named: "category112")
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
            
            categoryImg.image = UIImage(named: "category4")
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
            categoryImg.image = UIImage(named: "category\(section)\(row)")
            chooseCategoryBtn.setTitle(categoryValues().expense[section][row], for: .normal)
        }
        else
        {
            categoryImg.image = UIImage(named: "income\(row)")
            chooseCategoryBtn.setTitle(categoryValues().income[section][row], for: .normal)
        }
    }
    
    func loadData()  {
        ProgressHUD.show()
        userInfor = realm.objects(User.self)[0]
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        amount.isSecureTextEntry = userInfor!.isHideAmount
        unit.text = currencyBase().symbol[userInfor!.currency]
        if type == 0
        {
            let temp = record?.expense
            amount.text = String(loadAmount(value: temp!.amount))
            descript.text = temp?.descript
            category = temp!.category
            detailCategory = temp!.detailCategory
            categoryImg.image = UIImage(named: "category\(category)\(detailCategory)")
            chooseCategoryBtn.setTitle(categoryValues().expense[category][detailCategory], for: .normal)
            personTF.text = temp?.payee
            locationTF.text = temp?.location
            eventTF.text = temp?.event
            srcAccount = temp?.srcAccount
            chooseAccountBtn.setTitle(srcAccount?.getname(), for: .normal)

            dateTime.date = temp!.date

            //get borrow record from expense if it has
            tempRecord = temp?.borrowRecord
            if temp?.img != nil
            {
                if let img = UIImage(data: temp!.img!.data! as Data)
                {
                    imgView.image = img
                    hasImg = true
                }
                else
                {
                    SCLAlertView().showError("Image error", subTitle: "Location path had changed or file had been deleted!")
                }
            }
    }
        else
        {
            let temp = record?.income
            amount.text = String(loadAmount(value: temp!.amount))
            descript.text = temp?.descript
            category = 0
            detailCategory = temp!.category
            categoryImg.image = UIImage(named: "income\(detailCategory)")
            chooseCategoryBtn.setTitle(categoryValues().income[category][detailCategory], for: .normal)
            personTF.text = temp?.payer
            locationTF.text = temp?.location
            eventTF.text = temp?.event
            srcAccount = temp?.srcAccount
            chooseAccountBtn.setTitle(srcAccount?.getname(), for: .normal)

            dateTime.date = temp!.date
            //get lend record if it has
            tempRecord = temp?.lendRecord
            if temp?.img != nil
            {
                if let img = UIImage(data: temp!.img!.data! as Data)
                {
                    imgView.image = img
                    hasImg = true
                }
                else
                {
                    SCLAlertView().showError("Image error", subTitle: "Location path had changed or file had been deleted!")
                }
            }
        }
        var tempStr : [String] = []
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
        
        ProgressHUD.dismiss()
    }
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    func changedHideAmountValue(value: Bool) {
        amount.isSecureTextEntry = value
    }
    func changedCurrency(value: Int) {
        unit.text = currencyBase().symbol[value]
        amount.text = String(loadAmount(value: ((amount.text ?? "") as NSString).floatValue))
    }
    func loadAmount(value: Float) -> Float
    {
        if userInfor?.currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[userInfor!.currency])
    }
    override func viewDidLoad() {
        type = record!.type
        
        loadData()
        let reviewImg = UITapGestureRecognizer(target: self, action: #selector(clickImg))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(reviewImg)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        super.viewDidLoad()
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        var _amount = Float(amount.text!)
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
        if userInfor!.currency != 0 {
            _amount = _amount! / Float(currencyBase().valueBaseDolar[userInfor!.currency])
        }
        try! realm.write{
            var imgStored: imgClass? = nil
            if record?.type == 0
            {
                imgStored = record?.expense?.img
            }
            else
            {
                imgStored = record?.income?.img
            }
            if imgChange == true
            {
            if imgStored == nil && hasImg == true {
                if let imgData = NSData(contentsOf: imgURL! as URL) {
                    imgStored = imgClass()
                    imgStored!.data = imgData
                    realm.add(imgStored!)
                    }
                }
                else
                {
                    if hasImg == false
                    {
                        realm.delete(imgStored!)
                        imgStored = nil
                    }
                    else
                    {
                        if let imgData = NSData(contentsOf: imgURL! as URL) {
                            imgStored!.data = imgData
                        }
                    }
                }
            }
        if type == 0
        {
            let temp = record?.expense
            if srcAccount != temp?.srcAccount || _amount != temp?.amount || detailCategory != temp?.detailCategory || category != temp?.category || dateTime.date != temp?.date || descript.text != temp?.descript || personTF.text != temp?.payee || locationTF.text != temp?.location || eventTF.text != temp?.event
            {
                //undo old-record
                temp?.undoTransaction()

                //get new data and do new transaction
                temp?.getData(_amount: _amount!, _type: type, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: imgStored, _date: dateTime.date, _category: category, _detailCategory: detailCategory, _borrowRecord: tempRecord)
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
                temp?.getData(_amount: _amount!, _type: type, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: imgStored, _date: dateTime.date, _category: detailCategory, _lendRecord: tempRecord)
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
                    if self.record?.expense?.img != nil && self.record!.expense!.img!.isUploaded == true
                    {
                        self.record!.expense!.img!.isDeleted = true
                    }
                    self.record?.expense?.undoTransaction()

                    print("Mark an expense as deleted!")
                }
                else
                {
                    if self.record?.income?.img != nil && self.record!.income!.img!.isUploaded == true
                    {
                        self.record!.income!.img!.isDeleted = true
                    }
                    self.record?.income?.undoTransaction()

                    print("Deleted ab income as deleted!")
                }
            }
            else
            {
                if self.record?.type == 0
                {
                    if self.record?.expense?.img != nil
                    {
                        self.realm.delete(self.record!.expense!.img!)
                    }
                    self.record?.expense?.undoTransaction()
                    self.realm.delete((self.record?.expense)!)

                    print("Deleted a expense!")
                }
                else
                {
                    if self.record?.income?.img != nil
                    {
                        self.realm.delete(self.record!.income!.img!)
                    }
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
    private lazy var imagePicker: ImagePicker = {
            let imagePicker = ImagePicker()
            imagePicker.delegate = self
            return imagePicker
        }()
    var hasImg = false
    var imgChange: Bool = false
    var imgURL: NSURL? = nil
    @IBOutlet weak var imgView: UIImageView!
    @IBAction func chooseImg(_ sender: Any) {
        imagePicker.photoGalleryAsscessRequest()
    }
    @objc func clickImg() {
        if hasImg == false
        {
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "previewImgVC") as! previewImgVC
        dest.delegate = self
        self.present(dest, animated: true, completion: nil)
        dest.img.image = imgView.image
    }
    
}

extension editExOrInVC: ImagePickerDelegate{
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage,url: NSURL) {
        if url == imgURL
        {
            imagePicker.dismiss()
            return
        }
        hasImg = true
        imgView.image = image
        imgURL = url
        imgChange = true
        print(url)
        imagePicker.dismiss()
        }

        func cancelButtonDidClick(on imageView: ImagePicker) {
            imagePicker.dismiss()
        }
        func imagePicker(_ imagePicker: ImagePicker, grantedAccess: Bool,
                         to sourceType: UIImagePickerController.SourceType) {
            guard grantedAccess else { return }
            imagePicker.present(parent: self, sourceType: sourceType)
        }
}
extension editExOrInVC: delteImageDelegate{
    func didDeletedImage() {
        imgURL = nil
        imgView.image = UIImage(systemName: "film")
        hasImg = false
        imgChange = true
    }
}

