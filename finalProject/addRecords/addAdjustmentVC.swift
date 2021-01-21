//
//  addAdjustmentVCn.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import DropDown
import RealmSwift
import SearchTextField
import SCLAlertView

class addAdjustmentVC: UITableViewController,selectAccountDelegate,selectCategoryDelegate, settingDelegate {
    
    let realm = try! Realm()
    var userInfor: User? = nil
    var srcAccount: polyAccount? = nil
    var tempRecord: polyRecord? = nil
    var _acttualBalance: Float = 0
    var _currentBalance: Float = 0
    var _different: Float = 0

    var type = 5
    var subtype = -1
    var category = -1
    var detailCategory = -1
    
    @IBOutlet weak var selectTypeRecord: UIButton!
    @IBOutlet weak var chooseAccountBtn: UIButton!
    @IBOutlet weak var categoryLogo: UIImageView!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var locationTF: SearchTextField!
    @IBOutlet weak var acctualBalance: UITextField!
    @IBOutlet weak var currentBalance: UILabel!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var different: UILabel!
    @IBOutlet weak var subTypeTitle: UILabel!
    
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var unit1: UILabel!
    @IBOutlet weak var unit2: UILabel!
    @IBOutlet weak var personTF: SearchTextField!
    
    func didSelectRepayOrCollectDebt(_type: Int, temp: polyRecord) {
        tempRecord = temp
        if(_type == 0)
        {
            category = 11
            detailCategory = 2
            
            tempRecord = temp
            categoryLogo.image = UIImage(named: "category112")
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
            categoryLogo.image = UIImage(named: "income4")
            chooseCategoryBtn.setTitle("Collecting debt", for: .normal)
            
            let lend = temp.lend
            descript.text = "Collect debt from " + lend!.borrower
            personTF.text = lend?.borrower
        }
    }

    func didSelectCategory(section: Int, row: Int) {
        if tempRecord != nil
        {
            tempRecord = nil
            descript.text = ""
            personTF.text = ""
        }
        if section == category && row == detailCategory
        {
        return
        }
        category = section
        detailCategory = row

        if subtype == 0
        {
            categoryLogo.image = UIImage(named: "category\(section)\(row)")
            chooseCategoryBtn.setTitle(categoryValues().expense[category][detailCategory], for: .normal)
        }
        else
        {
            categoryLogo.image = UIImage(named: "income\(row)")
            chooseCategoryBtn.setTitle(categoryValues().income[0][detailCategory], for: .normal)
        }
        

    }
    
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        _currentBalance = (srcAccount?.getBalance())!
        if currency != 0
        {
            _currentBalance = _currentBalance * Float(currencyBase().valueBaseDolar[currency])
        }
        currentBalance.text = String(_currentBalance)
        changedAcctualBalance(UIButton())
    }
    
    var currency = 0
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    func changedHideAmountValue(value: Bool) {
        acctualBalance.isSecureTextEntry = value
    }
    func changedCurrency(value: Int) {
        if value == currency{
            return
        }
        currency = value
        unit.text = currencyBase().symbol[value]
        unit1.text = currencyBase().symbol[value]
        unit2.text = currencyBase().symbol[value]

        if srcAccount != nil
        {
        didSelectAccount(temp: srcAccount!, name: srcAccount!.getname())
        }
        
    }
    override func viewDidLoad() {
        userInfor = realm.objects(User.self)[0]
        
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        acctualBalance.isSecureTextEntry = userInfor!.isHideAmount
        unit.text = currencyBase().symbol[userInfor!.currency]
        unit1.text = currencyBase().symbol[userInfor!.currency]
        unit2.text = currencyBase().symbol[userInfor!.currency]
        
        currency = userInfor!.currency
        
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
        
        selectTypeRecord.semanticContentAttribute = .forceRightToLeft
        selectTypeRecord.clipsToBounds = true
        selectTypeRecord.backgroundColor = .white
        selectTypeRecord.layer.cornerRadius = selectTypeRecord.frame.width/10
        
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
    @IBAction func chooseAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    @IBAction func chooseCategory(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.getData(section: self.category, row: self.detailCategory,_type: self.subtype,_delegate: self)
    self.navigationController?.pushViewController(dest, animated: false)
    }
    @IBAction func chooseTypeRecord(_ sender: UIButton) {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = sender // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        let lang = realm.objects(User.self).first?.isVietnamese
        if lang == true{
            dropDown.dataSource = categoryValues().typeRecordVietnamese
        }
        else{
             dropDown.dataSource = categoryValues().typeRecord
        }

        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)

        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? typeRecord else { return }

           // Setup your custom UI components
           cell.logo.image = UIImage(named: "typeRecord\(index)")
        }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            if index != self?.type
            {
                switch index {
                case 0,1:
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }
                    let dest = self?.storyboard?.instantiateViewController(identifier: "addExpenseOrIncomeVC") as! addExpenseOrIncomeVC

                    _ = viewcontrollers.popLast()
                    viewcontrollers.append(dest)
                    dest.type = index
                    self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
                case 2,3:
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }
                    let dest = self?.storyboard?.instantiateViewController(identifier: "addLendOrBorrowVC") as! addLendOrBorrowVC

                    _ = viewcontrollers.popLast()
                    viewcontrollers.append(dest)
                    dest.type = index
                    self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
                
                case 4:
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }

                    let dest = self?.storyboard?.instantiateViewController(identifier: "addTransferVc") as! addTransferVc

                    _ = viewcontrollers.popLast()
                    viewcontrollers.append(dest)
