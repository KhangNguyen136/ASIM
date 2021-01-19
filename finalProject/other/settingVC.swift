//
//  settingVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/1/21.
//

import UIKit
import RealmSwift
import DropDown

class settingVC: UITableViewController {

    let realm = try! Realm()
    var userInfor: User!
    
    @IBOutlet weak var defaultScreenBtn: UIButton!
    @IBOutlet weak var dateFormatBtn: UIButton!
    @IBOutlet weak var isHideAmount: UISwitch!
    @IBOutlet weak var currencyBtn: UIButton!
    @IBOutlet weak var langBtn: UIButton!
    let screen = ["Dashboard", "Account","Add Record","Report","Other"]
    
    func loadData()
    {
        langBtn.semanticContentAttribute = .forceRightToLeft
        currencyBtn.semanticContentAttribute = .forceRightToLeft
        dateFormatBtn.semanticContentAttribute = .forceRightToLeft
        defaultScreenBtn.semanticContentAttribute = .forceRightToLeft
        
        let temp = realm.objects(User.self)
        if temp.isEmpty{
            return
        }
        userInfor = temp[0]
        if userInfor.isVietnamese == true
        {
            langBtn.setTitle("Vietnamese", for: .normal)
        }
        currencyBtn.setTitle(currencyBase().symbol[userInfor.currency], for: .normal)

        if userInfor.isHideAmount == true
        {
            isHideAmount.setOn(true, animated: false)
        }
        defaultScreenBtn.setTitle(screen[userInfor.defaultScreen], for: .normal)
        dateFormatBtn.setTitle(userInfor.dateFormat, for: .normal)
    }
    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()

    }

    @IBAction func setHideAmountValue(_ sender: UISwitch) {
        try! realm.write{
            userInfor.isHideAmount = sender.isOn
        }
    }
    
    @IBAction func chooseLanguage(_ sender: UIButton) {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = langBtn // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["English", "Vietnamese"]

        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)

        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? typeRecord else { return }

           // Setup your custom UI components
            if index == 0
            {
                cell.logo.image = UIImage(named: "United States Dollar")
            }
            else
            {
                cell.logo.image = UIImage(named: "Vietnamese Dong")
            }
        }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self!.langBtn.setTitle(item, for: .normal)
            if index == 1
            {
                try! self!.realm.write{
                    self!.userInfor.isVietnamese = true
                }
            }
            else
            {
                try! self!.realm.write{
                    self!.userInfor.isVietnamese = false
                }
            }
        }
        dropDown.show()
    }
    
    @IBAction func chooseCurrency(_ sender: UIButton) {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = currencyBtn // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = currencyBase().nameEnglish

        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)

        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? typeRecord else { return }

           cell.logo.image = UIImage(named: "currency\(index)")

        }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
                try! self!.realm.write{
                    self!.userInfor.currency = index
                }
            
        }
        dropDown.show()
        
    }
    @IBAction func chooseDateFormat(_ sender: Any) {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = langBtn // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["dd.MM.yy", "MM/dd/yyyy","MMM d, yyyy","EEEE, MMM d, yyyy"]

        /*** IMPORTANT PART FOR CUSTOM CELLS ***/


        dropDown.selectionAction = { [self] (index: Int, item: String) in
            dateFormatBtn.setTitle(item, for: .normal)
            try! realm.write{
                userInfor.dateFormat = item
            }
        }
        dropDown.show()
    }
    
    @IBAction func chooseDefaultScreen(_ sender: UIButton) {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = defaultScreenBtn // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Dashboard", "Account","Add Record","Report","Other"]
        let imgSource = ["home","walletSelected","plus.circle.fill","reportSelected","otherSelected"]
        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)

        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? typeRecord else { return }

           // Setup your custom UI components
            if index == 2
            {
                cell.logo.image = UIImage(systemName: imgSource[index])
            }
            else
            {
           cell.logo.image = UIImage(named: imgSource[index])
            }
        }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self!.defaultScreenBtn.setTitle(item, for: .normal)
                try! self!.realm.write{
                    self!.userInfor.defaultScreen = index
                }
        }
        dropDown.show()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

}
