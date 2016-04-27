import UIKit
import MapKit
import CoreLocation

var mainView: UIView = UIView()
var mainMapView: UIView = UIView()
var menuView: UIView = UIView()
var disclaimerView: UIView = UIView()
var splashView: UIImageView = UIImageView()
var rightBtn: UIButton = UIButton()
var leftBtn: UIButton = UIButton()
var homeBtn: UIButton = UIButton()
var locationBtn: UIButton = UIButton()
var dataSource: NSString = "Points"
var mapDisplay: NSString = "Off"
var menuDisplay: NSString = "Off"
var gpsDisplay: NSString = "Off"
var destinationTime: NSString = ""
var locateMeLabel: UILabel = UILabel()
var appTitle: UILabel = UILabel()
var timer: NSTimer = NSTimer()
var timer1: NSTimer = NSTimer()
var timer2: NSTimer = NSTimer()
var introText: UITextView = UITextView()
var disclaimerText: UITextView = UITextView()
var check: Bool = true
var disclaimerBtn: UIButton = UIButton()
var checkBtn: UIButton = UIButton()
var scrollLabel: UILabel = UILabel()
var isHighLighted:Bool = false
var myActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
let menus = ["2016 Tickets", "Accolades", "Accommodations", "Become a Sponsor", "Contact Us", "Designated Drivers", "Directions & Transportation", "Event Map", "Event Merchandise", "FAQ", "Grapevine Weather", "History", "Merriments", "Program Guide", "Terms and Conditions", "Wine Education"]

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HomeModelProtocal, UITabBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UIWebViewDelegate {
    
    var feedItems: NSArray = NSArray()
    var selectedLocation : LocationModel = LocationModel()
    
    var tableView: UITableView = UITableView()
    var selectedIndexPath : NSIndexPath?
    var tabBar: UITabBar = UITabBar()
    var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var webView: UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.activityType = .AutomotiveNavigation
        locationManager.requestWhenInUseAuthorization()
        
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems("Points")
        
        self.view.backgroundColor=UIColor(red: 51/255, green: 0/255, blue: 51/255, alpha: 1)
        
        mainView=UIView(frame: CGRectMake(0, 85, self.view.frame.width, self.view.frame.height-132))
        mainView.backgroundColor=UIColor(red: 102/255, green: 0/255, blue: 102/255, alpha: 1)
        self.view.addSubview(mainView)

        createNavigationBar()
        createIntroduction()

        if CLLocationManager.locationServicesEnabled() {
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        createScrollLabel()
        
        splashView  = UIImageView(frame:CGRectMake(0, 0, self.view.frame.width, self.view.frame.height));
        splashView.image = UIImage(named:"Poster.jpg")
        splashView.alpha = 1
        self.view.addSubview(splashView)
        
        createDisclaimer()
        
        
        menuView = UIView(frame: CGRectMake(-(mainView.frame.width), 0, mainView.frame.width, mainView.frame.height))
        menuView.backgroundColor=UIColor(red: 51/255, green: 0/255, blue: 51/255, alpha: 1)
        menuView.tag = 1
        mainView.addSubview(menuView)
        
        tableView = UITableView(frame: CGRectMake(0, 10, mainView.frame.width-20, mainView.frame.height-20), style: UITableViewStyle.Plain)
        tableView.backgroundColor=UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        menuView.addSubview(self.tableView)
        
        createWebAndMapView()
        
        myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        myActivityIndicator.center = view.center
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        //setLocalNotification()
    }
    /*
    func setLocalNotification() {
        
        let theDate = NSDate()
        
        let compDate: NSDateComponents = NSDateComponents()
        compDate.setValue(10, forComponent: NSCalendarUnit.Second)

        let cal = NSCalendar.currentCalendar()
        let fireDate: NSDate = cal.dateByAddingComponents(compDate, toDate: theDate, options: NSCalendarOptions(rawValue: 0))!
        
        print(fireDate)
        
        let notification: UILocalNotification = UILocalNotification()
        notification.alertBody = "Wine in the Woods today"
        notification.fireDate = fireDate
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    */
    //# MARK: - Navigation Bar
    func createNavigationBar() {
        leftBtn = UIButton(type: UIButtonType.System) as UIButton
        leftBtn.frame = CGRectMake(5, 32, 40, 48)
        leftBtn.setImage(UIImage(named: "List_White.png"), forState:.Normal)
        leftBtn.tintColor = UIColor.whiteColor()
        leftBtn.addTarget(self, action: #selector(ViewController.leftBtnPress), forControlEvents:.TouchUpInside)
        self.view.addSubview(leftBtn)
        
        rightBtn = UIButton(type: UIButtonType.System) as UIButton
        rightBtn.frame = CGRectMake(self.view.frame.width-45, 30, 28, 28)
        rightBtn.setImage(UIImage(named: "Map_Tab.png"), forState:.Normal)
        rightBtn.tintColor = UIColor.whiteColor()
        rightBtn.addTarget(self, action: #selector(ViewController.rightBtnPress), forControlEvents:.TouchUpInside)
        self.view.addSubview(rightBtn)
        
        homeBtn = UIButton(type: UIButtonType.System) as UIButton
        homeBtn.frame = CGRectMake(15, 30, 24, 24)
        homeBtn.setImage(UIImage(named: "750-home.png"), forState:.Normal)
        homeBtn.tintColor = UIColor.whiteColor()
        homeBtn.hidden = true
        homeBtn.addTarget(self, action: #selector(ViewController.homePress), forControlEvents:.TouchUpInside)
        self.view.addSubview(homeBtn)
        
        appTitle = UILabel(frame: CGRectMake(10, 30, self.view.frame.width-20, 24))
        appTitle.text = "Wine in the Woods"
        appTitle.textColor=UIColor.whiteColor()
        appTitle.font = UIFont(name: "TrebuchetMS-Bold", size: 18)
        appTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(appTitle)
        
        createTabBar()
    }
    func homePress() {
        timer2.invalidate()
        appTitle.text = "Wine in the Woods"
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        mapDisplay = "Off"
        leftBtn.hidden = false
        homeBtn.hidden = true
        UIView.animateWithDuration(1, animations:  {() in
            rightBtn.tintColor = UIColor.whiteColor()
            self.tabBar.tintColor = UIColor.grayColor()
            menuView.frame = CGRectMake(-(mainView.frame.width), 0, menuView.frame.width, menuView.frame.height)
            self.webView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
            mainMapView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
            }, completion:{(Bool)  in
        })
        getMessage()
        var bounds: CGRect = scrollLabel.bounds
        let originalString: String = scrollLabel.text!
        let myString: NSString = originalString as NSString
        bounds.size = myString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        scrollLabel.bounds = bounds;
    }
    func leftBtnPress() {
        timer2.invalidate()
        appTitle.text = "Wine in the Woods"
        rightBtn.tintColor = UIColor.whiteColor()
        self.tabBar.tintColor = UIColor.grayColor()
        if menuDisplay == "Off" {
            menuDisplay = "On"
            mapDisplay = "Off"
            leftBtn.tintColor = UIColor(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
            dataSource = "Slide"
            UIView.animateWithDuration(1, animations:  {() in
                menuView.alpha = 0
                menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width, mainView.frame.height)
                self.webView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
                mainMapView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
                }, completion:{(Bool)  in
                    self.itemsDownloaded(menus)
                    menuView.backgroundColor = UIColor.whiteColor()
                    menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width, mainView.frame.height)
                    UIView.animateWithDuration(1, animations: {() in
                        menuView.alpha = 1
                        menuView.frame = CGRectMake(0, 0, mainView.frame.width-60, mainView.frame.height)
                        self.tableView.frame = CGRectMake(0, 10, menuView.frame.width-20, menuView.frame.height-20)
                        }, completion:{(Bool) in
                            
                    })
            })
            
        } else if menuDisplay == "On" {
            menuDisplay = "Off"
            leftBtn.tintColor = UIColor.whiteColor()
            UIView.animateWithDuration(1.0, animations: {
                menuView.alpha = 1
                menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width-60, mainView.frame.height)
            })
        }
    }
    func rightBtnPress() {
        timer2.invalidate()
        appTitle.text = "Wine in the Woods"
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        leftBtn.tintColor = UIColor.whiteColor()
        self.tabBar.tintColor = UIColor.grayColor()
        if mapDisplay == "Off" {
            mapDisplay = "On"
            menuDisplay = "Off"
            rightBtn.tintColor = UIColor(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
            UIView.animateWithDuration(1.0, animations: {
                leftBtn.hidden = true
                homeBtn.hidden = false
                menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width-60, mainView.frame.height)
                self.webView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
                mainMapView.frame = CGRectMake(0, 0, mainView.frame.width, mainView.frame.height)
            })
        } else if mapDisplay == "On" {
            mapDisplay = "Off"
            rightBtn.tintColor = UIColor.whiteColor()
            UIView.animateWithDuration(1.0, animations: {
                leftBtn.hidden = false
                homeBtn.hidden = true
                mainMapView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
            })
        }
    }
    func closeSlide() {
        leftBtn.tintColor = UIColor.whiteColor()
        menuDisplay = "Off"
        UIView.animateWithDuration(1.0, animations: {
            menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width-60, mainView.frame.height)
        })
    }
    //# MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource == "Slide" {
            return menus.count
        } else {
            return feedItems.count
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if dataSource == "Slide" {
            return 35
        } else {
            if indexPath == selectedIndexPath {
                return MyTableViewCell.expandedHeight
            } else {
                return MyTableViewCell.defaultHeight
            }
        }

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = MyTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        //let item: LocationModel = feedItems[indexPath.row] as! LocationModel
        
        if dataSource == "Slide" {
            cell.textLabel?.text = menus[indexPath.row]
            cell.textLabel?.textColor = UIColor(red: 102/255, green: 0/255, blue: 102/255, alpha: 1)
            cell.textLabel?.font = UIFont(name: "TrebuchetMS-Bold", size: 16)
        } else if dataSource == "Sponsors" {
            let item: LocationModel = feedItems[indexPath.row] as! LocationModel
            cell.myButton1.frame = CGRectMake(15, 8, 30, 30)
            cell.myButton1.setImage(UIImage(named: (item.pin! as String)+".png"), forState: UIControlState.Normal)
            cell.myLabel1.frame = CGRectMake(55, 5, tableView.frame.width-50, 24)
            cell.myLabel1.text = item.name
            cell.myLabel2.frame = CGRectMake(55, 22, tableView.frame.width-50, 24)
            cell.myLabel2.text = item.desc
            cell.mapButton.frame = CGRectMake(60, 55, 28, 28)
            cell.mapButton.setImage(UIImage(named: "852-map.png"), forState: UIControlState.Normal)
            cell.mapButton.addTarget(self, action: #selector(ViewController.openMap), forControlEvents:.TouchUpInside)
            cell.webButton.frame = CGRectMake(105, 55, 28, 28)
            cell.webButton.setImage(UIImage(named: "715-globe.png"), forState: UIControlState.Normal)
            cell.webButton.addTarget(self, action: #selector(ViewController.openWeb), forControlEvents:.TouchUpInside)
            if item.phone != "" {
                cell.phoneButton.frame = CGRectMake(150, 55, 28, 28)
                cell.phoneButton.setImage(UIImage(named: "735-phone.png"), forState: UIControlState.Normal)
                cell.phoneButton.addTarget(self, action: #selector(ViewController.openPhone), forControlEvents:.TouchUpInside)
            }
        } else if dataSource == "Winery"
            || dataSource == "Music"
            || dataSource == "Food"
            || dataSource == "Crafter" {
            let item: LocationModel = feedItems[indexPath.row] as! LocationModel
            cell.myButton1.frame = CGRectMake(15, 8, 30, 30)
            cell.myButton1.setImage(UIImage(named: (item.pin! as String)+".png"), forState: UIControlState.Normal)
            cell.myLabel1.frame = CGRectMake(55, 5, tableView.frame.width-50, 24)
            cell.myLabel1.text = item.name
            cell.myLabel2.frame = CGRectMake(55, 22, tableView.frame.width-50, 24)
            cell.myLabel2.text = item.desc
            cell.myDetail.frame = CGRectMake(55, 39, tableView.frame.width-50, 24)
            cell.myDetail.text = item.locTime
            cell.mapButton.frame = CGRectMake(60, 65, 28, 28)
            cell.mapButton.setImage(UIImage(named: "852-map.png"), forState: UIControlState.Normal)
            cell.mapButton.addTarget(self, action: #selector(ViewController.openMap), forControlEvents:.TouchUpInside)
            cell.webButton.frame = CGRectMake(105, 65, 28, 28)
            cell.webButton.setImage(UIImage(named: "715-globe.png"), forState: UIControlState.Normal)
            cell.webButton.addTarget(self, action: #selector(ViewController.openWeb), forControlEvents:.TouchUpInside)
                if item.phone != "" {
                    cell.phoneButton.frame = CGRectMake(150, 65, 28, 28)
                    cell.phoneButton.setImage(UIImage(named: "735-phone.png"), forState: UIControlState.Normal)
                    cell.phoneButton.addTarget(self, action: #selector(ViewController.openPhone), forControlEvents:.TouchUpInside)
                }
        } else {
            let item: LocationModel = feedItems[indexPath.row] as! LocationModel
            cell.myButton1.frame = CGRectMake(15, 8, 30, 30)
            cell.myButton1.setImage(UIImage(named: (item.pin! as String)+".png"), forState: UIControlState.Normal)
            cell.myLabel1.frame = CGRectMake(55, 5, tableView.frame.width-50, 24)
            cell.myLabel1.text = item.name
            cell.myLabel2.frame = CGRectMake(55, 22, tableView.frame.width-50, 24)
            cell.myLabel2.text = item.desc
        }

        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if dataSource == "Slide" {
            menuPress(indexPath.row)
        } else if dataSource == "Other" {
            
            let item: LocationModel = feedItems[indexPath.row] as! LocationModel
            
            let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: item.latitude!, longitude: item.longitude!)
            mapView.centerCoordinate = center
            let span = MKCoordinateSpanMake(0.0015, 0.0015)
            let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = item.name
            annotation.subtitle = item.desc
            mapView.addAnnotation(annotation)
            
            rightBtnPress()
        } else if dataSource == "Music" {
            timer2.invalidate()
            appTitle.text = "Wine in the Woods"
            let previousIndexPath = selectedIndexPath
            if indexPath == selectedIndexPath {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = indexPath
                let item: LocationModel = feedItems[indexPath.row] as! LocationModel
                destinationTime = item.locTime!
                timer2 = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.displayTimeCountdown), userInfo: nil, repeats: true)
            }
            
            var indexPaths : Array<NSIndexPath> = []
            if let previous = previousIndexPath {
                indexPaths += [previous]
            }
            if let current = selectedIndexPath {
                indexPaths += [current]
            }
            if indexPaths.count > 0 {
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        } else {
            
            let previousIndexPath = selectedIndexPath
            if indexPath == selectedIndexPath {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = indexPath
            }
            
            var indexPaths : Array<NSIndexPath> = []
            if let previous = previousIndexPath {
                indexPaths += [previous]
            }
            if let current = selectedIndexPath {
                indexPaths += [current]
            }
            if indexPaths.count > 0 {
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! MyTableViewCell).watchFrameChanges()
    }
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! MyTableViewCell).ignoreFrameChanges()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in tableView.visibleCells as! [MyTableViewCell] {
            cell.ignoreFrameChanges()
        }
    }
    func menuPress(index: NSInteger) {
        leftBtn.hidden = true
        homeBtn.hidden = false
        if index == 0 {
            closeSlide()
            self.openWebView("http://www.missiontix.com/page/searchResults/?venue=Symphony%20Woods")
        } else if index == 1 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/about/accolades/")
        } else if index == 2 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/hotels-restaurants/")
        } else if index == 3 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/sponsors/become-a-sponsor/")
        } else if index == 4 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/contact-us/")
        } else if index == 5 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/designated-drivers/")
        } else if index == 6 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/directions-transportation/")
        } else if index == 7 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/event-map/")
        } else if index == 8 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/merchandise/")
        } else if index == 9 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/frequently-asked-questions/")
        } else if index == 10 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/grapevine-weather/")
        } else if index == 11 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/about/history/")
        } else if index == 12 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/artisans-entertainment/merriments/")
        } else if index == 13 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/information/program-guide/")
        } else if index == 14 {
            closeSlide()
            self.openDisclaimer()
        } else if index == 15 {
            closeSlide()
            self.openWebView("http://www.wineinthewoods.com/wineries/wine-seminars/")
        }
    }
    func openMap() {

        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        let item: LocationModel = feedItems[selectedIndexPath!.row] as! LocationModel
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: item.latitude!, longitude: item.longitude!)
        mapView.centerCoordinate = center
        let span = MKCoordinateSpanMake(0.0015, 0.0015)
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = item.name
        annotation.subtitle = item.desc
        
        mapView.addAnnotation(annotation)
        
        rightBtnPress()
    }
    func openWeb() {
        let item: LocationModel = feedItems[selectedIndexPath!.row] as! LocationModel
        openWebView(item.url!)
    }
    func openPhone() {
        let item: LocationModel = feedItems[selectedIndexPath!.row] as! LocationModel
        let newPhone = item.phone!.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        print(newPhone)
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(newPhone)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                
                let alert = UIAlertController(title: item.name!, message: item.phone!, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "Call", style: .Default) { (alert: UIAlertAction!) -> Void in
                    application.openURL(phoneCallURL);
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
                }
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                presentViewController(alert, animated: true, completion:nil)
            }
        }
    }
    func openWebView(url: NSString) {
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url as String)!))
        UIView.animateWithDuration(1.0, animations: {
            menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width-60, mainView.frame.height)
            self.webView.frame = CGRectMake(0, 0, mainView.frame.width, mainView.frame.height)
        })
    }
    func displayTimeCountdown() {

        // set destination date
        let firstArr = destinationTime.componentsSeparatedByString(" - ")
        let secondArr = firstArr[1].componentsSeparatedByString(" ")
        
        let ymdArr = secondArr[0].componentsSeparatedByString("-")
        let destY = "\(ymdArr[0])"
        let destM = "\(ymdArr[1])"
        let destD = "\(ymdArr[2])"

        let timeArr = secondArr[1].componentsSeparatedByString(":")
        let destHH = "\(timeArr[0])"
        let destMM = "\(timeArr[1])"
        let destSS = "\(timeArr[2])"
        
        let userCalendar = NSCalendar.currentCalendar()
        let competitionDate = NSDateComponents()
        if let myNumber1 = NSNumberFormatter().numberFromString(destY) {
            competitionDate.year  = myNumber1.integerValue
        }
        if let myNumber2 = NSNumberFormatter().numberFromString(destM) {
            competitionDate.month = myNumber2.integerValue
        }
        if let myNumber3 = NSNumberFormatter().numberFromString(destD) {
            competitionDate.day = myNumber3.integerValue
        }
        
        if let myNumber4 = NSNumberFormatter().numberFromString(destHH) {
            competitionDate.hour = myNumber4.integerValue
        }
        if let myNumber5 = NSNumberFormatter().numberFromString(destMM) {
            competitionDate.minute = myNumber5.integerValue
        }
        if let myNumber6 = NSNumberFormatter().numberFromString(destSS) {
            competitionDate.second = myNumber6.integerValue
        }
        
        let competitionDay = userCalendar.dateFromComponents(competitionDate)!

        // set current date
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let currentComponents = calendar.components([.Hour, .Minute, .Second, .Month, .Year, .Day], fromDate: date)
        
        let currentDate = calendar.dateFromComponents(currentComponents)
        
        
        // Here we compare the two dates
        competitionDay.timeIntervalSinceDate(currentDate!)
        
        let dayCalendarUnit: NSCalendarUnit = ([.Day, .Hour, .Minute, .Second])
        
        //here we change the seconds to hours,minutes and days
        let CompetitionDayDifference = userCalendar.components(dayCalendarUnit, fromDate: currentDate!, toDate: competitionDay, options: NSCalendarOptions())
        //finally, here we set the variable to our remaining time
        let daysLeft = CompetitionDayDifference.day
        let hoursLeft = CompetitionDayDifference.hour
        let minutesLeft = CompetitionDayDifference.minute
        let secondLeft = CompetitionDayDifference.second
        if (daysLeft < 0
            || hoursLeft < 0
            || minutesLeft < 0
            || secondLeft < 0) {
            appTitle.text = "Wine in the Woods"
        } else {
            appTitle.text = "Day: " + "\(daysLeft)" + " Time: " + "\(hoursLeft)" + ":" + "\(minutesLeft)" + ":" + "\(secondLeft)"
        }

        
    }
    func getMessage() {
        let url: NSURL = NSURL(string: "https://gis.howardcountymd.gov/iOS/WineInTheWoods/GetScrollMessage.aspx")!
        let data: NSData = NSData(contentsOfURL: url)!
        
        var jsonResult: NSMutableArray = NSMutableArray()
        
        do {
            jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            var jsonElement: NSDictionary = NSDictionary()
            
            jsonElement = jsonResult[0] as! NSDictionary
            let messages = (jsonElement["Messages"] as? String)!
            scrollLabel.text = messages

        } catch let error as NSError {
            print(error)
        }
    }
    //# MARK: - Scroll Label
    func createScrollLabel() {
        scrollLabel = UILabel(frame: CGRectMake(0, 60, self.view.frame.size.width, 22))
        scrollLabel.text = ""
        scrollLabel.textColor=UIColor.whiteColor()
        scrollLabel.backgroundColor=UIColor(red: 51/255, green: 0/255, blue: 51/255, alpha: 1)
        scrollLabel.font = UIFont(name: "TrebuchetMS", size: 14)
        scrollLabel.textAlignment = NSTextAlignment.Center
        scrollLabel.alpha = 1
        self.view.addSubview(scrollLabel)
        
        getMessage()
        
        var bounds: CGRect = scrollLabel.bounds
        let originalString: String = scrollLabel.text!
        let myString: NSString = originalString as NSString
        bounds.size = myString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        scrollLabel.bounds = bounds;
    }
    func timeScroll() {
        scrollLabel.center = CGPointMake(scrollLabel.center.x-2, scrollLabel.center.y);
        if (scrollLabel.center.x < -(scrollLabel.bounds.size.width/2)) {
            scrollLabel.center = CGPointMake(self.view.frame.size.width + (scrollLabel.bounds.size.width/2), scrollLabel.center.y);
        }
    }
    //# MARK: - Agreement
    func checkAgree() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let agreeItem = prefs.stringForKey("Agreement")
        if agreeItem == "Yes" {
            closeDisclaimer()
        } else if agreeItem == "No" {
            openDisclaimer()
        } else {
            openDisclaimer()
        }
    }
    func createIntroduction() {
        let introImageView  = UIImageView(frame:CGRectMake(0, 0, mainView.frame.width, 80));
        introImageView.image = UIImage(named:"witw header.jpg")
        introImageView.alpha = 1
        mainView.addSubview(introImageView)
        
        introText = UITextView(frame: CGRectMake(10, 90, mainView.frame.width-20, mainView.frame.height-100))
        introText.text = "May 21-22, 2016\nS Y M P H O N Y   W O O D S\n5950 Symphony Woods Road\nColumbia, MD 21044\n\nCelebrate the charm and character of an event that has aged to perfection! Sample Maryland’s finest wines from a souvenir glass; make food purchases from an abundance of high quality, distinctive restaurants and caterers; sharpen your palate by attending wine education seminars; enjoy exceptional works offered by invited artists and crafts persons; and revel in continuous live entertainment on the Purple and Green stages. The event runs from 11 AM-6 PM on Saturday and 11 AM-5 PM on Sunday. Learn about the designated driver program.\n\nWe recognize that parents may wish to bring their children to Wine in the Woods this year, however as this event is intended for anyone 21+ we are no longer offering face painting or other activities that may appeal to children. The admission fee for Non-Tasters, which includes anyone ages 3-20, is $25 on Saturday and $20 on Sunday.\n\nFor more information call 410-313-4700, or call 410-313-7275."
        introText.textColor=UIColor.whiteColor()
        introText.font = UIFont(name: "TrebuchetMS", size: 14)
        introText.backgroundColor=UIColor.clearColor()
        introText.alpha = 0
        introText.dataDetectorTypes = UIDataDetectorTypes.All
        introText.tintColor = UIColor.yellowColor()
        introText.selectable = true
        introText.editable = false
        mainView.addSubview(introText)
    }
    func createDisclaimer() {
        disclaimerView=UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        disclaimerView.backgroundColor=UIColor.grayColor()
        self.view.addSubview(disclaimerView)
        
        let disclaimerLabel = UILabel(frame: CGRectMake(10, 30, disclaimerView.frame.width-20, 24))
        disclaimerLabel.text = "Terms and Conditions"
        disclaimerLabel.textColor=UIColor.whiteColor()
        disclaimerLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 18)
        disclaimerLabel.textAlignment = NSTextAlignment.Center
        disclaimerView.addSubview(disclaimerLabel)
        
        disclaimerText = UITextView(frame: CGRectMake(10, 60, disclaimerView.frame.width-20, disclaimerView.frame.height-172))
        disclaimerText.text = "Your access to and use of the Howard County Government website (the 'Site') is subject to the following terms and conditions, as well as all applicable laws. Your access to the Site is in consideration for your agreement to these Terms and Conditions of Use, whether or not you are a registered user. By accessing, browsing, and using the Site, you accept, without limitation or qualification, these Terms and Conditions of Use.\n\nThere are sections of the Howard County Government website that connect you to other sites outside of the control of the Howard County Government. These terms and conditions apply only to those areas that are registered under the Howard County Government name and its agencies. Refer to the Terms of Use for those sites outside of the Howard County Government control.\n\nModification of the Agreement\n\nHoward County Government maintains the right to modify these Terms and Conditions of Use and may do so by posting notice of such modifications on this page. Any modification is effective immediately upon posting the modification unless otherwise stated. Your continued use of the Site following the posting of any modification signifies your acceptance of such modification. You should periodically visit this page to review the current Terms and Conditions of Use.\n\nConduct\n\nYou agree to access and use the Site only for lawful purposes. You are solely responsible for the knowledge of and adherence to any and all laws, statutes, rules and regulations pertaining to your use of the Site. By accessing the Site, you agree that you will not:\n\nUse the Site to commit a criminal offense or to encourage others to conduct that which would constitute a criminal offense or give rise to a civil liability;\nPost or transmit any unlawful, threatening, libelous, harassing, defamatory, vulgar, obscene, pornographic, profane, or otherwise objectionable content;\nUse the Site to impersonate other parties or entities;\nUse the Site to upload any content that contains a software virus, 'Trojan Horse' or any other computer code, files, or programs that may alter, damage, or interrupt the functionality of the Site or the hardware or software of any other person who accesses the Site;\nUpload, post, email, or otherwise transmit any materials that you do not have a right to transmit under any law or under a contractual relationship;\nAlter, damage, or delete any content posted on the site;\nDisrupt the normal flow of communication in any way;\nClaim a relationship with or speak for any business, association, or other organization for which you are not authorized to claim such a relationship;\nPost or transmit any unsolicited advertising, promotional materials, or other forms of solicitation;\nPost any material that infringes or violates the intellectual property rights of another; or\nCollect or store personal information about others.\n\nTermination of Use\n\nHoward County Government may, in its sole discretion, terminate or suspend your access and use of this Site without notice and for any reason, including for violation of these Terms and Conditions of Use or for other conduct which the Howard County Government, in its sole discretion, believes is unlawful or harmful to others. In the event of termination, you are no longer authorized to access the Site, and the Howard County Government will use whatever means possible to enforce this termination.\n\nOther Site Links\n\nSome links on the Site lead to websites that are not operated by the Howard County Government. The Howard County Government does not control these websites nor do we review or control their content. The Howard County Government provides these links to users for convenience. These links are not an endorsement of products, services, or information, and do not imply an association between the Howard County Government and the operators of the linked website.\n\nPolicy on Spamming\n\nYou specifically agree that you will not utilize email addresses obtained through using the Howard County Government's website to transmit the same or substantially similar unsolicited message to 10 or more recipients in a single day, nor 20 or more emails in a single week (consecutive 7-day period), unless it is required for legitimate business purposes. The Howard County Government, in its sole and exclusive discretion, will determine violations of the limitations on email usage set forth in these Terms and Conditions of Use.\n\nContent\n\nThe Howard County Government has the right to monitor the content that you provide, but shall not be obligated to do so. Although the Howard County Government cannot monitor all postings on the Site, we reserve the right (but assume no obligation) to delete, move, or edit any postings that come to our attention that we consider unacceptable or inappropriate, whether for legal or other reasons. United States and foreign copyright laws and international conventions protect the contents of the Site. You agree to abide by all copyright notices.\n\nIndemnity\n\nYou agree to defend, indemnify, and hold harmless the Howard County Government and its employees from any and all liabilities and costs incurred by Indemnified Parties in connection with any claim arising from any breach by you of these Terms and Conditions of Use, including reasonable attorneys' fees and costs. You agree to cooperate as fully as may be reasonably possible in the defense of any such claim. The Howard County Government reserves the right to assume, at its own expense, the exclusive defense and control of any matter otherwise subject to indemnification by you. You in turn shall not settle any matter without the written consent of the Howard County Government.\n\nDisclaimer of Warranty\n\nYou expressly understand and agree that your use of the Site, or any material available through this Site, is at your own risk. Neither the Howard County Government nor its employees warrant that the Site will be uninterrupted, problem-free, free of omissions, or error-free; nor do they make any warranty as to the results that may be obtained from the use of the Site. The content and function of the Site are provided to you 'as is,' without warranties of any kind, either express or implied, including, but not limited to, warranties of title, merchantability, fitness for a particular purpose or use, or 'currentness.'\n\nLimitation of Liability\n\nIn no event will the Howard County Government or its employees be liable for any incidental, indirect, special, punitive, exemplary, or consequential damages, arising out of your use of or inability to use the Site, including without limitation, loss of revenue or anticipated profits, loss of goodwill, loss of business, loss of data, computer failure or malfunction, or any and all other damages."
        disclaimerText.textColor=UIColor.whiteColor()
        disclaimerText.font = UIFont(name: "TrebuchetMS", size: 12)
        disclaimerText.backgroundColor=UIColor.darkGrayColor()
        disclaimerText.alpha = 1
        disclaimerText.selectable = false
        disclaimerText.editable = false
        disclaimerView.addSubview(disclaimerText)
        
        checkBtn = UIButton(type: UIButtonType.System) as UIButton
        checkBtn.frame = CGRectMake(10, disclaimerView.frame.size.height-90, 32, 32)
        checkBtn.setImage(UIImage(named: "Uncheckbox.png"), forState:.Normal)
        checkBtn.addTarget(self, action: #selector(ViewController.btnTouched), forControlEvents:.TouchUpInside)
        disclaimerView.addSubview(checkBtn)
        
        let agreeLabel = UILabel(frame: CGRectMake(52, disclaimerView.frame.size.height-85, 100, 24))
        agreeLabel.text = "I agree"
        agreeLabel.textColor=UIColor.whiteColor()
        agreeLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 18)
        agreeLabel.textAlignment = NSTextAlignment.Left
        disclaimerView.addSubview(agreeLabel)
        
        disclaimerBtn = UIButton(frame: CGRectMake(10, disclaimerView.frame.height-50, disclaimerView.frame.width-20, 40))
        disclaimerBtn.setTitle("Accept and Continue", forState: .Normal)
        disclaimerBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        disclaimerBtn.titleLabel!.font = UIFont(name: "TrebuchetMS", size: 20)
        disclaimerBtn.addTarget(self, action: #selector(ViewController.closeDisclaimer), forControlEvents: .TouchUpInside)
        disclaimerBtn.backgroundColor=UIColor.lightGrayColor()
        disclaimerBtn.hidden = true
        disclaimerView.addSubview(disclaimerBtn)
        
        checkAgree()
    }
    func openDisclaimer() {
        UIView.animateWithDuration(1.0, animations: {
            disclaimerView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        })
    }
    func closeDisclaimer() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue("Yes", forKey: "Agreement")
        UIView.animateWithDuration(1, animations: {
            disclaimerView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.view.frame.height)
            timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(ViewController.splash), userInfo: nil, repeats: false)
        })
    }
    func splash() {
        timer.invalidate()
        UIView.animateWithDuration(1.0, animations: {
            introText.alpha = 1
            splashView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.view.frame.height)
            myActivityIndicator.stopAnimating()
        })
        timer1 = NSTimer.scheduledTimerWithTimeInterval(0.06, target: self, selector: #selector(ViewController.timeScroll), userInfo: nil, repeats: true)
    }
    func btnTouched() {
        if check==false {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue("No", forKey: "Agreement")
            check=true
            disclaimerBtn.hidden = true
            checkBtn.setImage(UIImage(named: "Uncheckbox.png"), forState: .Normal)
        } else if check==true {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue("Yes", forKey: "Agreement")
            check=false
            disclaimerBtn.hidden = false
            checkBtn.setImage(UIImage(named: "Checkedbox.png"), forState: .Normal)
        }
    }
    //# MARK: - Update Data
    func itemsDownloaded(items: NSArray) {
        feedItems = items
        if dataSource == "Points" {
            setPin()
        } else {
            tableView.reloadData()
            myActivityIndicator.stopAnimating()
        }
    }
    //# MARK: - Set Pin
    func removePin() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    func setPin() {
        for obj : AnyObject in feedItems {
            if let item: LocationModel = obj as? LocationModel {
                let title = item.name
                let subtitle = item.desc
                let lat = item.latitude
                let lng = item.longitude
                let ann = MapPin(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: lng!), title: title!, subtitle: subtitle!, pin: "wiw.png")
                mapView.addAnnotation(ann)
            }
        }
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MapPin) {
            return nil
        }
        
        let reuseId = "pinID"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        } else {
            anView!.annotation = annotation
        }
        
        let cpa = annotation as! MapPin
        anView!.image = UIImage(named:cpa.pin!)
        
        return anView
    }
    //# MARK: - TileOverlay
    func addTileOverlay() {
        let baseURL = NSBundle.mainBundle().bundleURL.absoluteString
        let urlTemplate = baseURL.stringByAppendingString("/WITW/{z}/{x}/{y}.png/")
        let overlay = MKTileOverlay(URLTemplate:urlTemplate)
        overlay.geometryFlipped = true
        overlay.canReplaceMapContent = false
        self.mapView.addOverlay(overlay)
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            let renderer = MKTileOverlayRenderer(overlay:overlay)
            renderer.alpha = 1
            return renderer
        }
        return MKOverlayRenderer()
    }
    //# MARK: - User Location
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    func startLocationUpdates() {
        let status = CLLocationManager.authorizationStatus()
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            if gpsDisplay == "Off" {
                gpsDisplay = "On"
                locationBtn.tintColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
                locateMeLabel.text = "Locate Me\nis on"
                
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.activityType = CLActivityType.Fitness
                locationManager.distanceFilter = 10 // meters
                
                mapView.showsUserLocation = true
                mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
                UIApplication.sharedApplication().idleTimerDisabled = true
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
            } else if gpsDisplay == "On" {
                gpsDisplay = "Off"
                locationBtn.tintColor = UIColor.whiteColor()
                locateMeLabel.text = "Locate Me\nis off"
                mapView.showsUserLocation = false
                mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
                UIApplication.sharedApplication().idleTimerDisabled = false
                stopLocationUpdates()
            }
            
        } else if status == .Denied {
            openSettingGPS()
        }
    }
    func openSettingGPS() {
        let alertController = UIAlertController (title: "Location Service is off", message: "Go to Settings?", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil);
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized, .AuthorizedWhenInUse:
            manager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        default: break
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let eventDate: NSDate = newLocation.timestamp
            let howRecent: NSTimeInterval = eventDate.timeIntervalSinceNow
            if fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20 {
                let span = mapView.region.span
                let region = MKCoordinateRegion(center: newLocation.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
        if gpsDisplay == "Off" {
            stopLocationUpdates()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if gpsDisplay == "On" {
            mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        } else if gpsDisplay == "Off" {
            stopLocationUpdates()
        }
    }
    //# MARK: - Tab Bar
    func createTabBar() {
        tabBar = UITabBar(frame: CGRectMake(0,self.view.frame.height-48,self.view.frame.width,50))
        tabBar.backgroundColor=UIColor(red: 102/255, green: 0/255, blue: 102/255, alpha: 1)
        tabBar.delegate = self
        self.view.addSubview(tabBar)
        
        let tabImage0: UIImage = UIImage(named: "Food_Tab.png")!
        let tabImage1: UIImage = UIImage(named: "Winery_Tab.png")!
        let tabImage2: UIImage = UIImage(named: "Music_Tab.png")!
        let tabImage3: UIImage = UIImage(named: "Crafter_Tab.png")!
        let tabImage4: UIImage = UIImage(named: "Sponsors_Tab.png")!
        let tabImage5: UIImage = UIImage(named: "Other_Tab.png")!
        
        let item0 = UITabBarItem(title: "Food", image: tabImage0, selectedImage: nil)
        let item1 = UITabBarItem(title: "Winery", image: tabImage1, selectedImage: nil)
        let item2 = UITabBarItem(title: "Music", image: tabImage2, selectedImage: nil)
        let item3 = UITabBarItem(title: "Crafter", image: tabImage3, selectedImage: nil)
        let item4 = UITabBarItem(title: "Sponsors", image: tabImage4, selectedImage: nil)
        let item5 = UITabBarItem(title: "Other", image: tabImage5, selectedImage: nil)
        tabBar.items = [item0,item1,item2,item3,item4,item5]

    }
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        timer2.invalidate()
        appTitle.text = "Wine in the Woods"
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        selectedIndexPath = nil
        mapDisplay = "Off"
        dataSource = item.title!
        myActivityIndicator.startAnimating()
        rightBtn.tintColor = UIColor.whiteColor()
        leftBtn.hidden = true
        homeBtn.hidden = false
        if menuDisplay == "On" {
            UIView.animateWithDuration(1, animations:  {() in
                menuView.alpha = 0
                menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width-60, mainView.frame.height)
                self.webView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
                mainMapView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
                }, completion:{(Bool)  in
                    let homeModel = HomeModel()
                    homeModel.delegate = self
                    homeModel.downloadItems(item.title! as String)
                    
                    menuView.backgroundColor=UIColor(red: 102/255, green: 0/255, blue: 102/255, alpha: 1)
                    menuView.frame = CGRectMake(-(mainView.frame.width), 0, mainView.frame.width, mainView.frame.height)
                    UIView.animateWithDuration(1.0, animations: {() in
                        menuView.alpha = 1
                        leftBtn.tintColor = UIColor.whiteColor()
                        self.tabBar.tintColor = UIColor(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
                        menuView.frame = CGRectMake(0, 0, mainView.frame.width, mainView.frame.height)
                        self.tableView.frame = CGRectMake(0, 10, menuView.frame.width-20, menuView.frame.height-20)
                        }, completion:{(Bool) in
                            menuDisplay = "Off"
                    })
            })
        } else if menuDisplay == "Off" {
            UIView.animateWithDuration(1, animations:  {() in
                let homeModel = HomeModel()
                homeModel.delegate = self
                homeModel.downloadItems(item.title! as String)
                menuView.backgroundColor=UIColor(red: 102/255, green: 0/255, blue: 102/255, alpha: 1)
                menuView.frame = CGRectMake(0, 0, mainView.frame.width, mainView.frame.height)
                self.webView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
                mainMapView.frame = CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height)
                }, completion:{(Bool)  in
                    UIView.animateWithDuration(1.0, animations: {() in
                        menuView.alpha = 1
                        leftBtn.tintColor = UIColor.whiteColor()
                        self.tabBar.tintColor = UIColor(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
                        menuView.frame = CGRectMake(0, 0, mainView.frame.width, mainView.frame.height)
                        self.tableView.frame = CGRectMake(0, 10, menuView.frame.width-20, menuView.frame.height-20)
                        }, completion:{(Bool) in
                            menuDisplay = "Off"
                    })
            })
        }

        if item.title == "Food" {
            scrollLabel.text = "Enjoy a delicious variety of tastes from appetizers to desserts."
        } else if item.title == "Winery" {
            scrollLabel.text = "To learn more about the Maryland wine events, please visit http://www.marylandwine.com/home"
        } else if item.title == "Music" {
            scrollLabel.text = "Not only can you sample wine from the finest vineyards in Maryland, you can also enjoy live musical entertainment."
        } else if item.title == "Crafter" {
            scrollLabel.text = "Not only can you sample wine from the finest vineyards in Maryland, you can purchase products from our invitation-only craft show."
        } else if item.title == "Sponsors" {
            scrollLabel.text = "Thank you to the following sponsors who help make this event possible."
        } else {
            getMessage()
        }
        var bounds: CGRect = scrollLabel.bounds
        let originalString: String = scrollLabel.text!
        let myString: NSString = originalString as NSString
        bounds.size = myString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        scrollLabel.bounds = bounds;
    }
    //# MARK: - Web and Map View
    func createWebAndMapView() {
        
        mainMapView = UIView(frame: CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height))
        mainMapView.backgroundColor=UIColor(red: 51/255, green: 0/255, blue: 51/255, alpha: 1)
        mainView.addSubview(mainMapView)
        mapView = MKMapView(frame: CGRectMake(0, 40, mainMapView.frame.width, mainMapView.frame.height-40))
        mapView.mapType = MKMapType.Standard
        mapView.delegate = self
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.showsUserLocation = false
        mainMapView.addSubview(mapView)
        
        addTileOverlay()
        
        locationBtn = UIButton(type: UIButtonType.System) as UIButton
        locationBtn.frame = CGRectMake(12, 0, 32, 32)
        locationBtn.setImage(UIImage(named: "Location_Tab.png"), forState:.Normal)
        locationBtn.addTarget(self, action: #selector(ViewController.startLocationUpdates), forControlEvents:.TouchUpInside)
        locationBtn.tintColor = UIColor.whiteColor()
        mainMapView.addSubview(locationBtn)
        
        locateMeLabel = UILabel(frame: CGRectMake(50, 0, 80, 40))
        locateMeLabel.text = "Locate Me\nis off"
        locateMeLabel.textColor=UIColor.whiteColor()
        locateMeLabel.font = UIFont(name: "TrebuchetMS", size: 14)
        locateMeLabel.textAlignment = NSTextAlignment.Left
        locateMeLabel.numberOfLines = 2
        mainMapView.addSubview(locateMeLabel)
        
        webView = UIWebView(frame: CGRectMake(mainView.frame.width, 0, mainView.frame.width, mainView.frame.height))
        webView.scalesPageToFit = true
        webView.delegate = self;
        mainView.addSubview(webView)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

