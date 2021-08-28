import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherStatusLabel: UILabel!
    
    
    let cities = [
        "Leeds",
        "London",
        "Manchester"
    ]
    
    var city_api_address = "https://www.metaweather.com/api/location/search/?query="
    var weather_api_address = "https://www.metaweather.com/api/location/"
    var weather_icon_address = "https://www.metaweather.com/static/img/weather/png/64/"
    var selection_index: Int = 0
    var woeid: Int = 0
    var city_name: String = ""
    var weather_state: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCityId(cities[selection_index], city_api_address)

    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        
        selection_index += 1
        
        if ( selection_index == cities.count ) {
            selection_index = 0
        }
        
        getCityId(cities[selection_index], city_api_address)
        
    }
    
    func getCityId(_ city_name: String,_ api_address: String) {
                
        let request = NSMutableURLRequest(url: NSURL(string: api_address + city_name)! as URL,
                                cachePolicy: .useProtocolCachePolicy,
                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
              if (error != nil) {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
              } else {
                let decoder = JSONDecoder()
                let city_details = try! decoder.decode([CityData].self, from: data ?? Data())
                DispatchQueue.main.async() {
                    self.woeid  = (city_details[0].woeid)
                    self.getWeatherDetails(self.woeid, self.weather_api_address)
                }
              }
            })
            dataTask.resume()
    }
    
    func getWeatherDetails(_ woeid: Int,_ api_address: String) {
                
        if woeid != 0 {
            let request = NSMutableURLRequest(url: NSURL(string: api_address + String (self.woeid))! as URL,
                                    cachePolicy: .useProtocolCachePolicy,
                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                  if (error != nil) {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                  } else {
                    let decoder = JSONDecoder()
                    let weather_details = try! decoder.decode(WeatherDetails.self, from: data ?? Data())
                    DispatchQueue.main.async() {
                        self.weatherIconImageView.imageFromUrl(urlString: self.weather_icon_address + weather_details.consolidatedWeather[0].weatherStateAbbr + ".png")
                        
                        self.cityLabel.text = weather_details.title
                        self.weatherStatusLabel.text = weather_details.consolidatedWeather[0].weatherStateName
                    }
                  }
                })
                dataTask.resume()
        }
    }
    
}
extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {
                (response: URLResponse?, data: Data?, error: Error?) -> Void in
                if let imageData = data as Data? {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}
