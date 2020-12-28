//
//  otherVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit

class otherVC: UIViewController {

    @IBOutlet weak var listTv: UITableView!
    let titleRow = ["Setting","Your data","Share app","Rate app","Your feedback","Help and information"]
    let imgName = ["gearshape.fill","doc.text.fill","point.fill.topleft.down.curvedto.point.fill.bottomright.up","star.leadinghalf.fill","envelope.badge.fill","info.circle.fill"]
    override func viewDidLoad() {
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
        if row == 1
        {
            let dest = self.superview!.parentViewController!.storyboard?.instantiateViewController(identifier: "yourDataVC") as! yourDataVC
            self.superview!.parentViewController!.navigationController?.pushViewController(dest, animated: false)
        }
        print(content.currentTitle!)
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
