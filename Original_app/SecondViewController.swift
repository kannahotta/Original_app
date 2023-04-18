//
//  SecondViewController.swift
//  Original_app
//
//  Created by 堀田環菜 on 2023/04/18.
//

import UIKit
import CoreMotion

class SecondViewController: UIViewController {
    

        let motionManager = CMMotionManager()
        var lastRotation = CGFloat(0)

        override func viewDidLoad() {
            super.viewDidLoad()

            // モーションセンサーからのデータを取得する間隔を設定
            motionManager.deviceMotionUpdateInterval = 0.1
            
            // モーションセンサーのデータ取得を開始
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
                guard let data = data, error == nil else { return }

                // モーションデータからデバイスの姿勢を取得
                let attitude = data.attitude
                
                // デバイスの姿勢から回転行列を取得
                let rotationMatrix = attitude.rotationMatrix
                
                // 回転行列から回転角を取得
                let rotation = atan2(rotationMatrix.m21, rotationMatrix.m11)
                
                // 前回の回転角からの差分を計算し、回転角を更新
                let deltaRotation = rotation - self?.lastRotation ?? 0
                self?.lastRotation = rotation
                
                
                // 回転した角度を表示
                print("Rotation: \(deltaRotation * 180 / .pi)")
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            motionManager.stopDeviceMotionUpdates()
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

