import UIKit
import RealmSwift

class ListViewController: UITableViewController {
    
    private var dairyDatas: Results<DairyData>?
    private let realm = try! Realm()
    
    private var testDatas: Results<DairyData>?

    private var classifiedData : [SectionData?] = []
    
    @IBAction func printData(_ sender: UIBarButtonItem) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(doSomething), name: AppSettings.notifyName, object: nil)

        self.tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
       
        
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            tableView.contentInset = UIEdgeInsets(top: navBarHeight * 0.5, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    @objc func doSomething() {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDairyData()
//        makeArrayForTest()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            
            let nextVC = segue.destination as! DetailViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //既にデータがある場合
                nextVC.selectedData = classifiedData[indexPath.section]?.datas[indexPath.row]
            } else {
                //データを新規作成した場合
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                formatter.locale = Locale(identifier: "ja_JP")
                let titleString = formatter.string(from: Date())
                nextVC.titleString = titleString
                nextVC.id = dairyDatas?.count
            }
        }
    }
    

    @IBAction func createNewDetailVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return classifiedData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classifiedData[section]!.datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
        let item = classifiedData[indexPath.section]?.datas[indexPath.row]
        
        if AppSettings.shared.previewIsHidden == true {
            cell.previewLabel.isHidden = true
            cell.titleString = String(item!.title.suffix(5))
            cell.layoutIfNeeded()
        } else {
            cell.previewLabel.isHidden = false
            cell.previewString = item?.sentence
            cell.titleString = String(item!.title.suffix(5))
            cell.layoutIfNeeded()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return classifiedData[section]?.title
    }
    
    private func getNumberOfDatasInSections(section: inout Int) -> Int {
        
        var number = 0
        if section == 0 {
            return 0
        }
        
        for i in 0..<section {
            number += (classifiedData[section - (i+1)]?.datas.count)!
        }
        
        return number
        
    }
    
    //スワイプでセル削除
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            var section = indexPath.section
            let numberOfDatasInPreviousSections = getNumberOfDatasInSections(section: &section)
            let id = dairyDatas!.count - (numberOfDatasInPreviousSections + (indexPath.row + 1))
            
            let deleteData = dairyDatas![numberOfDatasInPreviousSections + indexPath.row]
            try! realm.write {
                realm.delete(deleteData)
            }
            
            if (numberOfDatasInPreviousSections + indexPath.row) != 0 {
                
                for i in 1...(numberOfDatasInPreviousSections + indexPath.row) {
                    
                    let newData = DairyData()
                    newData.title = dairyDatas![(numberOfDatasInPreviousSections + indexPath.row) - i].title
                    newData.sentence = dairyDatas![(numberOfDatasInPreviousSections + indexPath.row) - i].sentence
                    newData.id = id + (i - 1)
                    try! realm.write {
                        realm.add(newData, update: .modified)
                        realm.delete(dairyDatas![(numberOfDatasInPreviousSections + indexPath.row) - i])
                    }
                    
                }
                
            }
            
            dairyDatas = realm.objects(DairyData.self).sorted(byKeyPath: "id", ascending: false)
            classifyData(dairyDatas: dairyDatas)
            if classifiedData.count != tableView.numberOfSections {
                tableView.deleteSections(IndexSet([indexPath.section]), with: .fade)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
    }
    
    
    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }

    
    //MARK: - Realm methods
    private func loadDairyData() {
        
        dairyDatas = realm.objects(DairyData.self).sorted(byKeyPath: "id", ascending: false)
        classifyData(dairyDatas: dairyDatas)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    private func classifyData(dairyDatas: Results<DairyData>?) {
        

        classifiedData = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let secondFormatter = DateFormatter()
        secondFormatter.dateFormat = "yyyy/MM/dd"
        

        var oldDateString: String?
        var i = 0
        for dairyData in dairyDatas! {
            let date1 = dateFormatter.date(from: dairyData.title) //Date
            let newDate = secondFormatter.string(from: date1!) //String
            
            if let oldDate = oldDateString {
                if newDate == oldDate {
                    classifiedData[i]?.datas.append(dairyData)
                } else {
                    i += 1
                    classifiedData.append(SectionData(datas: [dairyData], title: newDate))
                }
                
            } else {
                //一つ目の配列を作る
                //for文の初め
                classifiedData.append(SectionData(datas: [dairyData], title: newDate))
            }
            
            oldDateString = newDate
            
        }
    }
    
    
}


//MARK: - Extension for TEST
//extension ListViewController {
//
//    func makeArrayForTest() {
//
//        try! realm.write {
//            realm.deleteAll()
//        }
//
//        save(dairyData: DairyData(title: "2023/03/13 13:13", sentence: "first", id: 0))
//        save(dairyData: DairyData(title: "2023/03/14 14:14", sentence: "second", id: 1))
//        save(dairyData: DairyData(title: "2023/03/15 15:15", sentence: "third", id: 2))
//
//        dairyDatas = realm.objects(DairyData.self).sorted(byKeyPath: "id", ascending: false)
//        classifyData(dairyDatas: dairyDatas)
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//
//    }
//
//    private func save(dairyData: DairyData) {
//        do {
//            try realm.write {
//                realm.add(dairyData)
//            }
//        } catch {
//            print("Saving error, \(error)")
//        }
//    }
//
//}
