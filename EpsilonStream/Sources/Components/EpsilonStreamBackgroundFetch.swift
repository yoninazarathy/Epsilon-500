import Foundation
import CloudKit
import Firebase


//QQQQ need to organize so this class is more for cloud and the other class is more for core data...?

class EpsilonStreamBackgroundFetch: ManagedObjectContextUserProtocol {
    
    static var searcherUI: SearcherUI! = nil
    static var needUpdate: Bool? = nil
    static var pullEpsilonStreamInfoInProgress = false
    static var epsilonStreamInfoRecord: CKRecord? = nil
    
    static var isUpdatingNow = false
    static var finishedVideos = false
    static var finishedMathObjects = false
    static var finishedFeaturedURLs = false
    static var finishedMathObjectLinks = false
    static var finishedSnippets = false

    static var readRecordsCount = [String: Int]()
    static var videoNum = 0
    static var videoCount = [String: Int]()
    static var peekVideoDone = false

    
    class func runUpdate() {
        readMathObjectsFromCloud() //QQQQ implement for collection
        readMathObjectLinksFromCloud()
        //if not in admin mode only read videos in collection otherwise (inAdminMode) read all videos
        readVideoDataFromCloud(isInAdminMode == false)
        readFeaturedURLsFromCloud()
        readSnippetsFromCloud()
    }
    
    //QQQQ This is a patch to make onFinish run only once.
    static var didItOnce = false
    
    class func onFinish(){
        if didItOnce{
            return
        }
        let isReady = finishedVideos && finishedFeaturedURLs &&  finishedMathObjects && finishedMathObjectLinks && finishedSnippets
        
        if isReady {
            didItOnce = true
            PersistentStorageManager.shared.saveMainContext()
            
            EpsilonStreamDataModel.setUpAutoCompleteLists(withContext: PersistentStorageManager.shared.newBackgroundContext() )
            
            DispatchQueue.main.async {
                //EpsilonStreamDataModel.setUpAutoCompleteLists(withContext: mainContext)
                EpsilonStreamDataModel.setLatestDates()
                ImageManager.setup()
                
                DispatchQueue.global(qos: .background).async{
                    EpsilonStreamBackgroundFetch.backgroundScan()
                }
                
                UserDataManager.lastDatabaseUpdateDate = Date()
                dbReadyToGo = true
            }
        }
    }
    
    //indicates if any of the background actions is in progress at any given time
    //the idea is that at most action will be in progress at any given time
    //action progress is either initiated through user behaviour (sometimes in curation mode)
    //or it is a result of the background scan
    static var numBackGroundActionsInProgress = 0
    
    class func setActionStart(){
        //QQQQ synch semaphore problem (also in setActionFinish() method)
//        DispatchQueue.main.sync {
            numBackGroundActionsInProgress += 1
//        }
    }
    
    class func setActionFinish(){
//        DispatchQueue.main.sync {
            numBackGroundActionsInProgress -= 1
            if numBackGroundActionsInProgress < 0 {
                DLog("Error: negative numBackGroundActionsInProgress")//QQQQ assert
            }
//        }
    }
    
    
    class func backgroundScan(){
   
        var counter = 0

        while true {
            sleep(30)
            if numBackGroundActionsInProgress > 0 {
                continue;
            }
            switch counter % 9 {
            case 0:
                DLog("refresh images")
                //QQQQ I am worried that this happens in background thread
                //If we do it with main.async it freezes with many videos (in curate mode)
            case 1:
                DLog("clean videos")
                DispatchQueue.main.async {
                    EpsilonStreamDataModel.videoIntegrityCheck()
                }
            case 2:
                DLog("clean features")
                break
            case 3:
                DLog("clean math objects")
                break
            case 4:
                DLog("clean math math object links")
                break
            case 5:
                DLog("fetch Videos")
                readVideoDataFromCloud(isInAdminMode == false)
                break
            case 6:
                DLog("fetch MathObjects")
                readMathObjectsFromCloud()
                break
            case 7:
                DLog("fetch MathObjectLinks")
                readMathObjectLinksFromCloud()
                break
            case 8:
                DLog("fetch Snippets")
                readSnippetsFromCloud()
                break
            case 9:
                DLog("fetch Features")
                readFeaturedURLsFromCloud()
                break
            default:
                break
            }
            counter += 1
            if counter % 100 == 0{
                Analytics.logEvent("background_long_cycle", parameters: ["counter" : counter as NSObject])
            }
        }
    }
    
