//
//  editLendOrBorrowVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/27/20.
//

import UIKit
import RealmSwift
import SearchTextField
import DatePicker
import SCLAlertView
import ProgressHUD

class editLendOrBorrowVC: UITableViewController,selectAccountDelegate, settingDelegate {
    
    var historyDelegate: editRecordDelegate? = nil
    var record: polyRecord? = nil
    var type = -1
    let realm = try! Realm()
    var userInfor: User? = nil
    var srcAccount: polyAccount? = nil
    
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var personTF: SearchTextField!
    @IBOutlet weak var locationTF: SearchTextField!
    @IBOutlet weak var chooseCategoryBtn: UIButton!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var selectTypeRecord: UIButton!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var chooseAccountBtn: UIButton!
    var reDate: Date? = nil
    @IBOutlet weak var reDateBtn: UIButton!
    @IBOutlet weak var dateTime: UIDatePicker!
    
    @IBOutlet weak var doneValue: UISwitch!
    @IBOutlet weak var doneTitle: UILabel!
        
    func didSelectAccount(temp: polyAccount, name: String) {
        srcAccount = temp
        chooseAccountBtn.setTitle(name, for: .normal)
        return
    }
    
    @IBAction func chooseReDate(_ sender: UIButton) {
        let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1990)!
                let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
                // Create picker object
                let datePicker = DatePicker()
                // Setup
                datePicker.setup(beginWith: Date(), min: minDate, max: maxDate) { (selected, date) in
                    if selected , let selectedDate = date {
                        self.reDate = selectedDate
                        sender.setTitle(selectedDate.string(), for: .normal)
                    } else {
                        print("Cancel choose redate")
                    }
                }
                // Display
                datePicker.show(in: self)
    }
    @IBAction func enterPerson(_ sender: Any) {
        if personTF.text == ""
        {
            return
        }
        if type == 2
        {
            descript.text = personTF.text! + " took out a loan"
        }
        else
        {
            descript.text = "Borrowed money from" + personTF.text!
        }
    }
    func loadData()  {
        ProgressHUD.show()
        type = record!.type
        userInfor = realm.objects(User.self)[0]

        categoryImg.image = UIImage(named: "other\(type-2)")
        chooseCategoryBtn.setTitle(categoryValues().typeRecord[type], for: .normal)
        
        selectTypeRecord.setTitle(categoryValues().typeRecord[type],for: .normal)
        selectTypeRecord.clipsToBounds = true
        selectTypeRecord.layer.cornerRadius = selectTypeRecord.frame.width/8

        chooseCategoryBtn.setTitle(categoryValues().other[0][type-2], for: .normal)
        if type == 2 {
            amount.textColor = UIColor.red
            personTF.placeholder = "Borrower"
            doneTitle.text = "Collected"
            reDateBtn.setTitle("Collecting date", for: .normal)
        }
        else
        {
            amount.textColor = UIColor.green
            personTF.placeholder = "Lender"
            doneTitle.text = "Repayed"
            reDateBtn.setTitle("Repayment date", for: .normal)
        }
        
        
        if type == 2
        {
            let temp = record?.lend
            amount.text = String(loadAmount(value: temp!.amount))
            descript.text = temp?.descript
            dateTime.date = temp!.date
            personTF.text = temp?.borrower
            locationTF.text = temp?.location
            doneValue.isOn = temp!.isCollected
            srcAccount = temp?.srcAccount
            chooseAccountBtn.setTitle(temp?.srcAccount?.getname(), for: .normal)
            if temp?.collectionDate != nil {
                reDate = temp?.collectionDate
                reDateBtn.setTitle(reDate?.string(), for: .normal)
            }
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
            let temp = record?.borrow
            amount.text = String(loadAmount(value: temp!.amount))
            descript.text = temp?.descript
            dateTime.date = temp!.date
            personTF.text = temp?.lender
            locationTF.text = temp?.location
            doneValue.isOn = temp!.isRepayed
            srcAccount = temp?.srcAccount
            chooseAccountBtn.setTitle(temp?.srcAccount?.getname(), for: .normal)
            if temp?.repaymentDate != nil
            {
                reDate = temp?.repaymentDate
                reDateBtn.setTitle(reDate?.string(), for: .normal)
            }
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
        
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        amount.isSecureTextEntry = userInfor!.isHideAmount
        unit.text = currencyBase().symbol[userInfor!.currency]
        
        var tempStr: [String] = []
        tempStr.append(contentsOf: userInfor!.persons)
        personTF.filterStrings(tempStr)
        personTF.theme.font = UIFont.systemFont(ofSize: 15)
        personTF.maxNumberOfResults = 5
        tempStr = []
        tempStr.append(contentsOf: userInfor!.locations)
        locationTF.filterStrings(tempStr)
        locationTF.theme.font = UIFont.systemFont(ofSize: 15)
        locationTF.maxNumberOfResults = 5
        
        ProgressHUD.dismiss()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        loadData()
        super.viewWillAppear(true)
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

    @IBAction func chooseAccount(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "selectAccountVC") as! selectAccountVC
        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    
    override func viewDidLoad() {
        
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

    @IBAction func clickSave(_ sender: Any) {
        var _amount = Float(amount.text!)
        if amount.text == "" || _amount == 0
        {
            print("You have to enter amount!")
            SCLAlertView().showError("Amount must be nonzero!", subTitle: "")
            return
        }
        
        if srcAccount == nil
        {
            print("You have to choose account for this action!")
            SCLAlertView().showError("You have to choose source account!", subTitle: "")

            return
        }
        if personTF.text == ""
        {
            var tempStr = "borrower"
            if type == 3
            {
                tempStr = "lender"
            }
            print("You have to enter name of \(tempStr)!")
            SCLAlertView().showError("You have to enter \(tempStr)'s name!", subTitle: "")
            return
        }
        //update record
        if userInfor!.currency != 0 {
            _amount = _amount! / Float(currencyBase().valueBaseDolar[userInfor!.currency])
        }
        try! realm.write{
            var imgStored: imgClass? = nil
            if record?.type == 2
            {
                imgStored = record?.lend?.img
            }
            else
            {
                imgStored = record?.borrow?.img
            }
            
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
                        imgStored?.isChanged = true
                    }
                    }
                }
            }
            
        if type == 2
        {
            let temp = record?.lend
                //undo transaction
                temp?.undoTransaction()

            temp?.updateLend(_amount: _amount!, _type: 2, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text!, _location: locationTF.text ?? "", _srcImg: imgStored, _date: dateTime.date, _collectionDate:reDate)
                
                temp?.doTransaction()
            print("Updated an lend!")
            //problem change src account
         }
        else{
            let temp = record?.borrow
                temp?.undoTransaction()
                
            temp?.updateBorrow(_amount: _amount!, _type: 3, _descript: descript.text ?? "", _srcAccount: srcAccount!, _person: personTF.text!, _location: locationTF.text ?? "", _srcImg: imgStored, _date: dateTime.date, _repaymentDate:reDate)
                temp?.doTransaction()
            print("Updated an borrow!")
            }
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
            SCLAlertView().showSuccess("Transaction updated!", subTitle: record?.getDescript() ?? "")
        historyDelegate?.editedRecord()
        }
        print(realm.configuration.fileURL!)
        //pop vc
            self.navigationController?.popViewController(animated: true)
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
                self.record?.isDeleted = true
                if self.record?.type == 2
                {
                    if self.record?.lend?.img != nil && self.record!.lend!.img!.isUploaded == true
                    {
                        self.record!.lend!.img!.isDeleted = true
                    }
                    self.record?.lend?.undoTransaction()

                    print("Mark a lend as deleted!")
                }
                else
                {
                    if self.record?.borrow?.img != nil && self.record!.borrow!.img!.isUploaded == true
                    {
                        self.record!.borrow!.img!.isDeleted = true
                    }
                    self.record?.borrow?.undoTransaction()

                    print("Mark a borrow as deleted!")
                }
            }
            else
            {
                if self.record?.type == 2
                {
                    if self.record?.lend?.img != nil
                    {
                        self.realm.delete(self.record!.lend!.img!)
                    }
                    self.record?.lend?.undoTransaction()
                    self.realm.delete((self.record?.lend)!)

                    print("Delete a lend!")

                }
                else
                {
                    if self.record?.borrow?.img != nil
                    {
                        self.realm.delete(self.record!.borrow!.img!)
                    }
                    self.record?.borrow?.undoTransaction()
                    self.realm.delete((self.record?.borrow)!)

                    print("Delete a borrow!")

                }
                self.realm.delete(self.record!)
            }
        //delete data in database
        }
            print("Deleted a lend or borrow")
            SCLAlertView().showSuccess("Transaction deleted!", subTitle: "")
            self.historyDelegate?.editedRecord()
            self.navigationController?.popViewController(animated: true)
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

extension editLendOrBorrowVC: ImagePickerDelegate{
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
extension editLendOrBorrowVC: delteImageDelegate{
    func didDeletedImage() {
        imgURL = nil
        imgView.image = UIImage(systemName: "film")
        hasImg = false
        imgChange = true
    }
}

