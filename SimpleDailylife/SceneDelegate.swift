import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        if let vc = window?.rootViewController {
            if vc.children.count == 1 {
                print("ListVCしかない！")
                let listVC = vc.children.first as! ListViewController
                DispatchQueue.main.async {
                    listVC.performSegue(withIdentifier: "toDetail", sender: nil)
                }
            }
        }
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunchKey"
        let firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        print(#function)
    }


}