//                    dest.type = index
                    self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
                default:
                    return
                }
            }
            
        }
        dropDown.show()
    }
    @IBAction func changedAcctualBalance(_ sender: Any) {
        _acttualBalance = (acctualBalance.text! as NSString).floatValue
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
                categoryLogo.image = UIImage(systemName: "archivebox")
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                personTF.placeholder = "Payee"
                descript.text = ""
                subtype = 1
            }
            _different = _acttualBalance - _currentBalance
            different.text = String(_different)
            different.textColor = UIColor.green
            subTypeTitle.text = "Income"
        }
        else{
            if subtype != 0
            {
                category = -1
                detailCategory = -1
                categoryLogo.image = UIImage(systemName: "archivebox")
                chooseCategoryBtn.setTitle("Select category", for: .normal)
                personTF.placeholder = "Payer"
                descript.text = ""
                subtype = 0
            }
            _different = _currentBalance - _acttualBalance
            different.text = String(_different)
            different.textColor = UIColor.red
            subTypeTitle.text = "Expense"
        }
    }
    @IBAction func clickSaveRecord(_ sender: Any) {
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            SCLAlertView().showError("You have to choose source account!", subTitle: "")
            return
        }
        if _different == 0
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
        //create
        let temp = Adjustment()
        if currency != 0
        {
            _acttualBalance = _acttualBalance / Float(currencyBase().valueBaseDolar[currency])
            _different = _different / Float(currencyBase().valueBaseDolar[currency])
        }
        try! realm.write{
            var imgStored: imgClass? = nil
            if imgURL != nil{
                if let imgData = NSData(contentsOf: imgURL! as URL) {
                    imgStored = imgClass()
                    imgStored!.data = imgData
//                    imgStored!.url = try! String(contentsOf: imgURL! as URL)
                    realm.add(imgStored!)
                }
            }
            temp.getData(_amount: _acttualBalance, _type: type, _descript: descript.text ?? "", _srcAccount: srcAccount!, _location: locationTF.text ?? "", _srcImg: imgStored,_date: dateTime.date,_subType: subtype, _different: _different,_category: category,_detailCategory: detailCategory,_tempRecord: tempRecord,_person: personTF.text ?? "")
        let temp1 = polyRecord()
            temp1.adjustment = temp
            temp1.type = 5
//            temp1.isChanged = true
        realm.add(temp1)
        userInfor?.records.append(temp1)
        var tempStr = locationTF.text ?? ""
        if tempStr.isEmpty == false && userInfor?.locations.contains(tempStr) == false
        {
        userInfor?.locations.append(tempStr)
        }
        tempStr = personTF.text ?? ""
        if tempStr.isEmpty == false && userInfor?.persons.contains(tempStr) == false
        {
            userInfor?.persons.append(tempStr)
            }
        }
        
        SCLAlertView().showSuccess("Transaction added!", subTitle: descript.text ?? "")
        //reset view
        guard var viewcontrollers = self.navigationController?.viewControllers else { return }
        if viewcontrollers.count == 1
        {
        let dest = self.storyboard?.instantiateViewController(identifier: "addAdjustmentVC") as! addAdjustmentVC

        _ = viewcontrollers.popLast()
        viewcontrollers.append(dest)
        dest.type = type
        self.navigationController?.setViewControllers(viewcontrollers, animated: false)
        }
        else
        {
            self.navigationController?.popViewController(animated: false)
        }
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
    var imgURL: NSURL? = nil
    @IBOutlet weak var imgView: UIImageView!
    @IBAction func chooseImg(_ sender: Any) {
        imagePicker.photoGalleryAsscessRequest()
    }
    @objc func clickImg() {
        if imgURL == nil
        {
            return
        }
        let dest = self.storyboard?.instantiateViewController(identifier: "previewImgVC") as! previewImgVC
        dest.delegate = self
        self.present(dest, animated: true, completion: nil)
        dest.img.image = imgView.image
    }
    
}

extension addAdjustmentVC: ImagePickerDelegate{
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage,url: NSURL) {
        if url == imgURL
        {
            imagePicker.dismiss()
            return
        }
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
extension addAdjustmentVC: delteImageDelegate{
    func didDeletedImage() {
        imgURL = nil
        imgView.image = UIImage(systemName: "film")
    }
}
