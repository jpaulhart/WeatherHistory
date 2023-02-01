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
    @Published var weatherKitData:  WeatherKitData  = WeatherKitData()
    
    @Published var locationDetail: LocationDetail = LocationDetail()

    init() { }
    
    func getLocation(locationName: String) {
        let lrc = locationData.getLocationInfo(searchFor: locationName)
        if !lrc {
            lastErrorMessage = locationData.lastErrorMessage
            return
        }
        
        Task {
            let _ = await weatherKitData.addCity(cityName: locationData.locationDetail.city,
                                               countryName: locationData.locationDetail.country,
                                               location: CLLocation(latitude: locationData.locationDetail.latitude,
                                                                    longitude: locationData.locationDetail.longitude))
            print("End of weather stuff")
        }
    }
    
    
    
}
