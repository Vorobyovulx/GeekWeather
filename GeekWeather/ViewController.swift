//
//  ViewController.swift
//  GeekWeather
//
//  Created by Mad Brains on 29.06.2020.
//  Copyright © 2020 GeekTest. All rights reserved.
//

import UIKit
import JGProgressHUD
import PromiseKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var temperature: UILabel!
    @IBOutlet private weak var weatherImage: UIImageView!
    
    private let networkService = NetworkService()
    
    private var currentCity = "Moscow"
    
    private let hud = JGProgressHUD(style: .dark)
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hud.textLabel.text = "Loading"
        //getWeather(with: currentCity)
        launchPromiseChaining(with: currentCity)
    }

    func launchPromiseChaining(with cityName: String) {
        // Запускаем лоадер
        hud.show(in: view)
        
        // Отправляем сетевой запрос
        networkService.weatherPromise(for: currentCity)
            // Обрабатываем ответ, какие-то сайд эффекты, печати или сохранения. Без изменения передает дальше
            .get { [weak self] weather in
                guard let self = self else {
                    return
                }
                
                print("\(weather.city)")
                try! self.realm.write {
                    self.realm.add(weather, update: .modified)
                }
                
                self.locationLabel.text = "Today in \(weather.city)"
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd hh:mm:ss"
                self.dateLabel.text = df.string(from: weather.date)
                self.temperature.text = String(weather.temperature) + "°C"
            }
            .then { [weak self] weather -> Promise<UIImage> in
                guard let self = self else { return Promise(error: PMKError.cancelled) }
                let promise = self.networkService.weatherImagePromise(iconName: weather.icon)
                return promise
            }
            //.thenMap { [weak self] weather -> Promise<UIImage> - для каждого элемента массива отправляем запрос за загрузку изображения
            // По окончании всех загрузок отображаем иконки
            .done(on: .main) { [weak self] image in
                self?.weatherImage.image = image
                
            }
            // Ловим ошибки при наличии
            .catch { [weak self] error in
                print("Error: \(error)")
            }
            // Прячем лоадер
           .finally { [weak self] in
                self?.hud.dismiss(animated: true)
           }
    


    }
    
    func getWeather(with cityName: String) {
        hud.show(in: view)
        networkService.weather(
            for: cityName,
            completionHandler: { response in
                switch response {
                case let .success(weather):
                    print(weather.description)
                    
                    self.networkService.weatherImage(
                        iconName: weather.icon,
                        completionHandler: { response in
                            switch response {
                            case let .success(image):
                                self.locationLabel.text = "Today in \(weather.city)"
                                
                                let df = DateFormatter()
                                df.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                self.dateLabel.text = df.string(from: weather.date)
                                self.temperature.text = String(weather.temperature) + "°C"
                                self.weatherImage.image = image
                                self.hud.dismiss(animated: true)
                            case .failure(_):
                                print("Some error with loading image")
                            }
                        }
                    )
                case let .failure(error):
                    print(error)
                }
            }
        )
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
        getWeather(with: currentCity)
    }
    
    @IBAction func moscowButtonTapped(_ sender: Any) {
        currentCity = "Moscow"
        getWeather(with: currentCity)
    }
    
    @IBAction func londonButtonTapped(_ sender: Any) {
        currentCity = "London"
        getWeather(with: currentCity)
    }
    
    @IBAction func berlinButtonTapped(_ sender: Any) {
        currentCity = "Berlin"
        getWeather(with: currentCity)
    }
    
}

