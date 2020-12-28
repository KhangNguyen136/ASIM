//
//  historyVc.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/25/20.
//

import UIKit
import RealmSwift

protocol editRecordDelegate: class {
    func editedRecord()
}
protocol chooseFilterTypeDelegate: class {
    func didSelectedFilterHistory(row: Int, section: Int, title: String)
    func didSelectedFilterByCustom(id: (Int,Int), start: Date, end: Date, title: String)
}

struct sectionInfor {
    var day: String = ""
    var totalIncome: Float = 0
    var totalExpense: Float = 0
    var records: [polyRecord] = []
}

class historyVC: UIViewController,editRecordDelegate,chooseFilterTypeDelegate {
    
    func didSelectedFilterByCustom(id: (Int, Int), start: Date, end: Date, title: String) {
        print("Filter by custom from \(startDate?.string() ?? "") to \(endDate?.string() ?? "")")
        startDate = start
        endDate = end
        filterBy = id
        filterBtn.setTitle(title, for: .normal)
        loadData()
    }
    var startDate: Date? = nil
    var endDate: Date? = nil
    
    func didSelectedFilterHistory(row: Int, section: Int, title: String) {
        filterBy = (section,row)
        filterBtn.setTitle(title, for: .normal)
        loadData()
    }
    
    func editedRecord() {
        loadData()
        listTv.reloadData()
    }
    
    var filterBy: (Int, Int) = (2,1)

    @IBOutlet weak var expense: UILabel!
    @IBOutlet weak var income: UILabel!
    var totalIncome: Float = 0
    var totalExpense: Float = 0
    @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var listTv: UITableView!
    
    var dataSource : [sectionInfor] = []
    var days: [String] = []
    let formatter = DateFormatter()
    let realm = try! Realm()
    
    func filterByDate(date: Date) -> Bool {
        switch filterBy {
        case (2,1):
//            print("This month")
            if Calendar.current.isDateInThisMonth(date)           {
            return true
            }
            return false
        case (2,2):
//            print("Last month")
            if Calendar.current.isDateInLastMonth(date)
            {
                return true
            }
            return false

        case (1,1):
//            print("This weeek")
            
            if Calendar.current.isDateInThisWeek(date)
            {
                return true
            }
            return false

        case (1,2):
//            print("Last week")
            if Calendar.current.isDateInLastWeek(date)
            {
                return true
            }
            return false

        case (0,1):
//            print("Today")
    
            if Calendar.current.isDateInToday(date)
            {
                return true
            }
            return false

        case (0,2):
//            print("Yesterday")
            if Calendar.current.isDateInYesterday(date)         {
            return true
            }
            return false
        case (0,3):
//            print("Select day")
//            if date.compare(startDate!) == .orderedSame
            if date == startDate
            {
            return true
            }
            return false

        case (4,0):
//            print("All")
            return true

        default:
            if date.isBetweeen(date: startDate!, andDate: endDate!)
                {
                return true
            }
            return false

        }
    }

