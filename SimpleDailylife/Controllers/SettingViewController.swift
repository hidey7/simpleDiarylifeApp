//protocol SettingViewControllerDelegate {
//    func settingView(settingViewController: SettingViewController)
//}


import UIKit

class SettingViewController: UITableViewController {
    
//    var delegate: SettingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "ExportCell", bundle: nil), forCellReuseIdentifier: "EXPORT")
        self.tableView.register(UINib(nibName: "PreviewSettingCell", bundle: nil), forCellReuseIdentifier: "PREVIEW")
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "EXPORT", for: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "PREVIEW", for: indexPath)
            cell.selectionStyle = .none
        default:
            break
        }
        return cell 
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "設定"
    }
    
    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "PRESENTEXPORTVC", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    


}
