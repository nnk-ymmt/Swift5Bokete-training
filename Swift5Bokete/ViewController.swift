//
//  ViewController.swift
//  Swift5Bokete
//
//  Created by 山本ののか on 2020/04/25.
//  Copyright © 2020 Nonoka Yamamoto. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import Photos

class ViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var odaiImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var count = 0
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        commentTextView.delegate = self
        commentTextView.layer.cornerRadius = 20.0
        PHPhotoLibrary.requestAuthorization { (status) in
            switch(status) {
                case .authorized: break
                case .denied: break
                case .notDetermined: break
                case .restricted: break
            }
        }
        DispatchQueue.global().async {
            self.getImages(keyword: "funny")
            DispatchQueue.main.async {
                self.indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                self.indicator.center = self.view.center
                self.indicator.hidesWhenStopped = true
                self.indicator.style = .large
                self.view.addSubview(self.indicator)
                self.indicator.startAnimating()
            }
        }
    }

    //検索キーワードの値を元に画像を引っ張ってくる
    //pixabay.com
    
    func getImages(keyword: String) {
        
        let url = "https://pixabay.com/api/?key=16225166-af44e4be5403ee2833169b4c6&q=\(keyword)"
        //Alamofireを使ってhttpリクエストを投げる
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
                case .success:
                    self.indicator.stopAnimating()
                    print(response)
                    let json:JSON = JSON(response.data as Any)
                    var imageString = json["hits"][self.count]["webformatURL"].string
                    if imageString == nil {
                        imageString = json["hits"][0]["webformatURL"].string
                        self.odaiImageView.sd_setImage(with: URL(string: imageString!), completed: nil)
                    } else {
                        self.odaiImageView.sd_setImage(with: URL(string: imageString!), completed: nil)
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    @IBAction func nextOdai(_ sender: Any) {
        
        count = count + 1
        if searchTextField.text == "" {
            getImages(keyword: "funny")
        } else {
            DispatchQueue.global().async{
              DispatchQueue.main.async{
                  self.getImages(keyword: self.searchTextField.text!)
                  self.indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                  self.indicator.center = self.view.center
                  self.indicator.hidesWhenStopped = true
                  self.indicator.style = .large
                  self.view.addSubview(self.indicator)
                  self.indicator.startAnimating()
              }
           }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        searchTextField.resignFirstResponder()
        commentTextView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchTextField.resignFirstResponder()
        getImages(keyword: searchTextField.text!)
        return true
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        self.count = 0
        if searchTextField.text == ""{
            getImages(keyword: "funny")
        }else{
            getImages(keyword: searchTextField.text!)
        }
    }
    
    @IBAction func next(_ sender: Any) {
        
        performSegue(withIdentifier: "next", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let shareVC = segue.destination as? ShareViewController
        shareVC?.commentString = commentTextView.text
        shareVC?.resultImage = odaiImageView.image!
    }
    
}

