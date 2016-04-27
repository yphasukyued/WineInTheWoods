import Foundation
import MapKit

protocol HomeModelProtocal: class {
    func itemsDownloaded(items: NSArray)
}


class HomeModel: NSObject, NSURLSessionDataDelegate {
    
    //properties
    
    weak var delegate: HomeModelProtocal!
    var data : NSMutableData = NSMutableData()
    var urlPath: String = ""
    var dataType: String = ""
    
    func downloadItems(type: String) {
        
        dataType = type
        
        if type == "Winery" {
            urlPath = "https://gis.howardcountymd.gov/iOS/WineInTheWoods/GetWineryList.aspx"
        } else if type == "Food"
            || type == "Crafter"
            || type == "Sponsors" {
            urlPath = "https://gis.howardcountymd.gov/iOS/WineInTheWoods/GetName.aspx?mytype="+type
        } else if type == "Music" {
            urlPath = "https://gis.howardcountymd.gov/iOS/WineInTheWoods/GetEntertainerList.aspx?stage=All"
        } else if type == "Other" {
            urlPath = "https://gis.howardcountymd.gov/iOS/WineInTheWoods/GetOthersList.aspx"
        } else if type == "Points" {
            urlPath = "https://gis.howardcountymd.gov/iOS/WineInTheWoods/GetPointsList.aspx"
        }
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
        
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            self.parseJSON()
        }
        
    }
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    func parseJSON() {
        
        var jsonResult: NSMutableArray = NSMutableArray()
        
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        //var jsonElement: NSDictionary = NSDictionary()
        let locations: NSMutableArray = NSMutableArray()
        
        //print(jsonResult)
        for item in jsonResult {
            let location = LocationModel()
            var name: NSString = ""
            var desc: NSString = ""
            var locTime: NSString = ""
            var url: NSString = ""
            var phone: NSString = ""
            var pin: NSString = ""
            
            
            if dataType == "Winery" {
                name = (item["Wine_Maker"] as? String)!
                desc = (item["TentID"] as? String)!
                locTime = (item["City"] as? String)! +
                    ", " + (item["State"] as? String)! +
                    " " + (item["Zip"] as? String)!
                if item["URL"] is NSNull {
                    url = ""
                } else {
                    url = (item["URL"] as? String)!
                }
                phone = (item["Phone"] as? String)!
                pin = (item["TentID"] as? String)!
            } else if dataType == "Food"
                || dataType == "Sponsors" {
                name = (item["NAME"] as? String)!
                if item["DESCRIPTION"] is NSNull {
                    desc = ""
                } else {
                    desc = (item["DESCRIPTION"] as? String)!
                }
                locTime = (item["TYPE"] as? String)!
                if item["URL2"] is NSNull {
                    url = ""
                } else {
                    url = (item["URL2"] as? String)!
                }
                pin = (item["TEXTLABEL"] as? String)!
            } else if dataType == "Crafter" {
                name = (item["NAME"] as? String)!
                if item["DESCRIPTION"] is NSNull {
                    desc = ""
                } else {
                    desc = (item["DESCRIPTION"] as? String)!
                }
                locTime = (item["TYPE"] as? String)!
                if item["URL2"] is NSNull {
                    url = ""
                } else {
                    url = (item["URL2"] as? String)!
                }
                pin = "A" + (item["TEXTLABEL"] as? String)!
            } else if dataType == "Other" || dataType == "Points"{
                name = (item["NAME"] as? String)!
                if item["DESCRIPTION"] is NSNull {
                    desc = ""
                } else {
                    desc = (item["DESCRIPTION"] as? String)!
                }
                
                locTime = (item["TYPE"] as? String)!
                pin = (item["NAME"] as? String)!
            } else if dataType == "Music" {
                name = (item["ENTERTAINER"] as? String)!
                desc = (item["GENRE"] as? String)!
                locTime = (item["STAGE_NAME"] as? String)! +
                    " - " + (item["DATE_TIME"] as? String)!
                if item["URL"] is NSNull {
                    url = ""
                } else {
                    url = (item["URL"] as? String)!
                }
                pin = (item["STAGE_NAME"] as? String)!
            }
            
            
            let latitude = item["Y"] as? Double
            let longitude = item["X"] as? Double
            
            location.name = name as String
            location.desc = desc as String
            location.locTime = locTime as String
            location.pin = pin as String
            location.latitude = latitude
            location.longitude = longitude
            location.url = url as String
            location.phone = phone as String
            locations.addObject(location)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.delegate.itemsDownloaded(locations)
            
        })
    }
}