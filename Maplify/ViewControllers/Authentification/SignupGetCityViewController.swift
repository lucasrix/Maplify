//
//  SignupGetCityViewController.swift
//  Maplify
//
//  Created by Sergei on 16/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import INTULocationManager
import GoogleMaps

class SignupGetCityViewController: ViewController, ErrorHandlingProtocol {
    @IBOutlet weak var questionPin: UIImageView!
    @IBOutlet weak var getCityButton: UIButton!
    @IBOutlet weak var getCityInfoLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pin: UIImageView!
    
    var user: User! = nil
    var location: Location! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - setup
    func setup() {
        self.setupLabels()
        self.setupGetCityButton()
    }
    
    func setupLabels() {
        self.title = NSLocalizedString("Controller.Signup.Title", comment: String())
        self.getCityInfoLabel.text = NSLocalizedString("Label.GetCurrentCity", comment: String())
    }
    
    func setupGetCityButton() {
        self.getCityButton.setTitle(NSLocalizedString("Button.GetCity", comment: String()), forState: .Normal)
        self.getCityButton.layer.cornerRadius = CornerRadius.defaultRadius
    }
    
    func setupView(city: String) {
        self.questionPin.hidden = true
        self.getCityButton.hidden = true
        self.cityLabel.hidden = false
        self.pin.hidden = false
    }
    
    override func backButtonHidden() -> Bool {
        return true
    }
    
    // MARK: - actions
    @IBAction func getCityButtonTapped(sender: AnyObject) {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.City, timeout: Network.mapRequestTimeOut) { [weak self] (location, accuracy, status) -> () in
            self?.addRightBarItem(NSLocalizedString("Button.Done", comment: String()))
            if (status == .Success) && (location != nil) {
                GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                                                        completionHandler: { [weak self] (response, error) in
                                                            if error != nil {
                                                                let title = NSLocalizedString("Alert.Error", comment: String())
                                                                let cancel = NSLocalizedString("Button.Ok", comment: String())
                                                                self?.showMessageAlert(title, message: (error?.description)!, cancel: cancel)
                                                            } else {
                                                                let address = response?.firstResult()
                                                                
                                                                self?.location = Location()
                                                                self?.location.latitude = location.coordinate.latitude
                                                                self?.location.longitude = location.coordinate.longitude
                                                                self?.location.address = (address?.thoroughfare)!
                                                                self?.location.city = (address?.locality)!
                                                                self?.user.profile.city = (address?.locality)!
                                                                self?.cityLabel.text = (address?.locality)!
                                                                self?.setupView((address?.locality)!)
                                                            }
                })
            }
        }
    }
    
    override func rightBarButtonItemDidTap() {
        SessionHelper.sharedHelper.setupDefaultSettings()

        if self.location != nil {
            self.showProgressHUD()
            ApiClient.sharedClient.updateProfile(self.user.profile, location: self.location,
                                                 success: { [weak self] (response) -> () in
                                                    self?.hideProgressHUD()
                                                    self?.user.profile = response as! Profile
                                                    SessionManager.saveCurrentUser((self?.user)!)
                                                    let location = CLLocation(latitude: (self?.location.latitude)!, longitude: (self?.location.longitude)!)
                                                    SessionHelper.sharedHelper.updateUserLastLocationIfNeeded(location)
                                                    self?.routesSetContentController()
                                                 },
                                                 failure: { [weak self] (statusCode, errors, localDescription, messages) -> () in
                                                    self?.hideProgressHUD()
                                                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
                                                 })
        } else {
            self.routesSetContentController()
            SessionManager.saveCurrentUser(self.user)
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}