//
//  InputCommentViewController.swift
//  Instagram
//
//  Created by Rsan on 2019/10/02.
//  Copyright © 2019 Rsan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class InputCommentViewController: UIViewController {
    
    var postData:PostData?
 

    @IBOutlet weak var commentTextView: UITextView!

   
    
    //コメントを投稿するボタン
    @IBAction func postComment(_ sender: Any) {
        // 辞書を作成してFirebaseに保存する
        if Auth.auth().currentUser != nil{
        if  let comment: String = commentTextView.text!{
            if comment != nil {
                let name: String! = Auth.auth().currentUser?.displayName
                
                postData!.comments.append(name + ":" + comment)
               
                
                let postRef = Database.database().reference().child(Const.PostPath).child(postData!.id!)
                let comments = ["comments": postData!.comments]
                postRef.updateChildValues(comments)
                
                
                
                
                
                
                // HUDで投稿完了を表示する
                SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました")
                print(postData!.comments)
                //元の画面へ
                self.dismiss(animated: true, completion: nil)
            }
        
        }
        
        }
    }
    
    //コメントをキャンセルする
    @IBAction func cancelCommentButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
