//
//  HomeViewController.swift
//  Instagram
//
//  Created by Rsan on 2019/08/22.
//  Copyright © 2019 Rsan. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postArray: [PostData] = []
    
    //DatabaseのobserverEventの登録状況を表す
    
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)//xibの定義を読み込む下準備？
        tableView.register(nib, forCellReuseIdentifier: "Cell")//テーブルびゅーにxibに書かれた定義とかを登録？
        
        //テーブル業の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableView.automaticDimension
        //テーブル業の高さを概算値設定しておく
        //高さ概算値 = 「縦横比１：１のUITableViewの高さ（＝画面幅）」＋「イイネボタン、キャプションラベル、そのほか余白の高さの合計概算値（＝100pt）」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 150
 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil{
            if self.observing == false{
                //要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: {snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生")
                    
                    //PostDatalクラスを制せして受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myID: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                //要素が変更されたら、該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableviewを再表示する
                postsRef.observe(.childChanged, with: {snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました")
                    
                    if let uid = Auth.auth().currentUser?.uid{
                        //PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myID: uid)
                        
                        //保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray{
                            if post.id == postData.id{
                                index = self.postArray.firstIndex(of: post)!
                                break
                            }
                        }
                        
                        //差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        //削除したところに更新済みデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        //TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                //DatabaseのobserverEventが上記のコードにより登録されたため
                //trueとする
                observing = true
            }
        } else {
            if observing == true{
                //ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する
                //テーブルをクリアする
                postArray = []
                tableView.reloadData()
                
                //オブザーバーを削除する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.removeAllObservers()
                
                //DatabaseのobservarEventが上記のコードにより解除されたため
                //falseとする
                observing = false
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        //セル内のばたんアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        //PostTableViewCellのコメントボタン
        cell.inputComment.addTarget(self, action:#selector(commentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func commentButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT: commentボタンがタップされました")
        let Comment = self.storyboard?.instantiateViewController(withIdentifier: "Comment")
        
        //タップされたセルのインデックスを求める
        let touch2 = event.allTouches?.first
        let point2 = touch2!.location(in: self.tableView)
        let indexPath2 = tableView.indexPathForRow(at: point2)
        
        //配列からタップされたインデックスを求める
        let postData2 = postArray[indexPath2!.row]
        
       let inputCommentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as! InputCommentViewController
        inputCommentViewController.postData = postData2
        
        self.present(inputCommentViewController, animated: true, completion: nil)

    }
    
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT: likeボタンがタップされました")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスを求める
        let postData = postArray[indexPath!.row]
        
        //Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid{
            if postData.isLiked{
                //すでにいいねをしていた場合いいねを解除するためのIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        //削除するためにインデックスを保持
                        index = postData.likes.firstIndex(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            //増えたLikeをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
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
