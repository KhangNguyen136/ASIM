//
//  chartType3.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/21/21.
//

import UIKit
import RealmSwift
import Charts
import DropDown


struct locationRecord{
    var income:Float=0
    var expense:Float=0
    var transfer:Float=0
    var adjust:Float=0
}
struct PeopleRecord{
    var income:Float=0
    var expense:Float=0
}
class chartType3VC: UITableViewController, settingDelegate {

    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    
    @IBOutlet weak var mostEx: UILabel!
    @IBOutlet weak var mostIn: UILabel!
    
    var filterBy = 1
    @IBOutlet weak var filterBtn: UIButton!
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
        dropDown.anchorView = (sender as! AnchorView) // UIView or UIBarButtonItem
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Expense vs Income","Lend vs Borrrow","Expense","Income","Location","Person"]
        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            if index - 4 != self?.type
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
    @IBOutlet weak var barChartView: BarChartView!
    var type = -1
    var currency:Int = 1
    var userInfor: User? = nil
    let realm = try! Realm()
    var recordList: [polyRecord] = []
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        currency = userInfor!.currency
        recordList.append(contentsOf: userInfor!.records)
    }
   


    func drawChart(){
        if(type==0){
            
        var locationDict:[String:locationRecord]=[:]
        var incomeEntries:[BarChartDataEntry]=[]
        var expenseEntries:[BarChartDataEntry]=[]
        var transferEntries:[BarChartDataEntry]=[]
        var adjustEntries:[BarChartDataEntry]=[]
        var locationStrings:[String]=[]
        for record in recordList{
            if(record.income?.location != nil && record.income?.location != "" && filterReportByDate(date: record.getDate(), by: filterBy))
            {
                if(locationDict[record.income!.location] == nil){
                    locationDict[record.income!.location] = locationRecord()
                }
                locationDict[record.income!.location]!.income += loadAmountByCurrency(value:record.income!.amount)
            }
            else if(record.expense?.location != nil && record.expense?.location != "" && filterReportByDate(date: record.getDate(), by: filterBy))
            {
                if(locationDict[record.expense!.location] == nil){
                    locationDict[record.expense!.location] = locationRecord()

                }
                locationDict[record.expense!.location]?.expense += loadAmountByCurrency(value: record.expense!.amount)
            
            }
            else if(record.transfer?.location != nil && record.transfer?.location != "" && filterReportByDate(date: record.getDate(), by: filterBy))
            {
                if(locationDict[record.transfer!.location] == nil){
                    locationDict[record.transfer!.location] = locationRecord()

                }
                locationDict[record.transfer!.location]?.transfer += loadAmountByCurrency(value: record.transfer!.amount)
            }
            else if(record.adjustment?.location != nil && record.adjustment?.location != "" && filterReportByDate(date: record.getDate(), by: filterBy))
            {
                if(locationDict[record.adjustment!.location] == nil){
                    locationDict[record.adjustment!.location] = locationRecord()
                }
                locationDict[record.adjustment!.location]?.adjust += loadAmountByCurrency(value: record.adjustment!.different)

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
            let mostSpent = locationDict.max(by: {a,b in a.value.expense < b.value.expense})
            let mostEarn = locationDict.max(by: {a,b in a.value.income < b.value.income})
            if mostEarn != nil
            {
                mostIn.text = mostEarn!.key + " ( \(mostEarn!.value.income) " + currencyBase().symbol[currency] + " )"
            }
            if mostEx != nil
            {
            mostEx.text = mostSpent!.key + " ( \(mostSpent!.value.expense) " + currencyBase().symbol[currency] + " )"
            }
        
        }
        else
        {
            title1.text = "Most payee: "
            title2.text = "Most payer: "
            var peopleDict:[String:PeopleRecord]=[:]
            var peopleString:[String]=[]
            var incomeEntries:[BarChartDataEntry]=[]
            var expenseEntries:[BarChartDataEntry]=[]
            for record in recordList{
                if(record.getPerson() != "" && filterReportByDate(date: record.getDate(), by: filterBy) && record.income != nil)
                {
                    if(peopleDict[record.getPerson()] == nil){
                        peopleDict[record.getPerson()] = PeopleRecord()
                    }
                    peopleDict[record.getPerson()]!.income += loadAmountByCurrency(value:record.income!.amount)
                }
                else if(record.getPerson() != "" && filterReportByDate(date: record.getDate(), by: filterBy) && record.expense != nil)
                {
                    if(peopleDict[record.getPerson()] == nil){
                        peopleDict[record.getPerson()] = PeopleRecord()

                    }
                    peopleDict[record.getPerson()]?.expense += loadAmountByCurrency(value: record.expense!.amount)
                
                }
            }
            var i = 0;
            for name in peopleDict.keys{
                peopleString.append(name)
                incomeEntries.append(BarChartDataEntry(x: Double(i), y: Double(peopleDict[name]!.income)))
                expenseEntries.append(BarChartDataEntry(x: Double(i), y: Double(peopleDict[name]!.expense)))
                i += 1
                
            }
            let incomeDataSet = BarChartDataSet(entries: incomeEntries, label: "income")
            incomeDataSet.colors = [UIColor.green]
            let expenseDataSet = BarChartDataSet(entries: expenseEntries, label: "expense")
            expenseDataSet.colors = [UIColor.red]
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:peopleString)
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
                    // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

            let groupCount = peopleString.count
            let startYear = 0

            let chartData = BarChartData(dataSets: [incomeDataSet,expenseDataSet])
            chartData.barWidth = barWidth;
            barChartView.xAxis.axisMinimum = 0
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChartView.xAxis.labelCount = groupCount
            barChartView.chartDescription?.text = "Person"
            barChartView.data = chartData
            let mostSpent = peopleDict.max(by: {a,b in a.value.expense < b.value.expense})
            let mostEarn = peopleDict.max(by: {a,b in a.value.income < b.value.income})
            if mostEarn != nil
            {
            mostIn.text = mostEarn!.key + " ( \(mostEarn!.value.income) " + currencyBase().symbol[currency] + " )"
            }
            if mostEx != nil
            {
            mostEx.text = mostSpent!.key + " ( \(mostSpent!.value.expense) " + currencyBase().symbol[currency] + " )"
            }
        }
        
    }

    override func viewDidLoad() {
        loadData()
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        chooseTypeBtn.semanticContentAttribute = .forceRightToLeft
        chooseTypeBtn.clipsToBounds = true
        chooseTypeBtn.layer.cornerRadius = chooseTypeBtn.frame.width/8
        if type == 0{
            chooseTypeBtn.setTitle("Location", for: .normal)
        }
        else
        {
            chooseTypeBtn.setTitle("Person", for: .normal)

        }

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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    func loadAmountByCurrency(value: Float) -> Float
    {
        if userInfor?.currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[userInfor!.currency])
    }
    func changedHideAmountValue(value: Bool) {
        
    }
    
    func changedCurrency(value: Int) {
        currency = value
        drawChart()
        
    }

}
