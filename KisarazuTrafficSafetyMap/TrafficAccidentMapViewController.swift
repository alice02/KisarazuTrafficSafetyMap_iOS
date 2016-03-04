//
//  TrafficAccidentMapViewController.swift
//  KisarazuTrafficSafetyMap
//
//  Created by Kouta on 2016/03/02.
//  Copyright © 2016年 Kouta. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON

class TrafficAccidentMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // サーバーのアドレス
    let serverAddress = "http://localhost:3000/"

    // MapView
    @IBOutlet weak var mapView: MKMapView!
    
    // 位置情報を管理
    let locationManager = CLLocationManager()
    
    // 最後に位置情報を更新した場所
    var lastLocation: CLLocationCoordinate2D?
    
    // 交通事故発生場所の緯度経度を格納する配列
    var trafficAccidentPlaces: [[String: Double]] = []
    
    // ボタンを生成
    let centerButton = UIButton(type: .Custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // ToolBarの色を変更 NavigationBarと同じ色にする
        self.navigationController?.toolbar.barTintColor = self.navigationController?.navigationBar.barTintColor
        
        setCenterButton(self.view.frame.width, height: self.view.frame.height)
        
        // 現在地をマーキング
        mapView.userTrackingMode = MKUserTrackingMode.Follow

        // デリゲートを設定
        locationManager.delegate = self
        mapView.delegate = self
        
        // 50m移動したら位置情報を更新する
        locationManager.distanceFilter = 50.0
        
        // 測位の精度を100mとする
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // 位置情報サービスへの認証状態を取得
        let status = CLLocationManager.authorizationStatus()
        
        // 未認証ならばダイアログを出す
        if status == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization();
        }
        
        // 即位開始
        locationManager.startUpdatingLocation()
        
        // 交通事故発生箇所をサーバーから取得
        getTrafficAccidentPlaces({(UIBackgroundFetchResult) -> Void in
            // ピンを立てる
            self.setPins(self.trafficAccidentPlaces)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 位置情報が更新されたとき実行
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 位置情報の配列から一番最後に取得した位置情報を取得
        let locations: NSArray = locations as NSArray
        let location: CLLocation = locations.lastObject as! CLLocation
        lastLocation = location.coordinate
        
        if let location = lastLocation {
            // 一番最後に取得した位置情報をマップの中心にする
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastLocation!.latitude, lastLocation!.longitude)
            mapView.setCenterCoordinate(center, animated: true)
            
            // 現在地から1.5km四方で表示する
            let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location, 1500, 1500)
            mapView.setRegion(myRegion, animated: true)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.centerButton.removeFromSuperview()
        setCenterButton(size.width, height: size.height)
    }
    
    // 位置情報サービスへの認証状態がダイアログによって変更されたとき実行
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case CLAuthorizationStatus.AuthorizedAlways:
            locationManager.startUpdatingLocation()
        case CLAuthorizationStatus.Denied:
            print("Denied")
        case CLAuthorizationStatus.Restricted:
            print("Restricted")
        case CLAuthorizationStatus.NotDetermined:
            print("NotDetermined")
        }
    }

    // サーバーから事故箇所を取得
    func getTrafficAccidentPlaces(completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        Alamofire.request(.GET, serverAddress + "api/v1/places.json").responseJSON { response in
            
            // 通信に成功
            if response.result.isSuccess {
                // 受信結果がnilならreturn
                guard let object = response.result.value else {
                    return
                }
                // JSONをparseする
                let json = JSON(object)
                json.forEach { (_, json) in
                    let point: [String: Double] = [
                        "latitude": json["latitude"].doubleValue,
                        "longitude": json["longitude"].doubleValue
                    ]
                    // 配列に保存する
                    self.trafficAccidentPlaces.append(point)
                }
                completionHandler(UIBackgroundFetchResult.NewData)
            }
            // 通信に失敗
            else {
                print(response.result.error)
            }
        }
    }

    // 指定した緯度経度にピンを立てる
    func setPins(places: [[String: Double]]) {
        for place in places {
            // 緯度経度を抽出
            let lat: Double = place["latitude"]!
            let lng: Double = place["longitude"]!
            // ピンを作る
            let pin: MKPointAnnotation = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(lat, lng)
            // ピンを追加
            mapView.addAnnotation(pin)
        }
    }
    
    func setCenterButton(width: CGFloat, height: CGFloat) {
        // ボタンに表示するアイコンを生成
        let targetImage: UIImage! = UIImage(named: "target")
        
        // ボタンのサイズ
        centerButton.frame = CGRectMake(0.0, 0.0, 100, 100)
        // ボタンの中心の表示位置
        centerButton.center.x = width / 2
        centerButton.center.y = height - 10

        // ボタンの外見
        // ボーダーラインの色を白
        centerButton.layer.borderColor = UIColor.whiteColor().CGColor
        // ボーダーラインの幅
        centerButton.layer.borderWidth = 1.5
        // ボタンの色を紫
        centerButton.layer.backgroundColor = UIColor.purpleColor().CGColor
        // 角を丸める（丸ボタンになる）
        centerButton.layer.cornerRadius = 50
        // ボタンに影をつける
        centerButton.layer.shadowOffset = CGSizeMake(0, 5.0)
        centerButton.layer.shadowColor = UIColor.blackColor().CGColor
        centerButton.layer.shadowOpacity = 0.9
        centerButton.layer.masksToBounds = false
        
        // タップした時のアクションを設定
        centerButton.addTarget(self, action: "tapAction", forControlEvents: .TouchUpInside)
        
        // 文字を表示
        centerButton.setTitle("現在地", forState: .Normal)
        centerButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, -3, 5, 30)
        
        // アイコンを表示
        centerButton.setImage(targetImage, forState: .Normal)
        centerButton.imageEdgeInsets = UIEdgeInsetsMake(0, 33, 50, 0)
        
        // アイコンの色を白に
        centerButton.tintColor = UIColor.whiteColor()
        
        // ボタンを追加
        self.navigationController?.view.addSubview(centerButton)
    }
    
    func tapAction() {
        if let last = self.lastLocation {
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(last.latitude, last.longitude)
            mapView.setCenterCoordinate(center, animated: true)
        }
    }
    
    
}

