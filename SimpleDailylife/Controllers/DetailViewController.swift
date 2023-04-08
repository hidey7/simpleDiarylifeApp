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
            self.titleString = selectedData?.title
            self.id = selectedData?.id
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = selectedData?.sentence
        self.textView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            textView.contentInset = contentInsets
            textView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !textView.text.isEmpty {
            if realm.object(ofType: DairyData.self, forPrimaryKey: self.id) == nil {
                save(dailyData: DairyData(title: self.titleString, sentence: textView.text, id: self.id))
            } else {
                update(with: textView.text)
            }
        }
    }
    
    
}


//MARK: - UITextView delegate methods
extension DetailViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
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
