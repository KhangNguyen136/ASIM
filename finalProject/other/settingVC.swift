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
        if userInfor.isVietnamDong == true
        {
            currencyBtn.setTitle("VND", for: .normal)
        }
        if userInfor.isHideAmount == true
        {
            isHideAmount.setOn(true, animated: false)
        }
        defaultScreenBtn.setTitle(screen[userInfor.defaultScreen], for: .normal)
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
        dropDown.dataSource = ["United States Dollar (USD)", "Vietnamese Dong"]

        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)

        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? typeRecord else { return }

           // Setup your custom UI components
            if index == 1
            {
           cell.logo.image = UIImage(named: "Vietnamese Dong")
            }
            else
            {
                cell.logo.image = UIImage(named: "United States Dollar")
            }
        }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            if index == 0
            {
                self!.currencyBtn.setTitle("$", for: .normal)
                try! self!.realm.write{
                    self!.userInfor.isVietnamDong = false
                }
            }
            else
            {
                self!.currencyBtn.setTitle("VND", for: .normal)

                try! self!.realm.write{
                    self!.userInfor.isVietnamDong = true
                }
            }
        }
        dropDown.show()
        
    }
    @IBAction func chooseDateFormat(_ sender: Any) {
        print("Choose date format")
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
            switch index {
            case 0:
//                self!.defaultScreenBtn.setTitle("Dashboard", for: .normal)
                try! self!.realm.write{
                    self!.userInfor.defaultScreen = index
                }
            case 1:
//                self!.defaultScreenBtn.setTitle("Account", for: .normal)
                try! self!.realm.write{
                    self!.userInfor.defaultScreen = index
                }
            case 2:
//                self!.defaultScreenBtn.setTitle("Add Record", for: .normal)
                try! self!.realm.write{
                    self!.userInfor.defaultScreen = index
                }
            case 3:
//                self!.defaultScreenBtn.setTitle("Report", for: .normal)
                try! self!.realm.write{
                    self!.userInfor.defaultScreen = index
                }
            default:
//                self!.defaultScreenBtn.setTitle("Other", for: .normal)
                try! self!.realm.write{
                    self!.userInfor.defaultScreen = index
                }
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
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
