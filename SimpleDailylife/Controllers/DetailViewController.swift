import UIKit
import RealmSwift

class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    private let realm = try! Realm()
    var titleString: String! {
        didSet {
            self.title = titleString
        }
    }
    
    var id: Int!
    
    var selectedData: DairyData? {
        didSet {
            print("unko")
            self.titleString = selectedData?.title
            self.id = selectedData?.id
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        self.textView.text = selectedData?.sentence
        self.textView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }

}


//MARK: - UITextView delegate methods
extension DetailViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print(#function)
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print(#function)
        if !textView.text.isEmpty {
            
            if realm.object(ofType: DairyData.self, forPrimaryKey: self.id) == nil {
                save(dailyData: DairyData(title: self.titleString, sentence: textView.text, id: self.id))
            } else {
                update(with: textView.text)
            }
            
        }
        //ここで文章を保存。NavigationVCのrootに戻る時に発動。
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
    }
    

    //MARK: - Realm methods
    private func save(dailyData: DairyData) {
        do {
            try realm.write {
                realm.add(dailyData)
            }
        } catch {
            print("Saving error, \(error)")
        }
    }
    
    private func update(with sentence: String) {
        do {
            try realm.write {
                self.selectedData?.sentence = sentence
            }
        } catch {
            print("Updating error, \(error)")
        }
    }
    
   
}
