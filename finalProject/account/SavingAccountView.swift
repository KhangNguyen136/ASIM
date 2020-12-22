//
//  SavingAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/15/20.
//

import UIKit
import RealmSwift

class SavingAccountView: UIViewController {
    var allAccount: [savingAccount] = []
    @IBOutlet weak var lblamount: UILabel!
    @IBOutlet weak var lblNumAcc: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
               // Do any additional setup after loading the view.
        self.navigationItem.title = "Saving account"
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        loadData()
    }
    
    func loadData(){
       let realm = try! Realm()
       let acc = realm.objects(savingAccount.self)
        allAccount = Array(acc)
       var total: Float = 0.0
       for bal in acc{
           total += bal.ammount
       }
        lblamount.text = "\(total)"
        lblNumAcc.text = "(\(acc.count) account)"
   }
}
extension SavingAccountView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllSavingAccountCell", for: indexPath) as! AllSavingAccountCell
        let type = allAccount[indexPath.row].srcAccountType
        cell.imgIcon.image = UIImage(named: "bank")
        cell.lblName.text = allAccount[indexPath.row].bank
        cell.lblRate.text = "\( allAccount[indexPath.row].interestRate)%"
        let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.lblDate.text = dateFormatter.string(from: allAccount[indexPath.row].startdate)
        cell.backgroundView = UIImageView(image: UIImage(named: "row"))
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
           return cell
    }
    
    
}
