import UIKit
import RealmSwift

class ListViewController: UITableViewController {
    
    private var dairyDatas: Results<DairyData>?
    private let realm = try! Realm()

    private var classifiedData : [SectionData?] = []
    
//    @IBAction func printData(_ sender: UIBarButtonItem) {
//        for dairyData in dairyDatas! {
//            print(dairyData)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
       
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            tableView.contentInset = UIEdgeInsets(top: navBarHeight * 0.5, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDairyData()
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
        cell.previewString = item?.sentence
        cell.titleString = String(item!.title.suffix(5))
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return classifiedData[section]?.title
    }
    
    //スワイプでセル削除
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let id = dairyDatas!.count - (indexPath.row + 1)
            
            let deleteData = dairyDatas![indexPath.row]
            try! realm.write {
                realm.delete(deleteData)
            }
            
            if indexPath.row != 0 {
                
                for i in 1...indexPath.row {
                    
                    let newData = DairyData()
                    newData.title = dairyDatas![indexPath.row - i].title
                    newData.sentence = dairyDatas![indexPath.row - i].sentence
                    newData.id = id + (i - 1)
                    try! realm.write {
                        realm.add(newData, update: .modified)
                        realm.delete(dairyDatas![indexPath.row - i])
                    }
                    
                }
                
            }
            
            dairyDatas = realm.objects(DairyData.self).sorted(byKeyPath: "id", ascending: false)
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
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
