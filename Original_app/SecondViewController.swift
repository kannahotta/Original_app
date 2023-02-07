//
//  SecondViewController.swift
//  Original_app
//
//  Created by 堀田環菜 on 2022/11/29.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

class SecondViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet var locatelabel2: UILabel!
    
    @IBOutlet var weatherlabel: UILabel!
    
    var cityName: String!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager.startUpdatingLocation()
        
    }
    
    
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
                self.locatelabel2.text = self.cityName!
                
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
        
        //位置情報取得開始
                
    }
}
