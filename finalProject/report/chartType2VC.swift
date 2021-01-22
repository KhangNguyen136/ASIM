//
//  chartType2VC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/21/21.
//

import UIKit
import RealmSwift
import Charts
import DropDown

class chartType2VC: UITableViewController,settingDelegate {
    func changedHideAmountValue(value: Bool) {
        
    }
    
    func changedCurrency(value: Int) {
        currency = value
        drawChart()
        
    }
    func loadAmountByCurrency(value: Float) -> Float
    {
        if userInfor?.currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[userInfor!.currency])
    }
    

    
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    var filterBy = 1
    let filterLabels = ["This year","This month","This week","Today"]
    @IBAction func chooseOptionFilter(_ sender: Any) {
    let dropDown = DropDown()
    // The view to which the drop down will appear on
    dropDown.anchorView = sender as! AnchorView // UIView or UIBarButtonItem
    // The list of items to display. Can be changed dynamically
    dropDown.dataSource = ["This year","This month","This week","Today"]
    /*** IMPORTANT PART FOR CUSTOM CELLS ***/
    
    dropDown.selectionAction = { [weak self] (index: Int, item: String) in
        if index != self?.filterBy
        {
            self?.filterBtn.setTitle(item, for: .normal)
            self!.filterBy = index
            self!.drawChart()
        }
    }
    dropDown.show()
    
}
@IBOutlet weak var chooseTypeBtn: UIButton!
@IBAction func chooseType(_ sender: Any) {
    let dropDown = DropDown()
    // The view to which the drop down will appear on
    dropDown.anchorView = sender as! AnchorView // UIView or UIBarButtonItem
    // The list of items to display. Can be changed dynamically
    dropDown.dataSource = ["Expense vs Income","Lend vs Borrrow","Expense","Income","Location","Person"]
    /*** IMPORTANT PART FOR CUSTOM CELLS ***/
    
    dropDown.selectionAction = { [weak self] (index: Int, item: String) in
        if index - 2 != self?.type
        {
            switch index {
            case 0,1:
                guard var viewcontrollers = self?.navigationController?.viewControllers else { return }
                let dest = self?.storyboard?.instantiateViewController(identifier: "chartType1VC") as! chartType1VC
                dest.type = index
                _ = viewcontrollers.popLast()
                viewcontrollers.append(dest)
                self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
            case 2,3:
                guard var viewcontrollers = self?.navigationController?.viewControllers else { return }
                let dest = self?.storyboard?.instantiateViewController(identifier: "chartType2VC") as! chartType2VC
                dest.type = index - 2
                _ = viewcontrollers.popLast()
                viewcontrollers.append(dest)
                self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
            default:
                guard var viewcontrollers = self?.navigationController?.viewControllers else { return }
                let dest = self?.storyboard?.instantiateViewController(identifier: "chartType3VC") as! chartType3VC
                dest.type = index - 4
                _ = viewcontrollers.popLast()
                viewcontrollers.append(dest)
                self?.navigationController?.setViewControllers(viewcontrollers, animated: false)
            }
        }
    }
    dropDown.show()
}
@IBOutlet weak var pieChartView: PieChartView!
var type = -1
    var currency:Int = 0
