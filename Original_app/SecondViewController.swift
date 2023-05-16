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
    
    
    @IBOutlet weak var compassImageView: UIImageView!
    
    @IBOutlet var tempdisplay: UILabel!
    
    var lastRotation: CGFloat = 0
    //スムーズに動かすために用意しているよ。CADisplayLinkはアニメーションや画面の更新処理をスムーズにさせたい時に使うよん。
    var displayLink: CADisplayLink?
    var targetRotation: CGFloat = 0
    var currentRotation: CGFloat = 0
    
    //let motionManager = CMMotionManager()
    //var lastRotation = CGFloat(0)
    
    override func viewDidLoad() {
        
        var locationManager = CLLocationManager()
        
        var my_latitude: CLLocationDegrees!
        // 取得した経度を保持するインスタンス
        var my_longitude: CLLocationDegrees!
        
        
        super.viewDidLoad()
        
        
        // 1時間ごとの気温情報を保存する配列
        var hourlyTemperatures: [Double] = []

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
        
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { [self] (response) in
            switch response.result {
            case .success:
                let json = JSON(response.data as Any)
                print(json)

                // 1時間ごとの気温情報を取得して配列に保存
                if let hourlyForecasts = json["list"].array {
                    for forecast in hourlyForecasts {
                        if let temperature = forecast["main"]["temp"].double {
                            hourlyTemperatures.append(temperature)
                        }
                    }
                }

                // UILabelのテキストを更新する
                updateTemperatureLabel()

                // その他の処理...

            case .failure(let error):
                self.tempdisplay.text = "データ取得失敗"
            }
        }

        // UILabelのテキストを更新するメソッド
        func updateTemperatureLabel() {
            // 適切な気温データを取得（例: 最新の気温データを表示する場合は hourlyTemperatures.last を使用）
            if let latestTemperature = hourlyTemperatures.last {
                // UILabelに気温を表示
                tempdisplay.text = "\(latestTemperature)℃"
            }
        }

        
        
        // UIPanGestureRecognizerを作成して、ビューに追加する
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateCompass(_:)))
        compassImageView.addGestureRecognizer(panGesture)
        
        //CADisplayLinkのインスタンスを作成！updateRotationメソッドを呼び出すように設定
        //インスタンスって何？については、別で送ったのを見てねー。
        displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
        // displayLinkをメインスレッドのRunLoopに追加し、デフォルトモードで動作させる
        displayLink?.add(to: .main, forMode: .default)
        
        
        // 画像を15°ずつスライドさせるアニメーションを作成
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi * 2.0 * 24.0 * (15.0 / 360.0) // 24時間分の回転角度
        rotationAnimation.duration = 24.0 * 60.0 * 60.0 // 24時間の秒数
        
        // アニメーションが終了した後も最終位置で停止するように設定
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards
        
        // アニメーションを追加して実行
        compassImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
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
    
    
    
    
}




//override func viewWillDisappear(_ animated: Bool) {
// super.viewWillDisappear(animated)
// motionManager.stopDeviceMotionUpdates()








/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

