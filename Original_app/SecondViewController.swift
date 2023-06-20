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
    var hourlyTemperatures: [Double] = []
    
    var locationManager = CLLocationManager()
    
    var sethour: Int = 0
    
    override func viewDidLoad() {
        
        //気温ボタンの角を丸くする
        tempdisplay.layer.cornerRadius = 25
        tempdisplay.clipsToBounds = true
        

        
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
                print(currentRotation)
                if currentRotation < 0 {
                    currentRotation += 360
                }
                
               // compassImageView.transform = CGAffineTransform(rotationAngle: currentRotation)
                compassImageView.transform = CGAffineTransform(rotationAngle: currentRotation * CGFloat.pi / 180)

                let hourMarkerAngle = 360.0 / 24.0 // 1時間あたりの角度
                    let hours = currentRotation / hourMarkerAngle
               // let hoursIn24Format = (hours).truncatingRemainder(dividingBy: 24)
                // let minutes = hoursIn24Format * 60
                let hoursIn24Format = floor(hours)
                let minutes = (hours - hoursIn24Format) * 60
        
        sethour = Int(hoursIn24Format)
                // 時間を表示するラベルに値を設定するなど、必要な処理を追加する
                timelabel.text = String(format: "%.0f時 %.0f分", hoursIn24Format, minutes)
                // メモリの数値を表示するラベルに値を設定するなど、必要な処理を追加する
                //markerslabel.text = "\(hourMarkers)"
    }
    
    
    //スムーズに動かすためのメソッド
    /*
     @objc func updateRotation() {
     //回転のスピードを決める。大きくすると早く、小さくするとゆっくりになるよ。
     let rotationSpeed: CGFloat = 0.2
     //1回の動きの後にくる角度はここで求めているよ。
     currentRotation = currentRotation + (targetRotation - currentRotation) * rotationSpeed
     compassImageView.transform = CGAffineTransform(rotationAngle: currentRotation)
     }
     */
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //  motionManager.stopDeviceMotionUpdates()
    }
    
    
    // CLLocationManagerDelegateのメソッドを実装
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        my_latitude = location.coordinate.latitude
        my_longitude = location.coordinate.longitude
        
        print("ichi",my_latitude)
        
        //緯度軽度を入れる&サイトで発行したAP! keyを入れる。
        let text = "https://api.openweathermap.org/data/2.5/weather?lat=\((my_latitude)!)&lon=\((my_longitude)!)&exclude=hourly&units=metric&appid=755fc0d3fb63d97d10d070136977a4f7"
        //上のtextをurlの形に変換する。
        let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //APIをリクエスト
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { [self] (response) in
            switch response.result {
            case .success:
                let json = JSON(response.data as Any)
                print(json)
                
                let temp = json["main"]["temp"].number!
                let tempRound = Int(round(Double(temp)))
                print(tempRound)
                tempdisplay.text = "\(String(tempRound))℃"
                
                
                
                print("1時間ごとの気温は\( json["hourly"]["temp"])")
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
                self.tempdisplay.text = "データ取得失敗"
            }
        }
        
        
    }
    
    //map許可
    /*
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     guard let location = locations.last else { return }
     my_latitude = location.coordinate.latitude
     my_longitude = location.coordinate.longitude
     print(my_latitude)
     
     let text = "https://api.openweathermap.org/data/2.5/weather?lat=\((my_latitude)!)&lon=\((my_longitude)!)&units=metric&appid=755fc0d3fb63d97d10d070136977a4f7"
     let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
     
     AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { [self] (response) in
     switch response.result {
     case .success:
     let json = JSON(response.data as Any)
     print(json)
     
     let temp = json["main"]["temp"].number!
     let tempRound = Int(round(Double(temp)))
     print(tempRound)
     
     DispatchQueue.main.async { [self] in
     tempdisplay.text = "\(tempRound)℃"
     
     }
     
     case .failure(let error):
     print("データ取得失敗: \(error)")
     }
     }
     }
     
     */
    
}
