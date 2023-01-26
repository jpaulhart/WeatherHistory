//
//  LocationData.swift
//  TestUrl
//
//  Created by Paul Hart on 2023-01-13.
//

import Foundation

class LocationData: ObservableObject {

// ------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------

    let gcApiKey = "AIzaSyDO831xz24Nv2zUIGq96GnDkoA85sh5KfY"
    @Published var locationJson: String = ""
    @Published var locationDetail: LocationDetail = LocationDetail()
    @Published var lastErrorMessage: String = ""

    // ------------------------------------------------------------------
    // GetLocationInfo - Main entry point
    // ------------------------------------------------------------------

    func getLocationInfo(searchFor: String) -> Bool {
        
        locationJson = ""
        locationDetail = LocationDetail()
        
        lastErrorMessage = ""
        
        let lrc: Bool = geoLocate(searchFor: searchFor)
        if lrc {
            return true
        }
        return false
    }
    
    // ------------------------------------------------------------------
    // Geolocation
    // ------------------------------------------------------------------

    func geoLocate(searchFor: String) -> Bool {
        
        let query = searchFor.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(query)&region=+CA&key=\(gcApiKey)"
        
        // Create an URL
        if let url = URL(string: urlString) {
            // download data                                    ```````````````
            do {
                let data = try Data(contentsOf: url)
                print("Location: \(String(decoding: data, as: UTF8.self))")
                locationJson = String(decoding: data, as: UTF8.self)
                if parseGeocodeLocation(json: data, searchFor: searchFor) {
                    return true
                } else {
                    return false
                }
            } catch let dataError as NSError {
                let eMsg: String = "Geocoding: Data download for: '\(searchFor)' failed: \n\(dataError.localizedDescription)\n"
                print(eMsg)
                lastErrorMessage = eMsg
                return false
            }
        } else {
            print("Error creating url")
            lastErrorMessage = "Geocoding URL creation failed"
            return false
        }
    }
        
    // ------------------------------------------------------------------
    // parseGeocodeLocation - Parse JSON returned by Google Geocode
    // ------------------------------------------------------------------
    func parseGeocodeLocation(json: Data, searchFor: String) -> Bool {
        var results = [LocationResult]()
        let decoder = JSONDecoder()
        let status = "OK"
        let geocodeResult: GeocodeResult = GeocodeResult()
        
        if let jsonStatus = try? decoder.decode(LocationStatus.self, from: json) {
            
            if jsonStatus.status != "OK" {
                print("Geocode status not OK")
                lastErrorMessage = "Geocoding: JSON decoing failed with  '\(jsonStatus.status)'"
                return false
            }
        }
        
        if let jsonResults = try? decoder.decode(LocationResults.self, from: json) {
            results = jsonResults.results
            for result in results {
                geocodeResult.status = status
                geocodeResult.formattedAddress = result.formatted_address
                for addressComponent in result.address_components {
                    switch addressComponent.types[0] {
                    case "locality": locationDetail.city = addressComponent.long_name
                    case "street_number": locationDetail.streetNumber = addressComponent.long_name
                    case "route": locationDetail.street = addressComponent.long_name
                    case "neighborhood": locationDetail.neighborhood = addressComponent.long_name
                    case "administrative_area_level_2": locationDetail.metroArea = addressComponent.long_name
                    case "administrative_area_level_1": locationDetail.Province = addressComponent.long_name
                    case "country": locationDetail.country = addressComponent.long_name
                    case "postal_code": locationDetail.postalCode = addressComponent.long_name
                    default:
                        print("Unknown Geocode entry")
                    }
                }
                
                locationDetail.query = searchFor
                locationDetail.status = status
                locationDetail.fullAddress = "\(locationDetail.city), \(locationDetail.country)"
                
                let location = result.geometry.location
                geocodeResult.latitude = (location.lat.description as NSString).doubleValue
                geocodeResult.longitude = (location.lng.description as NSString).doubleValue
                locationDetail.latitude = geocodeResult.latitude
                locationDetail.longitude = geocodeResult.longitude
                
                return true
                // locations.requested = locationDetail
            }
            
        } else {
            print("Error occurred parsing Location JSON results")
        }
        return true
    }
}

// Supporting Objects ---------------------------------------------------------------------------------------------------------
    
class LocationDetail: Codable, ObservableObject {
    var query: String = ""
    var status: String = ""
    var fullAddress: String = ""
    var city: String = ""
    var streetNumber: String = ""
    var street: String = ""
    var neighborhood: String = ""
    var metroArea: String = ""
    var Province: String = ""
    var country: String = ""
    var postalCode: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}

class GeocodeResult: Codable {
    var query: String = ""
    var status: String = ""
    var locality: String = ""                    // Locality
    var streetNumber: String = ""                // SubThoroughfare
    var route: String = ""                       //
    var localityPolitical: String = ""           //
    var neighborhood: String = ""                //
    var administrativeAreaLevel2: String = ""    //
    var administrativeAreaLevel1: String = ""    //
    var country: String = ""                     // country
    var postalCode: String = ""                  // postal code
    var formattedAddress: String = ""            // formatted address
    var latitude: Double = 0.0                   // latitude
    var longitude: Double = 0.0                  // latitude
}


// **************************************************************************************
//
// GoogleGeocode
//
// This object is used to get the geocoding information
//
// **************************************************************************************=

struct LocationStatus: Codable {
    var status: String = ""
}

struct LocationResults: Codable {
    var results: [LocationResult] = [LocationResult]()
}

struct LocationResult: Codable {
    
    var formatted_address: String = ""
    var address_components: [Address_Component] = [Address_Component]()
    var geometry: Geometry = Geometry()
    
}

struct Address_Component: Codable {
    var long_name: String = ""
    var short_name: String = ""
    var types: [String] = [String]()
}

struct Geometry: Codable {
    var location: Location = Location()
}

struct Location: Codable {
    var lat: Float = 0.0
    var lng: Float = 0.0
}
