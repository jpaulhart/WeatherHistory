//
//  ContentView.swift
//  WeatherHistory
//
//  Created by Paul Hart on 2023-01-18.
//

import SwiftUI

struct ContentView: View {
    @State var searchNewLocation: Bool = false
    @State var searchFor: String = ""
    @State var weatherInfo: WeatherInfo
    
    var body: some View {
        VStack(alignment: .leading) {

            HeaderView()
            InputView(searchFor: $searchFor,
                      searchNewLocation: $searchNewLocation,
                      weatherInfo: $weatherInfo)
            
            Text("**Entered data:** \(searchFor)")
            Text("**Location:** \(weatherInfo.locationDetail.city)")

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
    @Binding var searchFor: String
    @Binding var searchNewLocation: Bool
    @Binding var weatherInfo: WeatherInfo

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
        weatherInfo = WeatherInfo(locationName: searchFor)
        print("Search for: \(searchFor) complete")
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