    func loadData() {
        totalIncome = 0
        totalExpense = 0
        dataSource = []
        days = []
        let tempRecords = realm.objects(polyRecord.self)
        //load data before append to history
        for i in tempRecords
        {
            switch i.type {
            case 0:
                let temp = i.expense
                if filterByDate(date: (temp?.date)!) == false
                {
                    continue
                }
                totalExpense += temp!.amount
                let daystr = formatter.string(from: temp!.date)
                let id = days.firstIndex(of: daystr)
                if id == nil
                {
                    var tempSection = sectionInfor()
                    tempSection.day = daystr
                    tempSection.records.append(i)
                    tempSection.totalExpense += temp!.amount
                    insertHistorySection(tempSection: tempSection, _tempDate: daystr)
                }
                else
                {
                    dataSource[id!].records.append(i)
                    dataSource[id!].totalExpense += temp!.amount
                }
            case 1:
                let temp = i.income
                if filterByDate(date: (temp?.date)!) == false
                {
                    continue
                }
                totalIncome += temp!.amount
                let daystr = formatter.string(from: temp!.date)
                let id = days.firstIndex(of: daystr)
                if id == nil
                {
                    var tempSection = sectionInfor()
                    tempSection.day = daystr
                    tempSection.records.append(i)
                    tempSection.totalIncome += temp!.amount
                    insertHistorySection(tempSection: tempSection, _tempDate: daystr)
                }
                else
                {
                    dataSource[id!].records.append(i)
                    dataSource[id!].totalIncome += temp!.amount
                }
            case 2:
                let temp = i.lend
                if filterByDate(date: (temp?.date)!) == false
                {
                    continue
                }
                totalExpense += temp!.amount
                let daystr = formatter.string(from: temp!.date)
                let id = days.firstIndex(of: daystr)
                if id == nil
                {
                    var tempSection = sectionInfor()
                    tempSection.day = daystr
                    tempSection.records.append(i)
                    tempSection.totalExpense += temp!.amount
                    insertHistorySection(tempSection: tempSection, _tempDate: daystr)
                }
                else
                {
                    dataSource[id!].records.append(i)
                    dataSource[id!].totalExpense += temp!.amount
                }
            case 3:
                let temp = i.borrow
                if filterByDate(date: (temp?.date)!) == false
                {
                    continue
                }
                totalIncome += temp!.amount
                let daystr = formatter.string(from: temp!.date)
                let id = days.firstIndex(of: daystr)
                if id == nil
                {
                    var tempSection = sectionInfor()
                    tempSection.day = daystr
                    tempSection.records.append(i)
                    tempSection.totalIncome += temp!.amount
                    insertHistorySection(tempSection: tempSection, _tempDate: daystr)
                }
                else
                {
                    dataSource[id!].records.append(i)
                    dataSource[id!].totalIncome += temp!.amount
                }
            case 5:
                let temp = i.adjustment
                if filterByDate(date: (temp?.date)!) == false
                {
                    continue
                }
                if temp?.subType == 0
                {
                    totalExpense += temp!.different
                    let daystr = formatter.string(from: temp!.date)
                    let id = days.firstIndex(of: daystr)
                    if id == nil
                    {
                        var tempSection = sectionInfor()
                        tempSection.day = daystr
                        tempSection.records.append(i)
                        tempSection.totalExpense += temp!.different
                        //insert data into dataSource
                        insertHistorySection(tempSection: tempSection, _tempDate: daystr)
                    }
                    else
                    {
                        dataSource[id!].records.append(i)
                        dataSource[id!].totalExpense += temp!.different
                    }
                }
                else
                {
                    totalIncome += temp!.different
                    let daystr = formatter.string(from: temp!.date)
                    let id = days.firstIndex(of: daystr)
                    if id == nil
                    {
                        var tempSection = sectionInfor()
                        tempSection.day = daystr
                        tempSection.records.append(i)
                        tempSection.totalIncome += temp!.different
                        insertHistorySection(tempSection: tempSection, _tempDate: daystr)
                    }
                    else
                    {
                        dataSource[id!].records.append(i)
                        dataSource[id!].totalIncome += temp!.different
                    }
                }
            default:
                //transfer
                let temp = i.transfer
                if filterByDate(date: (temp?.date)!) == false
                {
                    continue
                }
                let daystr = formatter.string(from: temp!.date)
                let id = days.firstIndex(of: daystr)
                if id == nil
                {
                    var tempSection = sectionInfor()
                    tempSection.day = daystr
                    tempSection.records.append(i)
                    insertHistorySection(tempSection: tempSection, _tempDate: daystr)
                }
                else
                {
                    dataSource[id!].records.append(i)
                }
            }
        }
        income.text = String(totalIncome)
        expense.text = String(totalExpense)
        listTv.reloadData()
    }
    func insertHistorySection(tempSection: sectionInfor, _tempDate: String)  {
        let tempDate = formatter.date(from: _tempDate)!
        for i in 0..<days.count
        {
            let temp = formatter.date(from: days[i])!
//            if tempDate == temp
//            {
//            }
            if tempDate < temp
            {
                days.insert(_tempDate, at: i)
                dataSource.insert(tempSection, at: i)
                return
            }
        }
        days.append(_tempDate)
        dataSource.append(tempSection)
    }
    override func viewDidLoad(){
        formatter.dateStyle = .medium
        filterBtn.semanticContentAttribute = .forceRightToLeft
        listTv.register(historyCell.self, forCellReuseIdentifier: "historyCell")
        loadData()
        
        super.viewDidLoad()
    }
    
    @IBAction func filterHistory(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "filterHistoryVC") as! filterHistoryVC
        dest.delegate = self
        dest.getData(section: filterBy.0, row: filterBy.1)
        self.navigationController?.pushViewController(dest, animated: false)
    }
}

extension historyVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource[section].records.count + 1
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0
    {
        let cell: sectionHistoryCell = listTv.dequeueReusableCell(withIdentifier: "sectionHistoryRow", for: indexPath) as! sectionHistoryCell
        cell.getData(_date: days[indexPath.section], _income: dataSource[indexPath.section].totalIncome, _expense: dataSource[indexPath.section].totalExpense)
        return cell
    }
    else
    {
        let cell: historyCell = listTv.dequeueReusableCell(withIdentifier: "historyRow", for: indexPath) as! historyCell
        
        cell.getData(_record: dataSource[indexPath.section].records[indexPath.row-1])
        
        return cell
    }
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            listTv.deselectRow(at: indexPath, animated: false)
            return
        }
        let sb = UIStoryboard(name: "editRecord", bundle: nil)
        let temp = dataSource[indexPath.section].records[indexPath.row-1]
        switch temp.type {
        case 0,1:
            let dest = sb.instantiateViewController(identifier: "editExOrInVC") as! editExOrInVC
            dest.record = temp
            dest.historyDelegate = self
            self.navigationController?.pushViewController(dest, animated: false)
        case 2,3:
            let dest = sb.instantiateViewController(identifier: "editLendOrBorrowVC") as! editLendOrBorrowVC
                dest.record = temp
            dest.historyDelegate = self
            self.navigationController?.pushViewController(dest, animated: false)

        case 4:
            let dest = sb.instantiateViewController(identifier: "editTransferVc") as! editTransferVc
            dest.src = temp
            dest.historyDelegate = self
            self.navigationController?.pushViewController(dest, animated: false)

        default:
            let dest = sb.instantiateViewController(identifier: "editAdjustmentVC") as editAdjustmentVC
            dest.record = temp
            dest.historyDelegate = self
            self.navigationController?.pushViewController(dest, animated: false)

        }
    }
}

extension Calendar {
  private var currentDate: Date { return Date() }

  func isDateInThisWeek(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
  }

  func isDateInThisMonth(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .month)
  }

  func isDateInLastWeek(_ date: Date) -> Bool {
    guard let nextWeek = self.date(byAdding: DateComponents(weekOfYear: -1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear)
  }

  func isDateInLastMonth(_ date: Date) -> Bool {
    guard let nextMonth = self.date(byAdding: DateComponents(month: -1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextMonth, toGranularity: .month)
  }

  func isDateInFollowingMonth(_ date: Date) -> Bool {
    guard let followingMonth = self.date(byAdding: DateComponents(month: 2), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: followingMonth, toGranularity: .month)
  }
}

extension Date {
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2)
    }
}
