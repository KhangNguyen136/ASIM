//
//  chart3VC.swift
//  finalProject
//
//  Created by khanh tran on 1/20/21.
//

import UIKit
import RealmSwift
import Charts
struct locationRecord{
    var income:Float=0
    var expense:Float=0
    var transfer:Float=0
    var adjust:Float=0
}
class chart3VC: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    var type = -1
    var userInfor: User? = nil
    let realm = try! Realm()
    var recordList: [polyRecord] = []
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        recordList.append(contentsOf: userInfor!.records)
    }
    var locationDict:[String:locationRecord]=[:]
    var locationStrings:[String]=[]
    var incomeEntries:[BarChartDataEntry]=[]
    var expenseEntries:[BarChartDataEntry]=[]
    var transferEntries:[BarChartDataEntry]=[]
    var adjustEntries:[BarChartDataEntry]=[]
    func drawChart(){
        for record in recordList{
            if(record.income?.location != nil && record.income?.location != "")
            {
                if(locationDict[record.income!.location] == nil){
                    locationDict[record.income!.location] = locationRecord()
                }
                locationDict[record.income!.location]!.income += record.income!.amount
            }
            else if(record.expense?.location != nil && record.expense?.location != "")
            {
                if(locationDict[record.expense!.location] == nil){
                    locationDict[record.expense!.location] = locationRecord()

                }
                locationDict[record.expense!.location]?.expense += record.expense!.amount
            
            }
            else if(record.transfer?.location != nil && record.transfer?.location != "")
            {
                if(locationDict[record.transfer!.location] == nil){
                    locationDict[record.transfer!.location] = locationRecord()

                }
                locationDict[record.transfer!.location]?.transfer += record.transfer!.amount
            }
            else if(record.adjustment?.location != nil && record.adjustment?.location != "")
            {
                if(locationDict[record.adjustment!.location] == nil){
                    locationDict[record.adjustment!.location] = locationRecord()
                }
                locationDict[record.adjustment!.location]?.adjust += record.adjustment!.amount

            }
        }
        var i = 0;
        for location in locationDict.keys{
            locationStrings.append(location)
            incomeEntries.append(BarChartDataEntry(x: Double(i), y: Double(locationDict[location]!.income)))
            expenseEntries.append(BarChartDataEntry(x: Double(i), y: Double(locationDict[location]!.expense)))
            transferEntries.append(BarChartDataEntry(x: Double(i), y: Double(locationDict[location]!.transfer)))
            adjustEntries.append(BarChartDataEntry(x: Double(i), y: Double(locationDict[location]!.adjust)))
            i += 1
            
        }
        print(locationDict)
        let incomeDataSet = BarChartDataSet(entries: incomeEntries, label: "income")
        incomeDataSet.colors = [UIColor.green]
        let expenseDataSet = BarChartDataSet(entries: expenseEntries, label: "expense")
        expenseDataSet.colors = [UIColor.red]
        let transferDataSet = BarChartDataSet(entries: transferEntries, label: "transfer")
        transferDataSet.colors = [UIColor.purple]
        let adjustDataSet = BarChartDataSet(entries: adjustEntries, label: "adjustment")
        adjustDataSet.colors = [UIColor.blue]
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:locationStrings)
        let groupSpace = 0.18
        let barSpace = 0.02
        let barWidth = 0.2
                // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

        let groupCount = locationStrings.count
        let startYear = 0

        let chartData = BarChartData(dataSets: [incomeDataSet,expenseDataSet,transferDataSet,adjustDataSet])
        chartData.barWidth = barWidth;
        barChartView.xAxis.axisMinimum = 0
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        print("Groupspace: \(gg)")
        barChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        barChartView.xAxis.labelCount = groupCount
        barChartView.chartDescription?.text = "location"
        barChartView.data = chartData

        
        
    }
    override func viewDidLoad() {
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
        drawChart()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
