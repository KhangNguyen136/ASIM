//
//  passwordVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/1/21.
//

import UIKit
import RealmSwift

class passwordVC: UITableViewController {
    var isChangePassword = true
    let realm = try! Realm()
    var userInfor: User!

    var dataSource = ["Old password","New password","Confirm new password"]
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        if userInfor.password == ""
        {
            isChangePassword = false
            dataSource.remove(at: 0)
            self.navigationItem.title = "Set up password"
        }
        
    }
    override func viewDidLoad() {
        tableView.register(passwordTextFieldCell.self, forCellReuseIdentifier: "passwordTextFieldCell")
        tableView.register(messageCell.self, forCellReuseIdentifier: "messageCell")
        loadData()
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageRow") as! messageCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "passwordTextFieldRow") as! passwordTextFieldCell
        cell.getData(_title: dataSource[indexPath.row-1], _content: "")
        return cell
    }
    
    @IBAction func clickDone(_ sender: Any) {
        if isChangePassword == true
        {
            var temp = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! passwordTextFieldCell
            let oldPass = temp.content.text ?? ""
            if oldPass != userInfor.password
            {
                print("Incorrect old password!")
                return
            }
            temp = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! passwordTextFieldCell
                let newPass = temp.content.text ?? ""
            
            temp = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! passwordTextFieldCell
                let newPass2 = temp.content.text ?? ""
            if checkPass(pass: newPass) == false
            {
                print("New password must contain at least 1 uppercase,1 lowercase letter and 1 number")
                return
            }
            if newPass != newPass2
            {
                print("Confirm new password must same with new password!")
                return
            }
            try! realm.write{
                userInfor.password = newPass
            }
            print("Updated password.")
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            var temp = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! passwordTextFieldCell
                let newPass = temp.content.text ?? ""
            
            temp = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! passwordTextFieldCell
                let newPass2 = temp.content.text ?? ""
            if checkPass(pass: newPass) == false
            {
                print("New password must contain at least 1 uppercase,1 lowercase letter and 1 number")
                return
            }
            if newPass != newPass2
            {
                print("Confirm new password must same with new password!")
                return
            }
            try! realm.write{
                userInfor.password = newPass
            }
            print("Updated password.")
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    func checkPass(pass: String) -> Bool {
        if pass.count < 8
        {
            return false
        }
//        return false if pass doesn't have at least 1 uppercase,1 lowercase letter and 1 number
        
        return true
    }
    
}
class messageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
class passwordTextFieldCell: UITableViewCell {

    @IBOutlet weak var content: UITextField!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func getData(_title: String, _content: String)  {
        title.text = _title
        content.text = _content
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
