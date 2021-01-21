//
//  chart2VC.swift
//  finalProject
//
//  Created by khanh tran on 1/20/21.
//

import UIKit
import RealmSwift
import Charts


class chart2VC: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    var type = -1
    var userInfor: User? = nil
    let realm = try! Realm()
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
        recordList.append(contentsOf: userInfor!.records)
    }
    func drawChart(){
        if (type == 1)
        {
            var incomeList:[Income] = []
            for record in recordList{
                if((record.income) != nil){
                    incomeList.append(record.income!)
                }
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
        }
        else{
            var expenseList:[Expense] = []
            for record in recordList{
                if((record.expense) != nil){
                    expenseList.append(record.expense!)
                }
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
        
        
    }
    override func viewDidLoad() {
        loadData()
        pieChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChartView.entryLabelColor = .black
        pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        pieChartView.legend.enabled = false
        drawChart()
        super.viewDidLoad()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
