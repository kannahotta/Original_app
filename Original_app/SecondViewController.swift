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


class SecondViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var date2label: UILabel!
    
    @IBOutlet var tempdisplay: UILabel!
    
    @IBOutlet var timelabel: UILabel!
    
    @IBOutlet weak var compassImageView: UIImageView!
    
    var lastRotation: CGFloat = 0
    //スムーズに動かすために用意しているよ。CADisplayLinkはアニメーションや画面の更新処理をスムーズにさせたい時に使うよん。
    var displayLink: CADisplayLink?
    var targetRotation: CGFloat = 0
    var currentRotation: CGFloat = 0
    var angleDifference: CGFloat = 0
    var currentTime: CGFloat = 0.0 // currentTimeの追加
    
    var my_latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var my_longitude: CLLocationDegrees!
    
    // 1時間ごとの気温情報を保存する配列
    var hourlyTemperatures: [(String, Double)] = []
    
    var locationManager = CLLocationManager()
    
    var sethour: Int = 0
    
    override func viewDidLoad() {
        
        //日付ラベル２ フォントと角丸
        date2label.font = UIFont(name:"hanatotyoutyo" ,size: 25)
        //date2label.layer.cornerRadius = 15
        //date2label.clipsToBounds = true
        
        //気温ボタンの角を丸くする
        tempdisplay.layer.cornerRadius = 25
        tempdisplay.clipsToBounds = true
        
        //時間ボタンの角を丸くする
        timelabel.layer.cornerRadius = 17
        timelabel.clipsToBounds = true
        
        
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
        displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
        // displayLinkをメインスレッドのRunLoopに追加し、デフォルトモードで動作させる
        displayLink?.add(to: .main, forMode: .default)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    @objc func rotateCompass(_ sender: UIPanGestureRecognizer) {
        
        let compassCenter = CGPoint(x: compassImageView.bounds.size.width / 2.0, y: compassImageView.bounds.size.height / 2.0)
        let radiansToDegrees = 180 / CGFloat.pi
        
        switch sender.state {
            //回し始め
        case .began:
            let dy = sender.location(in: compassImageView).y - compassCenter.y
            let dx = sender.location(in: compassImageView).x - compassCenter.x
            lastRotation = atan2(dy, dx) * radiansToDegrees
        case .changed:
            let dy = sender.location(in: compassImageView).y - compassCenter.y
            let dx = sender.location(in: compassImageView).x - compassCenter.x
            var newRotation = atan2(dy, dx) * radiansToDegrees
            if newRotation - lastRotation > 180 {
                newRotation -= 360
            } else if newRotation - lastRotation < -180 {
                newRotation += 360
            }
            angleDifference = newRotation - lastRotation
            targetRotation = currentRotation + angleDifference
            lastRotation = newRotation
        default:
            break
        }
    }
    
    @objc func updateRotation() {
        let rotationSpeed: CGFloat = 0.4
        // 既存の回転処理のコード
        
        // 回転角度を24時間制に変換する処理
        currentRotation = currentRotation + (targetRotation - currentRotation) * rotationSpeed
        currentRotation = currentRotation.truncatingRemainder(dividingBy: 360)
        //print(currentRotation)
        if currentRotation < 0 {
            currentRotation += 360
        }
        
        // compassImageView.transform = CGAffineTransform(rotationAngle: currentRotation)
        compassImageView.transform = CGAffineTransform(rotationAngle: currentRotation * CGFloat.pi / 180)
        
        let hourMarkerAngle = 360.0 / 24.0 // 1時間あたりの角度
        let hours = currentRotation / hourMarkerAngle
        let hoursIn24Format = floor(hours)
        
        
        sethour = Int(hoursIn24Format)
        // 時間を表示するラベルに値を設定するなど、必要な処理を追加する
        timelabel.text = String(format: "%.0f時", hoursIn24Format)
        // メモリの数値を表示するラベルに値を設定するなど、必要な処理を追加する
        //３時間単位で、気温ラベルも変わる。
        updateTemperatureLabelWithRotation(hoursIn24Format)
        
    }
    func updateTemperatureLabelWithRotation(_ hoursIn24Format: CGFloat) {
        // 15度ごとに気温を更新する
        let temperatureIndex = Int(hoursIn24Format / 15)
        
        // hourlyTemperatures 配列から気温を取得
        if temperatureIndex >= 0 && temperatureIndex < hourlyTemperatures.count {
            let temperature = hourlyTemperatures[temperatureIndex]
            tempdisplay.text = "\(temperature.0) \(temperature.1)°C"
        } else {
            tempdisplay.text = "---"
        }
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //  motionManager.stopDeviceMotionUpdates()
    }
    
    
    // CLLocationManagerDelegateのメソッドを実装
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        my_latitude = location.coordinate.latitude
        my_longitude = location.coordinate.longitude
        
        
        //緯度軽度を入れる&サイトで発行したAP! keyを入れる。
        let apiurl = "https://api.openweathermap.org/data/2.5/forecat?"
        //上のtextをurlの形に変換する。
        let apikey = "55752a71af45fc0206fde6414a84f0bd"
        
        let parameters: Parameters = [
            "lat": my_latitude,
            "lon": my_longitude,
            
            "exclude": "curent,minutely,daily,alerts",
            "units": "metric",
            "appid": apikey
        ]
        
        
        
        //APIをリクエスト
        AF.request(apiurl, parameters: parameters).responseData { response in switch response.result {
        case .success(let value):
            let json = JSON(value)
            print(json)
            
            if let threeHourlyForecasts = json["list"].array {
                self.hourlyTemperatures.removeAll()
                for forecast in threeHourlyForecasts {
                    if let temperature = forecast["main"]["temp"].double,
                       let timestamp = forecast["dt"].double {
                        let date = Date(timeIntervalSince1970: timestamp)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        let time = dateFormatter.string(from: date)
                        self.hourlyTemperatures.append((time, temperature))
                    }
                }
            }
            print(self.hourlyTemperatures)
            
        case .failure(let error):
            print("天気情報の取得に失敗しました: \(error)")
        }
        }
    }
    
    //        struct dateFormatter {
    //            let time: String
    //            let temperature: Double
    //
    //        }
    //
    //        let dataFormatter = hourlyTemperatures
    //        var labelText =
    //
    //        for data in dataFormatter {
    //            labelText += "\(time.dataFormat)"
    //            labelText += "Temperature: \(data.hourlytemperatures)°C"
    //        }
    //
    //        tempdisplay.text = labelText
    //
    //

}
