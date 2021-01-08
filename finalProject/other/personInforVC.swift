//
//  personInforVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/25/20.
//

import UIKit
import RealmSwift

class personInforVC: UIViewController {
    let realm = try! Realm()
    var userInfor: User!
    let _title = ["Display name: ","Numberphone: ","","Address: ","Job: "]
    var content:[String] = []
    @IBOutlet weak var avtImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var listTV: UITableView!
    override func viewDidLoad() {
        listTV.register(inforTextFieldCell.self, forCellReuseIdentifier: "inforTextFieldCell")
        listTV.register(dobInforCell.self, forCellReuseIdentifier: "dobInforCell")
        listTV.register(submitInforCell.self, forCellReuseIdentifier: "submitInforCell")
        loadData()
        super.viewDidLoad()

    }
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        content.append(userInfor.displayName)
        content.append(userInfor.numberPhone)
        content.append("")
        content.append(userInfor.address)
        content.append(userInfor.job)
        
        if userInfor.displayName != ""
        {
            userName.text = userInfor.displayName
        }
        
    }
    func submitData()
    {
        var temp = listTV.cellForRow(at: IndexPath(row: 0, section: 0)) as! inforTextFieldCell
        let displayName = temp.content.text ?? ""
        temp = listTV.cellForRow(at: IndexPath(row: 1, section: 0)) as! inforTextFieldCell
        let numberPhone = temp.content.text ?? ""
        temp = listTV.cellForRow(at: IndexPath(row: 3, section: 0)) as! inforTextFieldCell
        let address = temp.content.text ?? ""
        temp = listTV.cellForRow(at: IndexPath(row: 4, section: 0)) as! inforTextFieldCell
        let job = temp.content.text ?? ""
        let temp1 = listTV.cellForRow(at: IndexPath(row: 2, section: 0)) as! dobInforCell
        let birthDay = temp1.dateOfBirth.date
        let isMale = temp1.isMale.isOn
        
        try! realm.write{
            userInfor.displayName = displayName
            userInfor.numberPhone = numberPhone
            userInfor.job = job
            userInfor.address = address
            userInfor.birthDay = birthDay
            userInfor.isMale = isMale
            print("Updated user information!")
        }
    }
}


extension personInforVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 5
        {
            let cell = listTV.dequeueReusableCell(withIdentifier: "submitInforRow") as! submitInforCell
//            cell.getData(imgName: imgName[indexPath.row], title: titleRow[indexPath.row])
            return cell
        }
        if indexPath.row == 2
        {
            let cell = listTV.dequeueReusableCell(withIdentifier: "dobInforRow") as! dobInforCell
            cell.getData(birthDay: userInfor.birthDay, _isMale: userInfor.isMale)
//            cell.getData(imgName: imgName[indexPath.row], title: titleRow[indexPath.row])
            return cell
        }
        let cell = listTV.dequeueReusableCell(withIdentifier: "inforTextFieldRow") as! inforTextFieldCell
        cell.getData(_title: _title[indexPath.row], _content: content[indexPath.row])
//            cell.getData(imgName: imgName[indexPath.row], title: titleRow[indexPath.row])
        return cell
    }
    
}
class inforTextFieldCell: UITableViewCell {

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
class dobInforCell: UITableViewCell {
    
    @IBOutlet weak var dateOfBirth: UIDatePicker!
    @IBOutlet weak var isMale: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func getData(birthDay: Date, _isMale: Bool)  {
        dateOfBirth.date = birthDay
        isMale.isOn = _isMale
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class submitInforCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func clickSave(_ sender: Any) {
        let temp = self.parentViewController as! personInforVC
        temp.submitData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

