//
//  addExpenseOrIncomeVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import SearchTextField
import DropDown
import RealmSwift
import SCLAlertView


class addExpenseOrIncomeVC: UITableViewController,selectCategoryDelegate,selectAccountDelegate,settingDelegate,delteImageDelegate {
    
    
    @IBOutlet weak var AmountL: UILabel!
    
    var type = 0
    var category = -1
    var detailCategory = -1
    
    let realm = try! Realm()
    var tempRecord : polyRecord? = nil
    var userInfor: User? = nil

    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    func changedHideAmountValue(value: Bool) {
        amount.isSecureTextEntry = value
    }
    func changedCurrency(value: Int) {
        unit.text = currencyBase().symbol[value]
    }
    var srcAccount: polyAccount? = nil
    
    @IBOutlet weak var amount: UITextField!
    
    @IBOutlet weak var chooseTypeRecordBtn: UIButton!
    
    @IBOutlet weak var categoryLogo: UIImageView!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    
    @IBOutlet weak var dateTime: UIDatePicker!
    
    @IBOutlet weak var unit: UILabel!
        
    @IBOutlet weak var chooseAccountBtn: UIButton!
    
    @IBOutlet weak var personTF: SearchTextField!
    
    @IBOutlet weak var locationTF: SearchTextField!
    
    @IBOutlet weak var eventTF: SearchTextField!
    
    @IBOutlet weak var descript: UITextField!
    
    @IBOutlet weak var chooseImageBtn: UIButton!
    
    @IBOutlet weak var imgView: UIImageView!
    var imgURL: NSURL? = nil
    
    //    var imagePicker = UIImagePickerController()
    private lazy var imagePicker: ImagePicker = {
            let imagePicker = ImagePicker()
            imagePicker.delegate = self
            return imagePicker
        }()

    let dropDown = DropDown()
    
    @IBAction func clickChooseImg(_ sender: Any) {
        imagePicker.photoGalleryAsscessRequest()
    }
    func setUp()
    {
        amount.isSecureTextEntry = userInfor!.isHideAmount
        settingObser = settingObserver(object: setting!)
        unit.text = currencyBase().symbol[userInfor!.currency]
    }
    func setLanguage(){
     }
    func loadData() {
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
            personTF.placeholder = "Payer"
        }
        userInfor = realm.objects(User.self)[0]
        setting = settingObserve(user: userInfor!)
        setting?.delegate = self
        setUp()
        
