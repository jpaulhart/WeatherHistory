//
//  ContentView.swift
//  WeatherHistory
//
//  Created by Paul Hart on 2023-01-18.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var searchNewLocation: Bool = false
    @State var searchFor: String = ""
    @StateObject var weatherInfo: WeatherInfo = WeatherInfo()
    
    @StateObject var locationData: LocationData = LocationData()
    @StateObject var weatherKitData:  WeatherKitData  = WeatherKitData()
    
    var body: some View {
        VStack(alignment: .leading) {

            HeaderView()
            InputView(searchFor: $searchFor,
                      searchNewLocation: $searchNewLocation,
                      weatherKitData: weatherKitData,
                      locationData: locationData,
                      weatherInfo: weatherInfo)
            
            Text("**Entered data:** \(searchFor)")
            Text("**Location:** \(locationData.locationDetail.city) \(locationData.locationDetail.country)")
            Text("**Temperature:** \(weatherKitData.city.city) \(weatherKitData.city.country)")

            Spacer()
        }
        .padding()
    }
}

struct HeaderView: View {
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "cloud.sun")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Weather History")
            }
            .font(.title2)
        
            Divider()
                .frame(height: 4)
                .overlay(.orange)
        }
    }
}

struct InputView: View {
    @State var lastErrorMessage: String = ""
    
    @Binding var searchFor: String
    @Binding var searchNewLocation: Bool

    @ObservedObject var weatherKitData: WeatherKitData
    @ObservedObject var locationData: LocationData
    @ObservedObject var weatherInfo: WeatherInfo

    var body: some View {
        VStack {
            HStack {
                TextField("Location Name", text: $searchFor)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .onSubmit {
                        if searchNewLocation == false {
                            searchNewLocation = true
                            getNewLocation(searchFor: searchFor)
                        }
                    }
                Image(systemName: "x.square")
                    .onTapGesture {
                        searchFor = ""
                    }
                    .offset(x: -5)

            }
            .font(.title2)
        
            Divider()
                .frame(height: 4)
                .overlay(.gray)
        }
        .font(.caption)
    }
    
    func getNewLocation(searchFor: String) {
        print("Search for: \(searchFor)")
        //weatherInfo.getLocation(locationName: searchFor)
        let lrc = locationData.getLocationInfo(searchFor: searchFor)
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

        print("Search for: \(searchFor) complete")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
