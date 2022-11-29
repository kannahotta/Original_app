//
//  ViewController.swift
//  Original_app
//
//  Created by 堀田環菜 on 2022/11/22.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    @IBOutlet var mainbutton: UIButton!
    
    
    @IBOutlet var datelabel: UILabel!
    
    
    @IBOutlet var locatelabel: UILabel!
    

    
    @IBAction func SecondView() {
        
        
        
        
    }
    

    override func viewDidLoad() {
        
        //メインボタンの角を丸くする
        mainbutton.layer.cornerRadius = 25
        mainbutton.clipsToBounds = true
      
        //日付ラベルの角を丸くする
        datelabel.layer.cornerRadius = 25
        datelabel.clipsToBounds = true
        
        //日付を表示させる
        let date = Date()
        let dateFormatter = DateFormatter();
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMdHms")
        
        print(dataFormatterstring(from: dt))
        
        
        //位置ラベルの角を丸くする
        locatelabel.layer.cornerRadius = 25
        locatelabel.clipsToBounds = true
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

