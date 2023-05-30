//
//  SecondViewController.swift
//  Original_app
//
//  Created by 堀田環菜 on 2023/04/18.
//

import UIKit
import CoreMotion
import SwiftyJSON
import Alamofire
import CoreLocation


class SecondViewController: UIViewController {
    
    @IBOutlet weak var compassImageView: UIImageView!
    
    var lastRotation: CGFloat = 0
    //スムーズに動かすために用意しているよ。CADisplayLinkはアニメーションや画面の更新処理をスムーズにさせたい時に使うよん。
    var displayLink: CADisplayLink?
    var targetRotation: CGFloat = 0
    var currentRotation: CGFloat = 0
    
    var my_latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var my_longitude: CLLocationDegrees!
    
    // 1時間ごとの気温情報を保存する配列
    var hourlyTemperatures: [Double] = []
    
    override func viewDidLoad() {
        
        var locationManager = CLLocationManager()
        
        locationManager.delegate = self
        
        // アプリの使用中のみ許可
        locationManager.requestWhenInUseAuthorization()
        
        // 位置情報の取得精度を指定する
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 更新に必要な最小移動距離
        // Int値を指定することで、〇〇m間隔で取得するようになる
        locationManager.distanceFilter = 10
        
        // 位置情報取得開始
        locationManager.startUpdatingLocation()
        
        
        super.viewDidLoad()
        
        // UIPanGestureRecognizerを作成して、ビューに追加する
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateCompass(_:)))
        compassImageView.addGestureRecognizer(panGesture)
        
        //CADisplayLinkのインスタンスを作成！updateRotationメソッドを呼び出すように設定
        //インスタンスって何？については、別で送ったのを見てねー。
        displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
        // displayLinkをメインスレッドのRunLoopに追加し、デフォルトモードで動作させる
        displayLink?.add(to: .main, forMode: .default)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    @objc func rotateCompass(_ sender: UIPanGestureRecognizer) {
        
        let compassCenter = CGPoint(x: compassImageView.bounds.size.width / 2.0, y: compassImageView.bounds.size.height / 2.0)
        
        switch sender.state {
            //回し始め
        case .began:
            //前回の回転を保持するために、現在の回転角度をlastRotationに入れておく。
            lastRotation = atan2(sender.location(in: compassImageView).y - compassCenter.y, sender.location(in: compassImageView).x - compassCenter.x)
            print(lastRotation)
            //実際に動いた分動かす。
        case .changed:
            //指が移動した後の角度を求める。
            let newRotation = atan2(sender.location(in: compassImageView).y - compassCenter.y, sender.location(in: compassImageView).x - compassCenter.x)
            //今の角度-前回いた位置の角度で変化量を出す。
            let angleDifference = newRotation - lastRotation
            //targetRotation(すなわち、目的のいきたい角度)を求める。
            targetRotation = currentRotation + angleDifference
        default:
            break
        }
    }
    
    //スムーズに動かすためのメソッド
    @objc func updateRotation() {
        //回転のスピードを決める。大きくすると早く、小さくするとゆっくりになるよ。
        let rotationSpeed: CGFloat = 0.2
        //1回の動きの後にくる角度はここで求めているよ。
        currentRotation = currentRotation + (targetRotation - currentRotation) * rotationSpeed
        compassImageView.transform = CGAffineTransform(rotationAngle: currentRotation)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //  motionManager.stopDeviceMotionUpdates()
    }
}

// CLLocationManagerDelegateのメソッドを実装
extension SecondViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            my_latitude = location.coordinate.latitude
            my_longitude = location.coordinate.longitude
            print(my_latitude)

            let apiUrl = "https://api.openweathermap.org/data/2.5/weather"
            let apiKey = "YOUR_API_KEY"

            let parameters: Parameters = [
                "lat": my_latitude,
                "lon": my_longitude,
                "units": "metric",
                "appid": apiKey
            ]

            AF.request(apiUrl, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)

                    if let hourlyForecasts = json["list"].array {
                        for forecast in hourlyForecasts {
                            if let temperature = forecast["main"]["temp"].double {
                                self.hourlyTemperatures.append(temperature)
                            }
                        }
                    }

                case .failure(let error):
                    print("天気情報の取得に失敗しました: \(error)")
                }

                self.locationManager.stopUpdatingLocation()
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
    }
}
