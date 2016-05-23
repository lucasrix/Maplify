//
//  MapCaptureViewController.swift
//  Maplify
//
//  Created by Sergei on 19/05/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

class MapCaptureViewController: ViewController, InfinitePageControlDelegate, ErrorHandlingProtocol {
    @IBOutlet weak var pageControl: InfinitePageControl!
    @IBOutlet weak var mapView: MCMapView!

    var googleMapService: GoogleMapService! = nil
    var storyPointDataSource: StoryPointDataSource! = nil
    var storyPointActiveModel = CSActiveModel()
    var mapActiveModel = MCMapActiveModel()
    var mapDataSource: MCMapDataSource! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
//        self.loadFromRemote()
    }

    // MARK: - setup
    func setup() {
        self.pageControl.pageControlDelegate = self
        self.pageControl.cellModeEnabled = true
        self.pageControl.moveAndShowCell(0, animated: false)
    }
    
    func loadItemsFromDBIfNedded() {
        let storyPoints = StoryPointManager.allStoryPoints()
        self.updateStoryPointDetails(storyPoints)
    }
    
    func updateStoryPointDetails(storyPoints: [StoryPoint]) {
        self.storyPointActiveModel.removeData()
        self.storyPointActiveModel.addItems(storyPoints, cellIdentifier: String(StorypointCell), sectionTitle: nil, delegate: self)
        
        self.pageControl.pageControlDelegate = self
        self.pageControl.moveAndShowCell(1, animated: false)
    }
    
    func setupMapDataSource() {
        self.mapDataSource = MCMapDataSource()
        self.mapDataSource.mapActiveModel = self.mapActiveModel
        self.mapDataSource.mapView = self.mapView
        self.mapDataSource.mapService = self.googleMapService
        self.mapDataSource.reloadMapView(StoryPointMapItem)
    }
    
    func loadFromRemote() {
        ApiClient.sharedClient.getAllStoryPoints({ [weak self] (response) in
            if let storyPoints = response {
                StoryPointManager.saveStoryPoints(storyPoints as! [StoryPoint])
                self?.loadItemsFromDBIfNedded()
            }
            },
                                                 failure: { [weak self] (statusCode, errors, localDescription, messages) in
                                                    self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
            }
        )
    }
    
    // MARL: - InfinitePageControlDelegate
    func numberOfItems() -> Int {
//        return self.storyPointActiveModel.numberOfItems(0)
        return 10
    }
    
    func didShowPageView(pageControl: InfinitePageControl, view: UIView, index: Int) {
        
//        let model = self.storyPointActiveModel.cellData(NSIndexPath(forRow: index, inSection: 0)).model
//        if model is StoryPoint {
//            DetailMapItemHelper.configureStoryPointView(view, storyPoint: model as! StoryPoint)
//        } else if model is Story {
//            DetailMapItemHelper.configureStoryView(view, story: model as! Story)
//        }
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        view.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}