        var temp :[String] = []
        temp.append(contentsOf: userInfor!.persons)
        personTF.filterStrings(temp)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        temp = []
        temp.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(temp)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        temp = []
        temp.append(contentsOf: userInfor!.events)
        eventTF.filterStrings(temp)
        eventTF.theme.font = UIFont.systemFont(ofSize: 15)
        eventTF.maxNumberOfResults = 5
    }
    func didSelectAccount(temp: polyAccount, name: String) {
        
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        return
    }
    func didSelectRepayOrCollectDebt(_type: Int,temp: polyRecord) {
        type = _type
        loadData()
         
        if(type == 0)
        {
            category = 11
            detailCategory = 2
            
            tempRecord = temp
            categoryLogo.image = UIImage(named: "category112")
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
            categoryLogo.image = UIImage(named: "income4")
            chooseCategoryBtn.setTitle("Collecting debt", for: .normal)
            
            let lend = temp.lend
            amount.text = String(lend!.remain)
            personTF.text = String(lend!.borrower)
            descript.text = "Collect debt from " + lend!.borrower
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
        if(type == 0)
        {
            categoryLogo.image = UIImage(named: "category\(section)\(row)")
            chooseCategoryBtn.setTitle(categoryValues().expense[section][row], for: .normal)
        }
        else
        {
            categoryLogo.image = UIImage(named: "income\(row)")
            chooseCategoryBtn.setTitle(categoryValues().income[section][row], for: .normal)
        }
    }
    @IBAction func clickSave(_ sender: Any) {
        if Float(amount.text ?? "0") == 0 || amount.text == ""
        {
            print("You have to enter amount!")
            SCLAlertView().showError("Amount must be nonzero!", subTitle: "")
            return
        }
        if category == -1
        {
            print("You have to choose category of record!")
            SCLAlertView().showError("You have to choose category of record!", subTitle: "")
            return
        }
        if srcAccount == nil
        {
            print("You have to choose source account")
            SCLAlertView().showError("You have to choose source account!", subTitle: "")
            return
        }
        //create
        var tempAmount = (amount.text! as NSString).floatValue
        if userInfor?.currency != 0
        {
            tempAmount = tempAmount / Float(currencyBase().valueBaseDolar[userInfor!.currency])
        }
        try! realm.write{
            var imgStored: imgClass? = nil
            if imgURL != nil{
                if let imgData = NSData(contentsOf: imgURL! as URL) {
                    imgStored = imgClass()
//                    imgStored!.url = try! String(contentsOf: imgURL! as URL)
                    imgStored!.data = imgData
                    realm.add(imgStored!)
                }
            }
            if type == 0
            {
                //create and do transaction
                let temp = Expense()
                temp.getData(_amount: tempAmount, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: imgStored,_date: dateTime.date, _category: category, _detailCategory: detailCategory, _borrowRecord: tempRecord)
                let temp1 = polyRecord()
                    temp1.expense = temp
                    temp1.type = 0
    //            temp1.isChanged = true
                realm.add(temp1)
                userInfor?.records.append(temp1)
            }
            else
            {
                    let temp = Income()
                temp.getData(_amount: tempAmount, _type: type, _descript: descript.text!, _srcAccount: srcAccount!, _person: personTF.text ?? "", _location: locationTF.text ?? "", _event: eventTF.text ?? "", _srcImg: imgStored , _date: dateTime.date, _category: detailCategory,_lendRecord: tempRecord)
                    let temp1 = polyRecord()
                        temp1.income = temp
                        temp1.type = 1
    //                    temp1.isChanged = true
                    realm.add(temp1)
                    userInfor?.records.append(temp1)
            }
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
            tempStr = eventTF.text ?? ""
            if tempStr.isEmpty == false && userInfor?.events.contains(tempStr) == false
            {
                userInfor?.events.append(tempStr)
            }
        }
        print(realm.configuration.fileURL!)
        SCLAlertView().showSuccess("Transaction added!", subTitle: descript.text ?? "")
        //reset vc
        guard var viewcontrollers = self.navigationController?.viewControllers else { return }
        if viewcontrollers.count == 1
        {
        let dest = self.storyboard?.instantiateViewController(identifier: "addExpenseOrIncomeVC") as! addExpenseOrIncomeVC
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
    @IBAction func chooseCategory(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectCategoryVC") as! selectCategoryVC
        dest.getData(section: self.category, row: self.detailCategory,_type: self.type,_delegate: self)
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    @IBAction func chooseAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
//    var documentsUrl: URL {
//        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    }
//    private func saveImg(image: UIImage) -> String? {
//        let fileName = "Asim_recordImg"
//        let fileURL = documentsUrl.appendingPathComponent(fileName)
//        if let imageData = image.jpegData(compressionQuality: 1.0) {
//           try? imageData.write(to: fileURL, options: .atomic)
//           return fileName // ----> Save fileName
//        }
//        print("Error saving image")
//        return nil
//    }
    
    @IBAction func chooseType(_ sender: UIButton) {
        let dropDown = DropDown()
        // The view to which the drop down will appear on
        dropDown.anchorView = sender // UIView or UIBarButtonItem
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = categoryValues().typeRecord
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
                    self!.category = -1
                    self!.detailCategory = -1
                    self?.chooseCategoryBtn.setTitle("Select category", for: .normal)
                    self!.categoryLogo.image = UIImage(systemName: "archivebox")
//                    self!.imgURL = nil
//                    self!.imgView.image = UIImage(systemName: "film")
                    self?.descript.text = ""
                    self!.type = index
                    if index == 0
                    {
                        self?.amount.textColor = UIColor.red
                        self?.personTF.placeholder = "Payee"
                    }
                    else
                    {
                        self?.amount.textColor = UIColor.green
                        self?.personTF.placeholder = "Payer"
                    }
                    
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
                case 5:
                    guard var viewcontrollers = self?.navigationController?.viewControllers else { return }
                    let dest = self?.storyboard?.instantiateViewController(identifier: "addAdjustmentVC") as! addAdjustmentVC
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
    override func viewDidLoad() {
       setLanguage()
        loadData()
        chooseTypeRecordBtn.semanticContentAttribute = .forceRightToLeft
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let reviewImg = UITapGestureRecognizer(target: self, action: #selector(clickImg))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(reviewImg)
        
        super.viewDidLoad()
    }
    @objc func clickImg() {
        print("Imageview Clicked")
        if imgURL == nil
        {
            return
        }
        let dest = self.storyboard?.instantiateViewController(identifier: "previewImgVC") as! previewImgVC
        dest.delegate = self
        self.present(dest, animated: true, completion: nil)
        dest.img.image = imgView.image
    }
    func didDeletedImage() {
        imgURL = nil
        imgView.image = UIImage(systemName: "film")
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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

}

extension addExpenseOrIncomeVC: ImagePickerDelegate{
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
