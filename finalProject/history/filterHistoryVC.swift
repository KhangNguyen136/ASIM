//
//  filterHistoryVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/25/20.
//

import UIKit
import DatePicker
import AlertsAndPickers

class filterHistoryVC: UIViewController {

    var selectedSection = -1
    var selectedRow = -1
    var delegate: chooseFilterTypeDelegate? = nil
    var isOpened: [Bool] = [false,false,false,false,false]
    let dataSource: [[String]] = [["Date","Today","Yesterday","Select day"],
                                  ["Week","This week","Last week"],
                                  ["Month","This month","Last month","Select month"],
                                  ["Custom","Start date: ","End date: "],
                                  ["All"]]
    var startDate: Date? = nil
    var endDate: Date? = nil
    @IBOutlet weak var listTv: UITableView!
    func getData(section: Int, row: Int) {
        if section == -1 || row == -1
        {
            return
        }
        isOpened[section] = true
        selectedRow = row
        selectedSection = section
    }
    
    @IBAction func clickDone(_ sender: Any) {
        if selectedSection == 3
        {
            var temp = listTv.cellForRow(at: IndexPath(row: 1, section: 3)) as! seclectDateFilterHistoryCell
            startDate = temp.date
            if startDate == nil
            {
                print("You have to choose start date!")
                return
            }
            temp = listTv.cellForRow(at: IndexPath(row: 2, section: 3)) as! seclectDateFilterHistoryCell
            endDate = temp.date
            if endDate == nil{
                print("You have to choose end date!")
                return
            }
            if endDate < startDate
            {
                print("Start date cannot be less than end date!")
                return
            }
            let tempStr = (startDate?.string())! + " - " + (endDate?.string())!
            delegate?.didSelectedFilterByCustom(id: (3,0), start: startDate!, end: endDate!, title: tempStr)
        }
        self.navigationController?.popViewController(animated: false)
    }
    override func viewDidLoad() {
        listTv.register(filterHistoryCell.self, forCellReuseIdentifier: "filterHistoryCell")
        listTv.register(sectionFilterHistoryCell.self, forCellReuseIdentifier: "sectionFilterHistoryCell")
        listTv.register(seclectDateFilterHistoryCell.self, forCellReuseIdentifier: "seclectDateFilterHistoryCell")
        if selectedRow != -1 && selectedSection != -1
        {
        listTv.selectRow(at: IndexPath(row: selectedRow, section: selectedSection), animated: true, scrollPosition: .none)
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}
extension filterHistoryVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOpened[section]
        {
        return dataSource[section].count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: sectionFilterHistoryCell = listTv.dequeueReusableCell(withIdentifier: "sectionFilterHistoryRow", for: indexPath) as! sectionFilterHistoryCell
            cell.content.text = dataSource[indexPath.section][indexPath.row]
            return cell
        }
        else
        {
            if indexPath.section == 3
            {
                let cell: seclectDateFilterHistoryCell = listTv.dequeueReusableCell(withIdentifier: "seclectDateFilterHistoryRow", for: indexPath) as! seclectDateFilterHistoryCell
                cell.content.text = dataSource[indexPath.section][indexPath.row]
                return cell
            }
            else
            {
                let cell: filterHistoryCell = listTv.dequeueReusableCell(withIdentifier: "filterHistoryRow", for: indexPath) as! filterHistoryCell
                cell.content.text = dataSource[indexPath.section][indexPath.row]
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectedSection = indexPath.section
        if indexPath.row == 0 && indexPath.section != 4
        {
            isOpened[indexPath.section] = !isOpened[indexPath.section]
            listTv.reloadSections(	IndexSet.init(integer: indexPath.section), with: .fade)
            if isOpened[indexPath.section] == true
                {
                listTv.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
        }
        else if indexPath.section == 3
        {
            return
        }
        else if indexPath.section == 0 && indexPath.row == 3
        {
            let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1990)!
                    let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
                    // Create picker object
                    let datePicker = DatePicker()
                    // Setup
                    datePicker.setup(beginWith: Date(), min: minDate, max: maxDate) { (selected, date) in
                        if selected, let selectedDate = date {
                            self.delegate?.didSelectedFilterByCustom(id: (0,3), start: selectedDate, end: selectedDate, title: selectedDate.string())
                            self.navigationController?.popViewController(animated: false)
                        } else {
                            print("Cancelled")
                        }
                    }
                    // Display
            datePicker.show(in: self)
        }
        else if indexPath.section == 2 && indexPath.row == 3
        {
            let alert = UIAlertController(title: "Select month", message: "", preferredStyle: .actionSheet)
            
            return
        }
        else
        {
                delegate?.didSelectedFilterHistory(row: indexPath.row, section: indexPath.section,title: dataSource[indexPath.section][indexPath.row])
            self.navigationController?.popViewController(animated: false)
        }
    }
    
}
