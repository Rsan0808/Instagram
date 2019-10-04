//
//  LoginViewController.swift
//  Instagram
//
//  Created by Rsan on 2019/08/22.
//  Copyright © 2019 Rsan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //ログインボタンがタップされた時に呼び出されるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName =  displayNameTextField.text{
            //アドレスかパスワードいずれかでも書かれていない時は、何もしない
            if address.isEmpty || password.isEmpty{
                SVProgressHUD.showError(withStatus: "必要事項を入力してください")
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.show()
            
            
            Auth.auth().signIn(withEmail: address, password: password){ user, error in
                if let error = error{
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()
                
                //画面を閉じてViewControllerに戻る
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    //アカウント作成ボタンが呼び出される時に呼び出されるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {

        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text{
            
            //アドレス、パスワード、表示名のいずれか一つでも表示されていない時、何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty{
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要事項を入力してください")
                return
            }
        
            //HUDで処理中を表示
            SVProgressHUD.show()
            
            //アドレスとパスワードでユーザー作成、ユーザー作成に成功すると自動でログイン
            Auth.auth().createUser(withEmail: address, password: password) { user, error in
            if let error = error{
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                    return
            }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
            
            //表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges{error in
                    if let error = error {
                        //プロフィールの更新でエラーが発生
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    
                    //HUDを消す
                    SVProgressHUD.dismiss()
                    
                    //画面を閉じてViewControllerに戻る
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
                
                
        }
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
