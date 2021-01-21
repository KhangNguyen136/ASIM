//
//  editAdjustmentVC.swift
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

class editAdjustmentVC: UITableViewController,selectAccountDelegate,selectCategoryDelegate, settingDelegate {
    func didSelectRepayOrCollectDebt(_type: Int, temp: polyRecord) {
        tempRecord = temp
        if(_type == 0)
        {
            category = 11
            detailCategory = 2
            
            tempRecord = temp
            categoryImg.image = UIImage(named: "category111")
            chooseCategoryBtn.setTitle("Repayment", for: .normal)
            let borrow = temp.borrow
            descript.text = "Repay for " + borrow!.lender
            personTF.text = borrow?.lender
        }
        else
        {
            category = 0
            detailCategory = 4
            tempRecord = temp
            categoryImg.image = UIImage(named: "income4")
            chooseCategoryBtn.setTitle("Collecting debt", for: .normal)
            let lend = temp.lend
            descript.text = "Collect debt from " + lend!.borrower
            personTF.text = lend?.borrower
        }
    }

    let realm = try! Realm()
    var userInfor: User? = nil
    var historyDelegate : editRecordDelegate? = nil
    var record: polyRecord? = nil
    var tempRecord: polyRecord? = nil
    var srcAccount: polyAccount? = nil

    var _acttualBalance: Float = 0
    var _currentBalance: Float = 0
    var _different: Float = 0
    var type = 5
    var subtype = -1
    var category = -1
    var detailCategory = -1
    
