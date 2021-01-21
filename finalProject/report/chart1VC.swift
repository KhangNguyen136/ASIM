//
//  chart1VC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/19/21.
//

import UIKit
import RealmSwift
import Charts
struct entry{
    var amount:Float
    var label: Int
}

class chart1VC: UIViewController {

    @IBOutlet weak var barChart: BarChartView!
    var type = -1
    var userInfor: User? = nil
    let realm = try! Realm()
    var recordList: [polyRecord] = []
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        recordList.append(contentsOf: userInfor!.records)
        
    }
    func drawChart(){
        let xStrings:[String]=["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec","test"]
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:xStrings)
        if (type == 0)
        {
            var expenseList:[Expense] = []
            var incomeList:[Income] = []
            for record in recordList{
                if((record.expense) != nil){
                    expenseList.append(record.expense!)
                }
                else if(record.income != nil){
                    incomeList.append(record.income!)
                }
            }
            var chartIncomeList = totalOfMonths(incomeList: incomeList)
            var chartExpenseList = totalOfMonths(expenseList: expenseList)
            chartIncomeList = chartIncomeList.sorted(by: {(s1:entry,s2:entry)->Bool in return s1.label < s2.label})
            chartExpenseList = chartExpenseList.sorted(by: {(s1:entry,s2:entry)->Bool in return s1.label < s2.label})
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

            let groupCount = 12
            let startYear = 0


            chartData.barWidth = barWidth;
            barChart.xAxis.axisMinimum = 0
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            print("Groupspace: \(gg)")
            barChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChart.chartDescription?.text = "income vs expense "
            barChart.data = chartData
        }
        else{
            var lendList:[Lend] = []
            var borrowList:[Borrow] = []
            for record in recordList{
                if((record.lend) != nil){
                    lendList.append(record.lend!)
                }
                else if(record.borrow != nil){
                    borrowList.append(record.borrow!)
                }
            }
            var chartBorrowList = totalOfMonths(borrowList: borrowList)
            var chartLendList = totalOfMonths(lendList: lendList)
            chartLendList = chartLendList.sorted(by: {(s1:entry,s2:entry)->Bool in return s1.label < s2.label})
            chartBorrowList = chartBorrowList.sorted(by: {(s1:entry,s2:entry)->Bool in return s1.label < s2.label})
            var LendEntries:[BarChartDataEntry]=[]
            var BorrowEntries:[BarChartDataEntry]=[]
            for lend in chartLendList{
                let entry = BarChartDataEntry(x: Double(lend.label), y: Double(lend.amount))
                LendEntries.append(entry)
            }
            for borrow in chartBorrowList{
                let entry = BarChartDataEntry(x: Double(borrow.label), y: Double(borrow.amount))
                BorrowEntries.append(entry)
            }
            let lendDataSet = BarChartDataSet(entries: LendEntries, label: "lend")
            lendDataSet.colors = [UIColor.green]
            lendDataSet.drawValuesEnabled = false
            let borrowDataSet = BarChartDataSet(entries: BorrowEntries, label: "borrow")
            borrowDataSet.colors = [UIColor.red]
            borrowDataSet.drawValuesEnabled = false
            let chartData = BarChartData(dataSets: [lendDataSet,borrowDataSet])
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
                    // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

            let groupCount = 12
            let startYear = 0


            chartData.barWidth = barWidth;
            barChart.xAxis.axisMinimum = 0
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            print("Groupspace: \(gg)")
            barChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChart.chartDescription?.text = "lend vs borrow "
            barChart.data = chartData
        }
        
    }
    
    override func viewDidLoad() {
        loadData()
                    barChart.noDataText = "You need to provide data for the chart."
              


                    //legend
                    let legend = barChart.legend
                    legend.enabled = true
                    legend.horizontalAlignment = .right
                    legend.verticalAlignment = .top
                    legend.orientation = .vertical
                    legend.drawInside = true
                    legend.yOffset = 10.0;
                    legend.xOffset = 10.0;
                    legend.yEntrySpace = 0.0;


                    let xaxis = barChart.xAxis
                    xaxis.drawGridLinesEnabled = true
                    xaxis.labelPosition = .bottom
                    xaxis.centerAxisLabelsEnabled = true
                    xaxis.granularity = 1


                    let leftAxisFormatter = NumberFormatter()
                    leftAxisFormatter.maximumFractionDigits = 1

                    let yaxis = barChart.leftAxis
                    yaxis.spaceTop = 0.35
                    yaxis.axisMinimum = 0
                    yaxis.drawGridLinesEnabled = false
                    xaxis.labelCount = 12
                    barChart.rightAxis.enabled = false
        drawChart()
        super.viewDidLoad()

        

        // Do any additional setup after loading the view.
    }
    

}
func totalOfMonths(incomeList:[Income])->[entry]{
    var dict:[Int:Float] = [:]
    var chartData:[entry]=[]
    let today = Date().get(.day,.month,.year);
    for i in 0...11{
        dict[i] = 0
    }
    for income in incomeList{
        let expenseDate = income.date.get(.day,.month,.year)
        if(expenseDate.year == today.year){
            
            dict[expenseDate.month!-1]! += income.amount;
        }
        
    }
    for key in dict.keys{
        chartData.append(entry(amount: dict[key]!, label: key))
    }
    return chartData
}
func totalOfMonths(borrowList:[Borrow])->[entry]{
    var dict:[Int:Float] = [:]
    var chartData:[entry]=[]
    let today = Date().get(.day,.month,.year);
    for i in 0...11{
        dict[i] = 0
    }
    for income in borrowList{
        let expenseDate = income.date.get(.day,.month,.year)
        if(expenseDate.year == today.year){
            
            dict[expenseDate.month!-1]! += income.amount;
        }
        
    }
    for key in dict.keys{
        chartData.append(entry(amount: dict[key]!, label: key))
    }
    return chartData
}
func totalOfMonths(lendList:[Lend])->[entry]{
    var dict:[Int:Float] = [:]
    var chartData:[entry]=[]
    let today = Date().get(.day,.month,.year);
    for i in 0...11{
        dict[i] = 0
    }
    for income in lendList{
        let expenseDate = income.date.get(.day,.month,.year)
        if(expenseDate.year == today.year){
            
            dict[expenseDate.month!-1]! += income.amount;
        }
        
    }
    for key in dict.keys{
        chartData.append(entry(amount: dict[key]!, label: key))
    }
    return chartData
}
func totalOfMonths(expenseList:[Expense])->[entry]{
    var dict:[Int:Float] = [:]
    var chartData:[entry]=[]
    let today = Date().get(.day,.month,.year);
    for i in 0...11{
        dict[i] = 0
    }
    for income in expenseList{
        let expenseDate = income.date.get(.day,.month,.year)
        if(expenseDate.year == today.year){
            
            dict[expenseDate.month!-1]! += income.amount;
        }
        
    }
    for key in dict.keys{
        chartData.append(entry(amount: dict[key]!, label: key))
    }
    return chartData
}
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

