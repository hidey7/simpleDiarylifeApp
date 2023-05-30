//
//  AppSettings.swift
//  SimpleDailylife
//
//  Created by 始関秀弥 on 2023/05/23.
//

import Foundation
import UIKit

final class AppSettings {
    
    static let shared = AppSettings()
    static let notifyName = Notification.Name("switch")
    
    var previewIsHidden = Bool()
    
    private init() {
        if UserDefaults.standard.object(forKey: "previewIsHidden") == nil {
            UserDefaults.standard.setValue(false, forKey: "previewIsHidden")
        } else {
            self.previewIsHidden = UserDefaults.standard.bool(forKey: "previewIsHidden")
        }
    }
    
    public static func switchPreviewState() {
        self.shared.previewIsHidden = !self.shared.previewIsHidden
        UserDefaults.standard.set(self.shared.previewIsHidden, forKey: "previewIsHidden")
        NotificationCenter.default.post(name: self.notifyName, object: nil)
    }
    
    
}
