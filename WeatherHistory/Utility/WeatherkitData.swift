//
//  WeatherDataModel.swift
//  WeatherKitExample
//
//  Created by Paul Hart on 2023-01-18.
//

import Foundation
import CoreLocation
import WeatherKit

/*
 func weather(for location: CLLocation) async throws -> Weather
 
 let current = try await service.weather(for: newYork, including: .current)
 let (current, minute) = try await service.weather(for: newYork, including: .current, .minute)
 let (current, minute, hourly) = try await service.weather(for: newYork, including: .current, .minute, .hourly)
 let (current, minute, hourly, daily) = try await service.weather(for: newYork, including: .current, .minute, .hourly, .daily)
 let (current, minute, hourly, daily, alerts) = try await service.weather(for: newYork, including: .current, .minute, .hourly, .daily, .alerts)
 let (current, minute, hourly, daily, alerts, airQuality) = try await service.weather(for: newYork, including: .current, .minute, .hourly, .daily, .alerts, .airQuality)`
 */

///
/// Name:
///     WeatherData
///
/// Description:
///     Collection of weather data for a city
///
class WeatherKitData: ObservableObject {

    // =======================================================================
    // Proprtties
    // =======================================================================
    //var cities =  [String: WeatherCity]()
    @Published var city = WeatherCity()
    
    // =======================================================================
    // Public Methods
    // =======================================================================
    
    func addCity(cityName: String, countryName: String, location: CLLocation) async -> WeatherCity {
        
        let newCity = WeatherCity ()
        let result: (CurrentWeather, Forecast<HourWeather>, Forecast<DayWeather>)
        
        do {
            result = try await fetchWeather(location: location)
        } catch {
            return newCity
        }
        
        newCity.city = cityName
        newCity.country = countryName
        newCity.location = location
        newCity.current = result.0
        newCity.hourly = result.1
        newCity.days = result.2
        //newCity.dayHistory = result.3
        
        DispatchQueue.main.async {
            self.city = newCity
        }
        //cities[newCity.city] = newCity
        return newCity
        
    }
    
    // =======================================================================
    // Private Methods
    // =======================================================================

    func fetchWeather(location: CLLocation) async throws -> (CurrentWeather, Forecast<HourWeather>, Forecast<DayWeather>) {
        
        let service = WeatherService.shared

        print("Loading WeatherData for \(location)")

        let startDate = "2020-01-01"
        let endDate   = "2020-12-31"
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Convert String to Date
//        let sd = dateFormatter.date(from: startDate)
//        let ed = dateFormatter.date(from: endDate)

        do {
            let (weather, hour, day) = try await service.weather(for: location, including: .current, .hourly, .daily)
            return (weather, hour, day)
        } catch {
            print("Unexpected error: \(error).")
            throw(error)
        }
        // async let dayHistory = getWeatherDayHistory(location: location, startDate: sd!, endDate: ed!)


    }

    private func getWeather(location: CLLocation) async -> Weather? {
        var weather: Weather?
        
        do {
            weather = try await Task.detached(priority: .userInitiated) {
                let fc = try await WeatherService.shared
                    .weather(for: location)
                return fc
            }.value
        } catch {
            print("WeatherKit Current returned error: \(error)")
//            fatalError("\(error)")
        }
        return weather
    }

    // =======================================================================
    private func getWeatherHour(location: CLLocation) async -> Forecast<HourWeather>? {
        var weatherHour: Forecast<HourWeather>?
        
        do {
            weatherHour = try await Task.detached(priority: .userInitiated) {
                let fc = try await WeatherService.shared
                    .weather(for: location,
                             including: .hourly)
                return fc
            }.value
        } catch {
            print("WeatherKit Hour returned error: \(error)")
//            fatalError("\(error)")
        }
        return weatherHour
    }


    // =======================================================================
    private func getWeatherDay(location: CLLocation) async -> Forecast<DayWeather>? {
        var weatherDay: Forecast<DayWeather>?
        
        do {
            weatherDay = try await Task.detached(priority: .userInitiated) {
                let fc = try await WeatherService.shared
                    .weather(for: location,
                             including: .daily)
                return fc
            }.value
        } catch {
            print("WeatherKit Daily returned error: \(error)")
//            fatalError("\(error)")
        }
        
        return weatherDay
    }

    // =======================================================================
    private func getWeatherDayHistory(location: CLLocation, startDate: Date, endDate: Date) async -> Forecast<DayWeather>? {
        var weatherDay: Forecast<DayWeather>?
        
        do {
            weatherDay = try await Task.detached(priority: .userInitiated) {
                let fc = try await WeatherService.shared
                    .weather(for: location,
                             including: .daily(startDate: startDate, endDate: endDate))
                return fc
            }.value
        } catch {
            print("WeatherKit Daily returned error: \(error)")
            fatalError("\(error)")
        }

        return weatherDay
    }
}

///
/// Name:
///     WeatherDataCity
///
/// Description:
///     Collection of weather data for a city
///
class WeatherCity: Identifiable {
    var id: UUID = UUID()
    var city: String = ""
    var country: String = ""
    var location: CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var current: CurrentWeather?
    var hourly: Forecast<HourWeather>?
    var days: Forecast<DayWeather>?
    var dayHistory: Forecast<DayWeather>?
}