    // MARK: - Factory methods
    
    class func defaultQueryCompletionBlock() -> ((CKQueryCursor?, Error?) -> Void) {
        let block = { (cursor: CKQueryCursor?, error: Error?) -> Void in
            if error != nil {
                DLog("\(error!.localizedDescription)")
            }
        }
        return block
    }
    
    class func modificationDateSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: BaseCoreDataModel.modificationDateProperty, ascending: true)
    }
    
    class func defaultSortDescriptors() -> [NSSortDescriptor] {
        return [modificationDateSortDescriptor()]
    }
    
    // MARK: - Save to local database
    
    class func createDBVideo(fromDataSource cloudSource: CKRecord){
        //unique key
        //let videoID = cloudSource["youtubeVideoId"] as! String
        let newVideo = Video(inContext: mainContext)
        newVideo.update(fromCloudRecord: cloudSource)
    }
    
    class func createOrUpdateDBMathObject(fromDataSource cloudSource: CKRecord){
        
        let hashTag = cloudSource["hashTag"] as! String
        
        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format: "hashTag == %@", hashTag)
        do {
            let mo = try mainContext.fetch(request)
            if mo.count == 0 {
                let newMathObject = MathObject(inContext: mainContext)
                newMathObject.update(fromCloudRecord: cloudSource)
            } else if mo.count == 1 {
                mo[0].update(fromCloudRecord: cloudSource)
            } else {
                print("error - too many MathObjects \(hashTag) -- \(mo.count)")
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    class func createOrUpdateDBFeaturedURL(fromDataSource cloudSource: CKRecord){
        //let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let ourFeaturedURLHashtag = cloudSource["ourFeaturedURLHashtag"] as! String
        
        let request = FeaturedURL.createFetchRequest()
        request.predicate = NSPredicate(format: "ourFeaturedURLHashtag == %@", ourFeaturedURLHashtag)
        do{
            let furl = try mainContext.fetch(request)
            if furl.count == 0{
                let newFeature = FeaturedURL(inContext: mainContext)
                newFeature.update(fromCloudRecord: cloudSource)
            }else if furl.count == 1{
                furl[0].update(fromCloudRecord: cloudSource)
            }else{
                print("error - too many featuredURLS \(ourFeaturedURLHashtag) -- \(furl.count)")
            }
        }catch{
            print("Fetch failed")
        }
    }
    
    class func createOrUpdateDBMathObjectLinks(fromCloudRecord cloudRecord: CKRecord){
        let request = MathObjectLink.createFetchRequest() //QQQQ name of object is singular or plural?
//        request.predicate = NSPredicate(format: "recordID == %@", cloudSource.recordID)
        request.predicate = NSPredicate(format: "recordName == %@", cloudRecord.recordID.recordName)
        do{
            let mol = try mainContext.fetch(request)
            if mol.count == 0{
                let newMathObjectLink = MathObjectLink(inContext: mainContext)
                newMathObjectLink.update(fromCloudRecord: cloudRecord)
            }else if mol.count == 1{
                mol[0].update(fromCloudRecord: cloudRecord)
            }else{
                DLog("error - too many MathObjectLinks \(cloudRecord.recordID.recordName) -- \(mol.count)")
            }
        }catch{
            DLog("Fetch failed")
        }
    }
    
    // MARK: - Read from cloud kit
    
    class func readRecordsFromCloud(recordTypeName: String, cursor: CKQueryCursor? = nil, latestDate: Date,
                                    saveRecordBlock: @escaping (CKRecord) -> (), completion: @escaping () -> ()) {

        let operation: CKQueryOperation
        
        if cursor != nil {
            
            operation = CKQueryOperation(cursor: cursor!)
            
        } else {
            
            readRecordsCount[recordTypeName] = 0
            
            let predicate = NSPredicate(format: "\(BaseCoreDataModel.modificationDateProperty) > %@", latestDate as NSDate)
            let query = CKQuery(recordType: recordTypeName, predicate: predicate)
            query.sortDescriptors = defaultSortDescriptors()
    
            operation = CKQueryOperation(query: query)
            
        }
        
        operation.recordFetchedBlock = { record in
            readRecordsCount[recordTypeName]! += 1
            if isInAdminMode {
                DLog("\(recordTypeName) - RECORD FETCHED BLOCK - \(readRecordsCount[recordTypeName]!)")
            }
            DispatchQueue.main.async {
                saveRecordBlock(record)
            }
        }
        
        operation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: Error?) -> Void in
            if error != nil {
                DLog("\(error!.localizedDescription)")
            }
            
            if cursor != nil {
                
                readRecordsFromCloud(recordTypeName: recordTypeName, cursor: cursor, latestDate: latestDate,
                                     saveRecordBlock: saveRecordBlock, completion: completion)
                
            } else {
                
                DLog("\(recordTypeName) finish fetch records. Count: \(readRecordsCount[recordTypeName]!)")
                completion()
                
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func readVideoDataFromCloud(_ inCollection: Bool) {
        
        EpsilonStreamBackgroundFetch.setActionStart()
        
        finishedVideos = false
        let pred1 = NSPredicate(format: "\(BaseCoreDataModel.modificationDateProperty) > %@", latestVideoDate as NSDate)
        let pred2 = NSPredicate(format: "isInVideoCollection = %@", NSNumber(booleanLiteral: inCollection))
        let pred = inCollection ? NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2]) : pred1
        
        let query = CKQuery(recordType: "Video", predicate: pred)
        query.sortDescriptors = defaultSortDescriptors()
        
        let operation = CKQueryOperation(query: query)
        //operation.qualityOfService = .userInteractive //QQQQ this is maybe abusive - but may speed up
        //operation.resultsLimit = queryOperationResultLimit
        
        videoNum = 0
        operation.recordFetchedBlock = populate(withVideoRecord:)
        
        var gotCursor = false
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil{
                    gotCursor = true
                    fetchVideoRecords(withCursor: cursor!)
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
            //            DispatchQueue.main.async {
            //                EpsilonStreamDataModel.setLatestDates() //QQQQ not clear if best here --
            //            }
            if gotCursor == false {
                DLog("Video records fetched. Count: \(videoNum)")
                finishedVideos = true
                onFinish() //QQQQ should this be in a mutex?
                //QQQQ is this really called after the last fetchVideoRecords??? Could be a problem.
                EpsilonStreamBackgroundFetch.setActionFinish()
            }//otherwise will be set by fetchVideoRecords()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func populate(withVideoRecord record: CKRecord) {
        if let videoID = record["youtubeVideoId"] as? String {
            videoNum = videoNum + 1
            if isInAdminMode {
                DLog("Video - RECORD FETCHED BLOCK -- \(videoNum), \(videoID)")
            }
            DispatchQueue.main.async{
                var video: Video! = nil
                let vids = EpsilonStreamDataModel.videos(ofYoutubeId: videoID)
                
                if vids.count == 0{ //new video
                    video = Video(inContext: mainContext)
                }else{
                    video = vids[0]
                    if vids.count > 1{
                        print("error too many videos")
                    }
                }
                video.update(fromCloudRecord: record)
            }
        } else {
            print("error got no video id on video from cloud")
        }
    }
    
    class func fetchVideoRecords(withCursor cursor: CKQueryCursor){
        let operation = CKQueryOperation(cursor: cursor)
        //operation.qualityOfService = .userInteractive
        operation.recordFetchedBlock = populate(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil {
                //print("no error")
                if cursor != nil {
                    fetchVideoRecords(withCursor: cursor!)
                } else {
                    DLog("Video records fetched. Count: \(videoNum)")
                    finishedVideos = true
                    onFinish() //QQQQ should this be in a mutex?
                    EpsilonStreamBackgroundFetch.setActionFinish()
                }
            }else{
                print("\(error!.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    class func gotRecord(withVideoRecord record: CKRecord){
        let videoID = record["youtubeVideoId"] as! String
        if let num = videoCount[videoID] {
            videoCount[videoID] = num + 1
        } else {
            videoCount[videoID] = 1
        }
    }
    
    class func peekVideoRecords(withCursor cursor: CKQueryCursor) {
        let operation = CKQueryOperation(cursor: cursor)
        //operation.qualityOfService = .userInteractive
        operation.recordFetchedBlock = gotRecord(withVideoRecord:)
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil {
                //print("no error")
                if cursor != nil {
                    peekVideoRecords(withCursor: cursor!)
                }else{
                    //onFinish() //QQQQ should this be in a mutex?
                    peekVideoDone = true
                    print("done")
                }
            } else {
                DLog("\(error!.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    // This is for getting all the videos in the cloud and seeing what they are
    class func peekVideoDataFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart() //QQQQ?
        
        videoCount = [:]
        
        let query = CKQuery(recordType: "Video", predicate: NSPredicate(value: true) )
        query.sortDescriptors = defaultSortDescriptors()
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = gotRecord(withVideoRecord:)
        
        var gotCursor = false
        
        operation.queryCompletionBlock = { (cursor, error) in
            if error == nil{
                //print("no error")
                if cursor != nil {
                    gotCursor = true
                    peekVideoRecords(withCursor: cursor!)
                }
            } else {
                print("\(error!.localizedDescription)")
            }
        }
        
        operation.completionBlock = {
            if gotCursor == false {
                //QQQQ is this really called after the last fetchVideoRecords??? Could be a problem.
                EpsilonStreamBackgroundFetch.setActionFinish()
            }//otherwise will be set by fetchVideoRecords()
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    //QQQQ add inCollectionFilter (also to Features and MathObjectLinks)
    class func readMathObjectsFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart()
        
        finishedMathObjects = false
        readRecordsFromCloud(recordTypeName: MathObject.cloudTypeName, latestDate: latestMathObjectDate, saveRecordBlock: { (record) in
            createOrUpdateDBMathObject(fromDataSource: record)
        }) {
            finishedMathObjects = true
            onFinish() //QQQQ should this be in a mutex?
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
    }
    
    class func readMathObjectLinksFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart()
        
        finishedMathObjectLinks = false
        readRecordsFromCloud(recordTypeName: MathObjectLink.cloudTypeName, latestDate: latestMathObjectLinkDate, saveRecordBlock: { (record) in
            createOrUpdateDBMathObjectLinks(fromCloudRecord: record)
        }) {
            finishedMathObjectLinks = true
            onFinish() //QQQQ should this be in a mutex?
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
    }
    
    class func readFeaturedURLsFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart()
        
        finishedFeaturedURLs = false
        readRecordsFromCloud(recordTypeName: FeaturedURL.cloudTypeName, latestDate: latestFeatureDate, saveRecordBlock: { (record) in
            createOrUpdateDBFeaturedURL(fromDataSource: record)
        }) {
            finishedFeaturedURLs = true
            onFinish() //QQQQ should this be in a mutex?
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
    }
    
    class func readSnippetsFromCloud() {
        EpsilonStreamBackgroundFetch.setActionStart()
        
        finishedSnippets = false
        readRecordsFromCloud(recordTypeName: Snippet.cloudTypeName, latestDate: latestSnippetsDate, saveRecordBlock: { (record) in
            Snippet.createOrUpdateFromCloudRecord(record: record)
        }) {
            finishedSnippets = true
            onFinish() //QQQQ should this be in a mutex?
            EpsilonStreamBackgroundFetch.setActionFinish()
        }
    }

}

