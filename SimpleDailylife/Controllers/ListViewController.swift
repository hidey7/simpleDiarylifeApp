import UIKit
import RealmSwift

class ListViewController: UITableViewController {
    
    private var dairyDatas: Results<DairyData>?
    private let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

//        loadDairyData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        loadDairyData()
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            
            let nextVC = segue.destination as! DetailViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //既にデータがある場合
                nextVC.selectedData = dairyDatas![indexPath.row]
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dairyDatas!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        let item = dairyDatas![indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }

    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }

    
    //MARK: - Realm methods
    private func loadDairyData() {
        
        dairyDatas = realm.objects(DairyData.self).sorted(byKeyPath: "id", ascending: false)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
}
