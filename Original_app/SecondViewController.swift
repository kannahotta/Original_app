//
//  SecondViewController.swift
//  Original_app
//
//  Created by 堀田環菜 on 2022/11/29.
//

import UIKit
import CoreLocation

class SecondViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet var locatelabel2: UILabel!
    
    @IBOutlet var weatherlabel: UILabel!
    
    var cityName: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
