//
//  ViewController.swift
//  Original_app
//
//  Created by 堀田環菜 on 2022/11/22.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    @IBOutlet var mainbutton: UIButton!
    
    
    @IBOutlet var datelabel: UILabel!
    
    var cityName: String!
    
    var my_latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var my_longitude: CLLocationDegrees!
    
    
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
        
        my_latitude = locationManager.location?.coordinate.latitude
        my_longitude = locationManager.location?.coordinate.longitude
        print(my_latitude)
        //天気を表示する
        //緯度軽度を入れる&サイトで発行したAP! keyを入れる。
        let text = "https://api.openweathermap.org/data/2.5/weather?lat=\((my_latitude)!)&lon=\((my_longitude)!)&units=metric&appid=755fc0d3fb63d97d10d070136977a4f7"
        //上のtextをurlの形に変換する。
        let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //APIをリクエスト
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
                    switch response.result {
                    case .success:
                        let json = JSON(response.data as Any)
                        print(json)

                        self .mainbutton.setTitle(String(describing: json["main"]["temp_max"].number!), for: .normal)
                    
                        //天気によって用意しておいた画像をセットしている。
                        /*
                        if self.descriptionWeather == "Clouds" {
                            self.tenkiImageView.image = UIImage(named: "kumori")
                        }else if self.descriptionWeather == "Rain" {
                            self.tenkiImageView.image = UIImage(named: "ame")
                        }else if self.descriptionWeather == "Snow"{
                            self.tenkiImageView.image = UIImage(named: "yuki.gif")
                        }else {
                            self.tenkiImageView.image = UIImage(named: "hare")
                        }
                         */

                        //最低気温とか色々やりたかったら以下のような感じで書く。
                        /*
                        self.max.text = "\(Int(json["main"]["temp_max"].number!).description)℃"
                        self.min.text = "\(Int(json["main"]["temp_min"].number!).description)℃"
                        self.taikan.text = "\(Int(json["main"]["temp"].number!).description)℃"
                        self.wind.text = "\(Int(json["wind"]["speed"].number!).description)m/s"
                         */

                    case .failure(let error):
                        self.mainbutton.titleLabel!.text = "データ取得失敗"
                    }
                }
       
        
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
    

   
            
    
        }

