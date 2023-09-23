//
//  WeatherManager.swift
//  TimeStamp
//
//  Created by Mei Mei on 17/11/2022.
//

import UIKit
import CoreLocation

private struct Const {
    static let key: String = "e04be51cf236e9b3a1e565f7e149d5ba"
}

struct CurrentTemperature: Decodable {
    var temp: CGFloat
}

struct CurrentWeather: Decodable {
    var main: CurrentTemperature
}

class WeatherManager {
    static let shared = WeatherManager()
    
    func getCurrentWeather(location: CLLocation) -> CGFloat? {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(Const.key)") else {
            return nil
        }
        
        do {
            let dataUrl = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            let urlDataFromJson = try jsonDecoder.decode(CurrentWeather.self, from: dataUrl)
            return urlDataFromJson.main.temp
        } catch {
            print(error)
            return nil
        }
    }
}
