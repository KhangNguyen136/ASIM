//
//  DetailAccumulate.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 1/5/21.
//

import UIKit

class DetailAccumulate: UIViewController {
    var viewName = ""
    var accumulate = polyAccount()
    @IBOutlet weak var NeedMore: UILabel!
    @IBOutlet weak var lblComplete: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblRemainDate: UILabel!
    @IBOutlet weak var lblPurBalance: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblAdded: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var lblRemain: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Remain: UILabel!
    @IBOutlet weak var Month: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblComplete.isHidden = true
         self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
               self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
               self.navigationItem.title = viewName
               self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!
               ]
        loadData()
        setLanguage()
    }
    func setLanguage(){
           
        Time.setupAutolocalization(withKey: "Time", keyPath: "text")
        Remain.setupAutolocalization(withKey: "Remain", keyPath: "text")
        NeedMore.setupAutolocalization(withKey: "NeedMore", keyPath: "text")
    
            
        }
    func loadData(){
        let purBalance = accumulate.accumulate!.balance
            
        lblPurBalance.text = "\(round((accumulate.accumulate!.balance as! Float)*Float(currencyBase().valueBaseDolar[accumulate.accumulate!.currency]))) \(currencyBase().symbol[accumulate.accumulate!.currency])"
        let addBalance = accumulate.accumulate!.addbalance
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        lblStartDate.text = "\(dateFormatter.string(from: accumulate.accumulate!.startdate)) - "
        lblEndDate.text = dateFormatter.string(from: accumulate.accumulate!.enddate)
        if addBalance >= purBalance{
            lblComplete.isHidden = false
        }
       
        
        let remain = purBalance - addBalance
        lblRemain.text = "\(remain*Float(currencyBase().valueBaseDolar[accumulate.accumulate!.currency])) \(currencyBase().symbol[accumulate.accumulate!.currency])"
        progress.progress = addBalance/purBalance
        lblAdded.text = "\(addBalance*Float(currencyBase().valueBaseDolar[accumulate.accumulate!.currency])) \(currencyBase().symbol[accumulate.accumulate!.currency])"
        let timeTerm = Calendar.current.dateComponents([.day], from: accumulate.accumulate!.startdate, to: accumulate.accumulate!.enddate)
        if timeTerm.day! < 30{
            lblRemainDate.text = " \(timeTerm.day!)"
            Month.setupAutolocalization(withKey: "Day", keyPath: "text")
        }
        else if timeTerm.day! <= 365{
            let timeTerm = Calendar.current.dateComponents([.month], from: accumulate.accumulate!.startdate, to: accumulate.accumulate!.enddate)
            lblRemainDate.text = " \(timeTerm.month!)"
            Month.setupAutolocalization(withKey: "Month", keyPath: "text")
        }
        else {
            let timeTerm = Calendar.current.dateComponents([.year], from: accumulate.accumulate!.startdate, to: accumulate.accumulate!.enddate)
            lblRemainDate.text = " \(timeTerm.year!)"
            Month.setupAutolocalization(withKey: "Year", keyPath: "text")
        }
        
       
    }
  

}
