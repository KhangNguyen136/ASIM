//
//  personInforVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/25/20.
//

import UIKit

class personInforVC: UIViewController {

    @IBOutlet weak var avtImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var listTV: UITableView!
    override func viewDidLoad() {
        listTV.register(inforTextFieldCell.self, forCellReuseIdentifier: "inforTextFieldCell")
        listTV.register(dobInforCell.self, forCellReuseIdentifier: "dobInforCell")
        listTV.register(submitInforCell.self, forCellReuseIdentifier: "submitInforCell")

        super.viewDidLoad()

    }
}

class inforTextFieldCell: UITableViewCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func getData(imgName: String, title: String)  {

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
//            cell.getData(imgName: imgName[indexPath.row], title: titleRow[indexPath.row])
            return cell
        }
        let cell = listTV.dequeueReusableCell(withIdentifier: "inforTextFieldRow") as! inforTextFieldCell
//            cell.getData(imgName: imgName[indexPath.row], title: titleRow[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listTV.deselectRow(at: indexPath, animated: false)
    }
    
}
class dobInforCell: UITableViewCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func getData(imgName: String, title: String)  {

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
    func getData(imgName: String, title: String)  {

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

