import Foundation
import RealmSwift

class DairyData: Object {
    @Persisted var title: String = ""
    @Persisted var sentence: String = ""
    
    @Persisted(primaryKey: true) var id: Int!
    
    convenience init(title: String, sentence: String, id: Int) {
        self.init()
        self.title = title
        self.sentence = sentence
        self.id = id
    }
    
}