var userInfor: User? = nil
let realm = try! Realm()
var setting: settingObserve? = nil
var settingObser: settingObserver? = nil
var categorieNames = ["Food and Dining","Utilities","Auto and Transport","Home"
    ,"Clothing",
    "Kids",
      "Gift and Donations",
      "Health and Fitness",
      "Entertainment",
      "Personal",
      "Pets",
      "Other"
]
var incomeNames = ["Bonus","Interest","Salary","Savings interesst","Collecting debts","Other"]
var recordList: [polyRecord] = []
func loadData()
{
    userInfor = realm.objects(User.self)[0]
    currency = userInfor!.currency
    recordList.append(contentsOf: userInfor!.records)
}
func drawChart(){
    if (type == 1)
    {
        var total:Float = 0
        chooseTypeBtn.setTitle("Income", for: .normal)
        var incomeList:[Income] = []
        for record in recordList{
            if((record.income) != nil && filterReportByDate(date: record.getDate(), by: filterBy)){
                incomeList.append(Income(value:record.income!))
            }
        }
        for income in incomeList{
            income.amount = loadAmountByCurrency(value: income.amount)
            total += income.amount
        }
        let categories = totalOfCategory(incomeList: incomeList)
        var categoryEntries:[PieChartDataEntry] = []
        for category in categories{
            let entry = PieChartDataEntry(value: Double(category.amount), label: incomeNames[category.label])
            categoryEntries.append(entry)
        }
        let PieDataSet = PieChartDataSet(entries: categoryEntries,label: "Income categories")
        PieDataSet.colors = ChartColorTemplates.colorful();
        PieDataSet.valueLinePart1Length = 0.2
        PieDataSet.valueLinePart2Length = 0.4
        PieDataSet.xValuePosition = .outsideSlice
        PieDataSet.sliceSpace = 2
        PieDataSet.valueLinePart1OffsetPercentage = 0.8
        PieDataSet.yValuePosition = .outsideSlice
        PieDataSet.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        let chartData = PieChartData(dataSet: PieDataSet)
        chartData.setValueTextColor(.black)
        pieChartView.data = chartData;
        //load Label
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .none
        let currencyType = currencyBase().symbol[currency]
        filterLabel.text = filterLabels[filterBy]
        totalLabel.text = currencyFormatter.string(from: NSNumber(value: total))! + currencyType
    }
    else{
        chooseTypeBtn.setTitle("Expense", for: .normal)
        var total:Float = 0
        var expenseList:[Expense] = []
        for record in recordList{
            if((record.expense) != nil && filterReportByDate(date: record.getDate(), by: filterBy) ){
                expenseList.append(Expense(value:record.expense!))
            }
        }
        for expense in expenseList{
            expense.amount = loadAmountByCurrency(value: expense.amount)
            total += expense.amount
        }
        let categories = totalOfCategory(expenseList: expenseList)
        var categoryEntries:[PieChartDataEntry] = []

        for category in categories{
            let entry = PieChartDataEntry(value: Double(category.amount), label: categorieNames[category.label])
            categoryEntries.append(entry)
        }
        let PieDataSet = PieChartDataSet(entries: categoryEntries,label: "Expense categories")
        PieDataSet.colors = ChartColorTemplates.colorful();
        PieDataSet.valueLinePart1Length = 0.2
        PieDataSet.valueLinePart2Length = 0.4
        PieDataSet.xValuePosition = .outsideSlice
        PieDataSet.sliceSpace = 2
        PieDataSet.valueLinePart1OffsetPercentage = 0.8
        PieDataSet.yValuePosition = .outsideSlice
        PieDataSet.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        let chartData = PieChartData(dataSet: PieDataSet)
        chartData.setValueTextColor(.black)
        pieChartView.data = chartData;
        
        //load Label
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .none
        let currencyType = currencyBase().symbol[currency]
        filterLabel.text = "Total Expense " + filterLabels[filterBy]
        totalLabel.text = currencyFormatter.string(from: NSNumber(value: total))! + currencyType
        
        
        
    }
    
    
}
override func viewDidLoad() {
    chooseTypeBtn.semanticContentAttribute = .forceRightToLeft
    chooseTypeBtn.clipsToBounds = true
    chooseTypeBtn.layer.cornerRadius = chooseTypeBtn.frame.width/8
    loadData()
    setting = settingObserve(user: userInfor!)
    settingObser = settingObserver(object: setting!)
    setting?.delegate = self
    pieChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
    pieChartView.entryLabelColor = .black
    pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
    pieChartView.legend.enabled = false
    drawChart()
    super.viewDidLoad()
}
    
    @IBOutlet weak var listCategory: UITableView!
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

   
}

func totalOfCategory(expenseList: [Expense])->[entry]{
    var entries:[entry] = [];
    var dict:[Int:Float] = [:]
    for expense in expenseList{
        if(dict[expense.category] == nil){
            dict[expense.category] = 0
        }
        dict[expense.category]! += expense.amount
    }
    for key in dict.keys{
        entries.append(entry(amount: dict[key]!, label: key))
    }
    return entries
}
func totalOfCategory(incomeList: [Income])->[entry]{
    var entries:[entry] = [];
    var dict:[Int:Float] = [:]
    for income in incomeList{
        if(dict[income.category] == nil){
            dict[income.category] = 0
        }
        dict[income.category]! += income.amount
    }
    for key in dict.keys{
        entries.append(entry(amount: dict[key]!, label: key))
    }
    return entries
}
