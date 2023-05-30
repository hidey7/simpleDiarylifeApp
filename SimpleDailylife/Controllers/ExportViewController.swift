import UIKit
import RealmSwift
import PDFKit

class ExportViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    
    var originalDatas: Results<DairyData>? 
    private let realm = try! Realm()
    
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func exportToPDF(_ sender: Any) {
        let sharedPDF = pdfView.document?.dataRepresentation()
        let items = [sharedPDF as Any] as [Any]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        self.loadDairyaData()
        if originalDatas?.count != 0 {
            
            shareButton.isEnabled = true
            let pdfData = self.createPDFData()
            let pdfDocument = PDFDocument(data: pdfData)
            self.pdfView.autoScales = true
            self.pdfView.displayDirection = .vertical
            self.pdfView.displaysPageBreaks = true
            self.pdfView.document = pdfDocument
            
        } else {
            
            shareButton.isEnabled = false
            
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    private func createPDFData() -> Data {
        
        //A4 Aspect
        let pdfWidth: CGFloat = 2100
        let pdfHeight: CGFloat = 2900
        
        let pageRect = CGRect(x: 0, y: 0, width: pdfWidth, height: pdfHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            
            for oneData in originalDatas! {
                
                context.beginPage()
                let title = oneData.title
                let titleAttributes = [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 100)
                ]
                let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
                attributedTitle.draw(at: CGPoint(x: 70, y: 30))
                
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: 70, y: 150))
                linePath.addLine(to: CGPoint(x: 910, y: 150))
                
                let layer = CAShapeLayer()
                layer.path = linePath.cgPath
                layer.fillColor = UIColor.black.cgColor
                layer.strokeColor = UIColor.black.cgColor
                layer.lineWidth = 5.0
                layer.render(in: context.cgContext)

                let text = oneData.sentence
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                let textAttributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 54),
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]
                let textRect = CGRect(x: 100, y: 200, width: 1900, height: 2700) //テキストを描画する領域を設定
                
                if text.count > 1515 {
                    let startIndex = text.startIndex
                    let range1 = text.index(startIndex, offsetBy: 0)..<text.index(startIndex, offsetBy: 1515)
                    let range2 = text.index(startIndex, offsetBy: 1515)..<text.index(startIndex, offsetBy: text.count)
                    let text1 = text[range1]
                    let attributedText1 = NSAttributedString(string: String(text1), attributes: textAttributes)
                    
                    let text2 = text[range2]
                    let attributedText2 = NSAttributedString(string: String(text2), attributes: textAttributes)
                    
                    attributedText1.draw(in: textRect)
                    
                    context.beginPage()
                    attributedText2.draw(in: textRect)
                    
                } else {
                    let attributedString = NSAttributedString(string: text, attributes: textAttributes)
                    attributedString.draw(in: textRect)
                }
                
            }
            
        }
        
        return data
        
    }
    
    
    
    //MARK: - Realm methods
    private func loadDairyaData() {
        originalDatas = realm.objects(DairyData.self).sorted(byKeyPath: "id", ascending: true)
    }
    


}
