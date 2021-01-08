//
//  DetailAccumulate.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 1/5/21.
//

import UIKit

class DetailAccumulate: UIViewController {
    var viewName = ""
    var accumulate = Accumulate()
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblRemainDate: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblAdded: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var lblRemain: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

         self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
               self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
               self.navigationItem.title = viewName
               self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!
               ]
        loadData()
    }
    
    func loadData(){
        let purBalance = accumulate.balance
        let addBalance = accumulate.addbalance
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        lblStartDate.text = "\(dateFormatter.string(from: accumulate.startdate)) - "
        lblEndDate.text = dateFormatter.string(from: accumulate.enddate)
        if addBalance >= purBalance{
            
        }
        else {
            
        }
        
        let remain = purBalance - addBalance
        lblRemain.text = "\(remain) đ"
        progress.progress = addBalance/purBalance
        lblAdded.text = "\(addBalance)"
        let timeTerm = Calendar.current.dateComponents([.day], from: accumulate.startdate, to: accumulate.enddate)
        if timeTerm.day! < 30{
            lblRemainDate.text = "(Remain \(timeTerm.day!) days)"
        }
        else if timeTerm.day! <= 365{
            let timeTerm = Calendar.current.dateComponents([.month], from: accumulate.startdate, to: accumulate.enddate)
            lblRemainDate.text = "(Remain \(timeTerm.month!) months)"
        }
        else {
            let timeTerm = Calendar.current.dateComponents([.year], from: accumulate.startdate, to: accumulate.enddate)
            lblRemainDate.text = "(Remain \(timeTerm.year!) years)"
        }
        
       
    }
  

}
