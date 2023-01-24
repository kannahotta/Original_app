//
//  ViewController.swift
//  Original_app
//
//  Created by 堀田環菜 on 2022/11/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    @IBOutlet var mainbutton: UIButton!
    
    
    @IBOutlet var datelabel: UILabel!
    
    var cityName: String!
    @IBOutlet var locatelabel: UILabel!
    

    
    @IBAction func SecondView() {
        

    }
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        
        //メインボタンの角を丸くする
        mainbutton.layer.cornerRadius = 25
        mainbutton.clipsToBounds = true
      
        //日付ラベルの角を丸くする
        datelabel.layer.cornerRadius = 25
        datelabel.clipsToBounds = true
        
        //日付を表示させる
        let date = Date()
        print(date)
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "MM月dd日"
        
        print(dateFormatter.string(from: date))
        
        datelabel.text = dateFormatter.string(from: date)
     
        
        //位置ラベルの角を丸くする
        locatelabel.layer.cornerRadius = 25
        locatelabel.clipsToBounds = true
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
      
        
        
        
       // locationManager = CLLocationManager()
        locationManager.delegate = self
        
//        //アプリの使用中のみ許可
        locationManager.requestWhenInUseAuthorization()
//
//        //位置情報の取得精度を指定する
//        locationManager!.desiredAccuacy = CLLocationAccuracyBest
//
//        //更新に必要な最小移動距離
//        //Int値を指定することで、〇〇m間隔で取得するようになる
//        locationManager!.distanseFilter = 10
//
//        //位置情報取得開始
        locationManager.startUpdatingLocation()
//
//        locatelabel.text =
        
        
        
    }
    
    //map許可
        func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus) {// 許可を求めるためのdelegateメソッド
            switch status {
            case .notDetermined:// 許可されてない場合
                manager.requestWhenInUseAuthorization()// 許可を求める
            case .restricted, .denied:// 拒否されてる場合
                break// 何もしない
                
            case .authorizedWhenInUse: // 許可されている場合
                manager.startUpdatingLocation()// 現在地の取得を開始
                
                //市町村を取得
                CLGeocoder().reverseGeocodeLocation(locationManager.location!) { placemarks, error in
                    guard
                        let placemark = placemarks?.first, error == nil,
                        let locality = placemark.locality
                    else {
                        
                        return
                    }
                    self.cityName = locality
                    self.locatelabel.text = self.cityName!
                    
                }
                break
            default:
                break
            }
        }
        
        /* 位置情報取得失敗時に実行される関数 */
        func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
            // この例ではLogにErrorと表示するだけ．
            //アラート　位置情報をオンにしてください。って出す
            NSLog("Error")
        }
    
    //座標を取得する
    
    func manager.startUpdatingLocation()// 現在地の取得を開始
            
    
        }

