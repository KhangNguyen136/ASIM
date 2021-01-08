//
//  otherVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import RealmSwift

class otherVC: UIViewController {

    @IBOutlet weak var listTv: UITableView!
    let realm = try! Realm()
    var userInfor: User!
    var titleRow = ["Personal information","Setting","Your data","Account link","Change password","Share app","Rate app","Your feedback","Help and information"]
    let imgName = ["person.fill","gearshape.fill","doc.text.fill","","","point.fill.topleft.down.curvedto.point.fill.bottomright.up","star.leadinghalf.fill","envelope.badge.fill","info.circle.fill"]
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        if userInfor.password != ""
        {
            titleRow[4] = "Set password"
        }
        print(realm.configuration.fileURL)
    }
    override func viewDidLoad() {
        loadData()
        listTv.register(otherCell.self, forCellReuseIdentifier: "otherCell")
        
        super.viewDidLoad()

    }

}
extension otherVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleRow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTv.dequeueReusableCell(withIdentifier: "otherRow") as! otherCell
        cell.getData(imgName: imgName[indexPath.row], title: titleRow[indexPath.row], _row: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = listTv.cellForRow(at: indexPath)  as! otherCell
        temp.click(temp.content!)
    }
    
}

class otherCell: UITableViewCell {

    var row = -1
    @IBOutlet weak var content: UIButton!
    
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func click(_ sender: Any) {
        switch row {
        case 0:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "personInforVC") as! personInforVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 1:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "settingVC") as! settingVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 2:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "yourDataVC") as! yourDataVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 3:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "accountLinkVC") as! accountLinkVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        case 4:
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "passwordVC") as! passwordVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        default:
            print(content.currentTitle!)

        }

    }
    func getData(imgName: String, title: String, _row: Int)  {
        img.image = UIImage(systemName: imgName)
        content.setTitle(title, for: .normal)
        row = _row
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
