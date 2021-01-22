//
//  dashboardVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/19/21.
//

import UIKit
import RealmSwift
import ProgressHUD
import SCLAlertView
import Charts

class dashboardVC: UITableViewController,settingDelegate{
    
    @IBOutlet weak var hiMsg: UILabel!
    @IBOutlet weak var totalBalanceTF: UITextField!

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var moreBtn2: UIButton!
    @IBOutlet weak var moreBtn1: UIButton!
    
    @IBAction func moreHistory(_ sender: Any) {
        let sb = UIStoryboard(name: "report", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "chartType1VC") as chartType1VC
        dest.type = 0
        self.navigationController?.pushViewController(dest, animated: true)
    }
    @IBAction func moreReport(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "historyVC") as historyVC
        self.navigationController?.pushViewController(dest, animated: true)
    }
    @IBAction func toAddAccount(_ sender: Any) {
        let sb = UIStoryboard(name: "account", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "AddAccountView") as AddAccountView
        self.navigationController?.pushViewController(dest, animated: true)
        
    }
    @IBAction func changeHideAmount(_ sender: Any) {
        totalBalanceTF.isSecureTextEntry = !totalBalanceTF.isSecureTextEntry
    }
    
    func changedHideAmountValue(value: Bool) {
        totalBalanceTF.isSecureTextEntry = value
    }
    
    func changedCurrency(value: Int) {
        
    }
    

    @IBAction func clickSyncData(_ sender: Any) {
        ProgressHUD.show("Sync your data...")
        userInfor?.syncData()
        ProgressHUD.dismiss()
        SCLAlertView().showSuccess("Sync data successfully!", subTitle: "")
        return
    }
    let realm = try! Realm()
    var userInfor: User? = nil
    var currency = -1
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    var recordList: [polyRecord] = []
    
    var _balance: Float = 0
    
    func drawBarChart(){
        var incomeList:[Income]=[]
        var expenseList:[Expense]=[]
        var xStrings:[String]=[]
        for record in recordList{
            if(record.income != nil)
            {
                incomeList.append(Income(value:record.income))
            }
            else if(record.expense != nil)
            {
                expenseList.append(Expense(value: record.expense))
            }
            
        }
            for income in incomeList{
                income.amount = loadAmountByCurrency(value: income.amount)
            }
            for expense in expenseList{
                expense.amount = loadAmountByCurrency(value: expense.amount)
            }
            xStrings.append(String(Date().month(shortHand: false)))
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xStrings)
            
            let chartIncomeList = finalProject.totalIncome(incomeList: incomeList)
            let chartExpenseList = finalProject.totalExpense(expenseList: expenseList)

            var IncomeEntries:[BarChartDataEntry]=[]
            var ExpenseEntries:[BarChartDataEntry]=[]
            for income in chartIncomeList{
                let entry = BarChartDataEntry(x: Double(income.label), y: Double(income.amount))
                IncomeEntries.append(entry)
            }
            for expense in chartExpenseList{
                let entry = BarChartDataEntry(x: Double(expense.label), y: Double(expense.amount))
                ExpenseEntries.append(entry)
            }
            let IncomeDataSet = BarChartDataSet(entries: IncomeEntries, label: "income")
            IncomeDataSet.colors = [UIColor.green]
            IncomeDataSet.drawValuesEnabled = false
            let ExpenseDataSet = BarChartDataSet(entries: ExpenseEntries, label: "expense")
            ExpenseDataSet.colors = [UIColor.red]
            ExpenseDataSet.drawValuesEnabled = false
            let chartData = BarChartData(dataSets: [IncomeDataSet,ExpenseDataSet])
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
                    // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

            let groupCount = xStrings.count
            let startYear = 0


            chartData.barWidth = barWidth;
            barChartView.xAxis.axisMinimum = 0
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            print("Groupspace: \(gg)")
            barChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChartView.chartDescription?.text = "income vs expense "
            barChartView.data = chartData
        
        
        
    }
    func drawPieChart(){
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
        var expenseList:[Expense] = []
        for record in recordList{
            if((record.expense) != nil && filterReportByDate(date: record.getDate(), by: 1) ){
                expenseList.append(Expense(value:record.expense!))
            }
        }
        for expense in expenseList{
            expense.amount = loadAmountByCurrency(value: expense.amount)
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
        
        
    }
    func loadAmount(value: Float) -> Float
    {
        if currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[currency])
    }
    @IBAction func toNotify(_ sender: Any) {
        let sb = UIStoryboard(name: "other", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "notificationVC") as! notificationVC
        self.navigationController?.pushViewController(dest, animated: false)
    }
    func loadBalance() -> Float{
        var result:Float = 0.0
        for i in userInfor!.accounts
        {
            if i.type == 0
            {
                result += i.cashAcc!.balance
            }
            else if i.type == 1
            {
                result += i.bankingAcc!.balance
            }
            else if i.type == 2
            {
                result += i.savingAcc!.ammount
            }
        }
        return result
    }
    func loadData()
    {
        recordList = []
        userInfor = realm.objects(User.self)[0]
        currency = userInfor!.currency
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        recordList.append(contentsOf: userInfor!.records)
        setting?.delegate = self
        _balance = loadBalance()

    }
    func setData()  {
        hiMsg.text = "Hi \(userInfor?.displayName ?? "")!"
        totalBalanceTF.text = String(loadAmount(value: _balance)) + " \(currencyBase().symbol[currency])"
    }
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        moreBtn1.semanticContentAttribute = .forceLeftToRight
        moreBtn2.semanticContentAttribute = .forceLeftToRight
        loadData()
        barChartView.noDataText = "You need to provide data for the chart."
  


        //legend
        let legend = barChartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
        legend.yOffset = 10.0;
        legend.xOffset = 10.0;
        legend.yEntrySpace = 0.0;


        let xaxis = barChartView.xAxis
        xaxis.drawGridLinesEnabled = true
        xaxis.labelPosition = .bottom
        xaxis.centerAxisLabelsEnabled = true
        xaxis.granularity = 1


        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 1

        let yaxis = barChartView.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        setData()
        drawBarChart()
        pieChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChartView.entryLabelColor = .black
        pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        pieChartView.legend.enabled = false
        drawPieChart()
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            tableView.deselectRow(at: indexPath, animated: false)
        case 1:
            let sb = UIStoryboard(name: "report", bundle: nil)
            let dest = sb.instantiateViewController(identifier: "chartType1VC") as chartType1VC
            dest.type = 0
            self.navigationController?.pushViewController(dest, animated: true)
        case 2:
            let dest = (self.storyboard?.instantiateViewController(identifier: "historyVC"))! as historyVC
            self.navigationController?.pushViewController(dest, animated: true)
        default:
            print("no item")
        }

        
    }
    func loadAmountByCurrency(value: Float) -> Float
    {
        if userInfor?.currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[userInfor!.currency])
    }

    
}