    @IBOutlet weak var subTypeTitle: UILabel!
    @IBOutlet weak var typeReccord: UIButton!
    @IBOutlet weak var chooseAccountBtn: UIButton!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var acctualBalance: UITextField!
    @IBOutlet weak var currentBalance: UILabel!
    @IBOutlet weak var different: UILabel!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var locationTF: SearchTextField!
    @IBOutlet weak var personTF: SearchTextField!

    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var unit1: UILabel!
    @IBOutlet weak var unit2: UILabel!
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    func changedHideAmountValue(value: Bool) {
        acctualBalance.isSecureTextEntry = value
    }
    func changedCurrency(value: Int) {
        unit.text = currencyBase().symbol[value]
        unit1.text = currencyBase().symbol[value]
        unit2.text = currencyBase().symbol[value]
        acctualBalance.text = String(loadAmount(value: ((acctualBalance.text ?? "") as NSString).floatValue))
        if srcAccount != nil
        {
        didSelectAccount(temp: srcAccount!, name: srcAccount!.getname())
        }
        
    }
    func loadAmount(value: Float) -> Float
    {
        if userInfor?.currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[userInfor!.currency])
    }
    func loadData()  {
        ProgressHUD.show()
        
        userInfor = realm.objects(User.self)[0]

        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        acctualBalance.isSecureTextEntry = userInfor!.isHideAmount
        unit.text = currencyBase().symbol[userInfor!.currency]
        unit1.text = currencyBase().symbol[userInfor!.currency]
        unit2.text = currencyBase().symbol[userInfor!.currency]

        if record == nil
        {
            return
        }
        let temp = record?.adjustment
        locationTF.text = temp?.location ?? ""
        personTF.text = temp?.person ?? ""
        dateTime.date = temp?.date ?? Date()
        descript.text = temp?.descript
        subtype = temp!.subType
        category = temp!.category
        detailCategory = temp!.detailCategory
        tempRecord = temp?.tempRecord
        
        
        _acttualBalance = loadAmount(value: (record?.adjustment!.amount)!)
        acctualBalance.text = String(_acttualBalance)
        
        _different = loadAmount(value: temp!.different)
        different.text = String(_different)
        
        if temp?.subType == 0
        {
            different.textColor = UIColor.red
            subTypeTitle.text = "Expense"
        }
        else
        {
            different.textColor = UIColor.green
            subTypeTitle.text = "Income"
        }
//        loadRootSrcAccount()
        didSelectAccount(temp: temp!.srcAccount!, name: temp!.srcAccount!.getname())
        print(subtype)
        print(category)
        print(detailCategory)
        if subtype == 0
        {
            categoryImg.image = UIImage(named: "category\(category)\(detailCategory)")
            chooseCategoryBtn.setTitle(categoryValues().expense[category][detailCategory], for: .normal)
        }
        else
        {
            categoryImg.image = UIImage(named: "income\(detailCategory)")
            chooseCategoryBtn.setTitle(categoryValues().income[0][detailCategory], for: .normal)
        }
        if record!.adjustment!.img != nil
        {
            if let img = UIImage(data: record!.adjustment!.img!.data! as Data)
            {
                imgView.image = img
                hasImg = true
            }
            else
            {
                SCLAlertView().showError("Image error", subTitle: "Location path had changed or file had been deleted!")
            }
        }

        
        var tempStr : [String] = []
        tempStr.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        
        tempStr = []
        tempStr.append(contentsOf: userInfor!.persons)
        personTF.filterStrings(tempStr)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        
        ProgressHUD.dismiss()
    }

    override func viewDidLoad() {
        typeReccord.clipsToBounds = true
        typeReccord.layer.cornerRadius = typeReccord.frame.width/8
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
    
    func didSelectCategory( section: Int, row: Int) {
        if section == category && row == detailCategory
        {
        return
        }
        category = section
        detailCategory = row

        if subtype == 0
        {
            categoryImg.image = UIImage(named: "category\(section)\(row)")
            chooseCategoryBtn.setTitle(categoryValues().expense[category][detailCategory], for: .normal)
        }
        else
        {
            categoryImg.image = UIImage(named: "income\(row)")
            chooseCategoryBtn.setTitle(categoryValues().income[0][detailCategory], for: .normal)
        }
    }
    func loadRootSrcAccount( )
    {
        let temp = record?.adjustment
        if temp?.subType == 0
        {
            _currentBalance = loadAmount(value: temp!.amount + temp!.different)
            currentBalance.text = String(_currentBalance)
        }
        else
        {
            _currentBalance = loadAmount(value: temp!.amount - temp!.different)
            currentBalance.text = String(_currentBalance)
        }
    }
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)

        if temp.getname() == record!.adjustment!.srcAccount!.getname()
        {
            loadRootSrcAccount()
            print("Load root acc")
        }
        else
        {
            print("Load other acc")
        _currentBalance = loadAmount(value: (srcAccount?.getBalance())!)
        currentBalance.text = String( _currentBalance)
        }
        changedAcctualBalance(UIButton())
    }
    @IBAction func chooseAccount(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func chooseCategory(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.delegate = self
        dest.type = self.subtype
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    @IBAction func changedAcctualBalance(_ sender: Any) {
        _acttualBalance = (acctualBalance.text! as NSString).floatValue
        print(_acttualBalance)
        print(_currentBalance)
        if _currentBalance == _acttualBalance
        {
        _different = 0
        different.text = "0"
        subTypeTitle.text = "Difference"
        different.textColor = UIColor.black
        subtype = -1
        }
        else if _currentBalance < _acttualBalance
            {
            if subtype != 1
            {
                category = -1
                detailCategory = -1
                categoryImg.image = UIImage(systemName: "archivebox")
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                subtype = 1
                different.textColor = UIColor.green
                subTypeTitle.text = "Income"
            }
            _different = _acttualBalance - _currentBalance
            different.text = String(_different)
        }
        else{
            if subtype != 0
            {
                category = -1
                detailCategory = -1
                categoryImg.image = UIImage(systemName: "archivebox")
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                subtype = 0
                different.textColor = UIColor.red
                subTypeTitle.text = "Expense"
            }
            _different = _currentBalance - _acttualBalance
            different.text = String(_different)
        }
    }
    
    @IBAction func clickSaveRecord(_ sender: Any) {
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            SCLAlertView().showError("You have to choose source account!", subTitle: "")
            return
        }
        if _different == 0 || subtype == -1
        {
            print("You have to enter changed amount of source account!")
            SCLAlertView().showError("Difference must be nonzero!", subTitle: "")
            return
        }

        if category == -1 || detailCategory == -1
        {
            print("You have to choose category for this action!")
            SCLAlertView().showError("You have to choose category!", subTitle: "")
            return
        }
        try! realm.write{
            var imgStored = record!.adjustment!.img
            if imgChange == true
            {
                if imgStored == nil && hasImg == true
                {
                    if imgURL != nil{
                        if let imgData = NSData(contentsOf: imgURL! as URL) {
                            imgStored = imgClass()
                            imgStored!.data = imgData
                            realm.add(imgStored!)
                        }
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

            record?.adjustment?.undoTransaction()
            if userInfor?.currency != 0
            {
                _acttualBalance = _acttualBalance / Float(currencyBase().valueBaseDolar[userInfor!.currency])
                _different = _different / Float(currencyBase().valueBaseDolar[userInfor!.currency])
            }
            record?.adjustment?.getData(_amount: _acttualBalance, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _location: locationTF.text ?? "", _srcImg: imgStored,_date: dateTime.date,_subType: subtype, _different: _different,_category: category,_detailCategory: detailCategory,_tempRecord: tempRecord,_person: personTF.text ?? "")
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
        }
        print("Update a adjustment")
        SCLAlertView().showSuccess("Transaction updated!", subTitle: record?.getDescript() ?? "")
        historyDelegate?.editedRecord()
        //pop after save
        self.navigationController?.popViewController(animated: false)
        
    
    }
    
    @IBAction func clickDelte(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let msg = SCLAlertView(appearance: appearance)
        msg.addButton("Yes", action: { [self] in
            try! self.realm.write{
                self.record?.adjustment?.undoTransaction()
                if self.record?.isUploaded == true
                {
                    if self.record?.adjustment?.img != nil
                    {
                        self.record?.adjustment?.img?.isDeleted = true
                    }
                    self.record?.isDeleted = true
                }
                    else
                {
                    if self.record?.adjustment?.img != nil
                    {
                        self.realm.delete(self.record!.adjustment!.img!)
                    }
                    self.realm.delete((self.record?.adjustment)!)
                    self.realm.delete(self.record!)

                }
        }
        
        print("Deleted a adjustment")
            SCLAlertView().showSuccess("Transaction deleted!", subTitle: "")
            self.historyDelegate?.editedRecord()
        self.navigationController?.popViewController(animated: false)
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
    private lazy var imagePicker: ImagePicker = {
            let imagePicker = ImagePicker()
            imagePicker.delegate = self
            return imagePicker
        }()
    var hasImg = false
    var imgChange = false
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

extension editAdjustmentVC: ImagePickerDelegate{
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage,url: NSURL) {
        if url == imgURL
        {
            imagePicker.dismiss()
            return
        }
        hasImg = true
        imgChange = true
        imgView.image = image
        imgURL = url
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
extension editAdjustmentVC: delteImageDelegate{
    func didDeletedImage() {
        imgURL = nil
        imgView.image = UIImage(systemName: "film")
        imgChange = true
        hasImg = false
    }
}
