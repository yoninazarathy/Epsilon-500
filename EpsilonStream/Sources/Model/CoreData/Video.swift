import Foundation
import CoreData
import CloudKit

@objc(Video)
public class Video: BaseCoreDataModel {

}

extension Video {
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video");
    }
    
    @NSManaged public var age8Rating: Float
    @NSManaged public var age10Rating: Float
    @NSManaged public var age12Rating: Float
    @NSManaged public var age14Rating: Float
    @NSManaged public var age16Rating: Float
    @NSManaged public var exploreVsUnderstand: Float
    @NSManaged public var imageURL: String
    @NSManaged public var isAwesome: Bool
    @NSManaged public var isInCollection: Bool
    @NSManaged public var ourTitle: String
    @NSManaged public var commentAndReview: String
    @NSManaged public var channelKey: String
    @NSManaged public var imageURLlocal: String?
    @NSManaged public var whyVsHow: Float
    @NSManaged public var youtubeTitle: String
    @NSManaged public var youtubeVideoId: String
    @NSManaged public var hashTags: String
    @NSManaged public var durationSec: Int32
    @NSManaged public var displaySearchPriority: Float //QQQQ del
    @NSManaged public var hashTagPriorities: String
    @NSManaged public var initPriority: Float
    @NSManaged public var splashKey: String
    
    
    func update(fromCloudRecord record: CKRecord){
        recordName = record.recordID.recordName
        modificationDate = record[BaseCoreDataModel.modificationDateProperty] as! Date
        
        age8Rating = record["age8Rating"] as! Float
        age10Rating = record["age10Rating"] as! Float
        age12Rating = record["age12Rating"] as! Float
        age14Rating = record["age14Rating"] as! Float
        age16Rating = record["age16Rating"] as! Float
        exploreVsUnderstand = record["exploreVsUnderstand"] as! Float
        isAwesome = record["isAwesome"] as! Bool
        isInCollection = record["isInVideoCollection"] as! Bool
        ourTitle = record["ourTitle"] as! String
        commentAndReview = record["commentAndReview"] as! String
        channelKey = record["channelKey"] as! String
        whyVsHow = record["whyVsHow"] as! Float
        youtubeTitle = record["youtubeTitle"] as! String
        youtubeVideoId = record["youtubeVideoId"] as! String
        hashTags = record["hashTags"] as! String
        
        //QQQQ why aren't all fields treated this way?
        // -- currently it is with caution since just added duration
        if let ds = record["durationSec"] as? Int32{
            durationSec = ds
        }else{
            print("--- FOUND NO DURATION ---") //QQQQ
        }
        
        if let pr = record["displaySearchPriority"] as? Float{
            displaySearchPriority = pr
        }else{
            displaySearchPriority = Float(arc4random()) / 0xFFFFFFFF
        }
        
        imageURL = record["imageURL"] as! String
        //print(imageURL)
        
        if let htp = record["hashTagPriorities"] as? String{
            hashTagPriorities = htp
        }else{
            //print("--- FOUND NO HASH TAG PRIORITY ---") //QQQQ
            hashTagPriorities = ""
        }
        
        if let sk = record["splashKey"] as? String{
            splashKey = sk
        }else{
            splashKey = ""
        }
        
    }
    
    func update(withYouTube item: YouTubeVideoListResultItem){
        age8Rating = 0.0
        age10Rating = 0.0
        age12Rating = 0.0
        age14Rating = 0.0
        age16Rating = 0.0
        exploreVsUnderstand = 0.0
        isAwesome = false
        isInCollection = false
        ourTitle = item.title
        commentAndReview = "no comment"
        channelKey = item.channel
        whyVsHow = 0.0
        youtubeTitle = item.title
        youtubeVideoId = item.videoId
        hashTags = "#noTag"
        durationSec = item.durationInt
        imageURL = item.imageURLdef //QQQQ
        splashKey = ""
        hashTagPriorities = ""
        displaySearchPriority = Float(arc4random()) / 0xFFFFFFFF
    }
    
    func populate(cloudRecord video: CKRecord){
        
        if (video["recordType"] as! String) != "Video"{
            print("error - why is recordType != Video???")
            video["recordType"] = "Video" as CKRecordValue
        }
        
        video["age8Rating"] = age8Rating as CKRecordValue
        video["age10Rating"] = age10Rating as CKRecordValue
        video["age12Rating"] = age12Rating as CKRecordValue
        video["age14Rating"] = age14Rating as CKRecordValue
        video["age16Rating"] = age16Rating as CKRecordValue
        video["exploreVsUnderstand"] = exploreVsUnderstand as CKRecordValue
        video["imageURL"] = imageURL as CKRecordValue
        video["isAwesome"] = isAwesome as CKRecordValue
        video["isInVideoCollection"] = isInCollection as CKRecordValue
        video["ourTitle"] = ourTitle as CKRecordValue
        video["commentAndReview"] = commentAndReview as CKRecordValue
        video["channelKey"] = channelKey as CKRecordValue
        video["durationSec"] = durationSec as CKRecordValue
        
        video["displaySearchPriority"] = displaySearchPriority as CKRecordValue
        video["hashTagPriorities"] = hashTagPriorities as CKRecordValue
        video["splashKey"] = splashKey as CKRecordValue
        
        
        video["contentVersionNumber"] = tempCurrentVersionForSubmit as CKRecordValue//QQQQ temp - have in settings app
        
        //QQQQ is ok?
        if imageURLlocal != nil {
            //QQQQ same problem as in the other place with url2            let url = URL(string: str)!
            
            //let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            //let url2 = documentsDirectory.appendingPathComponent("imageThumbnails").appendingPathComponent(dbVideo.youtubeVideoId).appendingPathExtension("png")
            
            //QQQQ no idea - why url is not working - as a workaround reconstructing path here...
            
            
            video["imagePic"] = nil //CKAsset(fileURL: url2)//QQQQ
            //QQQQ submit it as ImageThumbNail
        }else{
            video["imagePic"] = nil
            print("No local URL for image - will try to cloud it without")
        }
        
        video["whyVsHow"] = whyVsHow as CKRecordValue
        video["youtubeTitle"] = youtubeTitle as CKRecordValue
        video["youtubeVideoId"] = youtubeVideoId as CKRecordValue
        video["hashTags"] = hashTags as CKRecordValue
    }
    
}
