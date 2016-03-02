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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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

    
}

