//
//  WeatherInfo.swift
//  WeatherHistory
//
//  Created by Paul Hart on 2023-01-22.
//

import Foundation
import CoreLocation

class WeatherInfo: ObservableObject {
    @Published var lastErrorMessage: String = ""
    
    @Published var locationData: LocationData = LocationData()
    @Published var weatherData:  WeatherData  = WeatherData()
    
    @Published var locationDetail: LocationDetail = LocationDetail()

    init() { }
    
    init(locationName: String) {
        let lrc = locationData.getLocationInfo(searchFor: locationName)
        if !lrc {
            lastErrorMessage = locationData.lastErrorMessage
            return
        }
        
        Task {
            let wd = await weatherData.addCity(cityName: locationData.locationDetail.city,
                                         countryName: locationData.locationDetail.country,
                                         location: CLLocation(latitude: locationData.locationDetail.latitude,
                                                              longitude: locationData.locationDetail.longitude))
            print("End of weather stuff")
        }
    }
    
    
    
}
