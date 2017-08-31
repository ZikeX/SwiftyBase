//
//  AppUtility.swift
//  Pods
//
//  Created by MacMini-2 on 30/08/17.
//
//

import UIKit
import SystemConfiguration

open class AppUtility: NSObject {
    
    //  MARK: - Network Connection Methods
    
    public class func isNetworkAvailableWithBlock(_ completion: @escaping (_ wasSuccessful: Bool) -> Void) {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            completion(false)
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        completion(isReachable && !needsConnection )
    }
    
    //  MARK: - User Defaults Methods
    
    public class func getUserDefaultsObjectForKey(_ key: String)->AnyObject{
        let object: AnyObject? = UserDefaults.standard.object(forKey: key) as AnyObject?
        return object!
    }
    
    public class func setUserDefaultsObject(_ object: AnyObject, forKey key: String) {
        UserDefaults.standard.set(object, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    public class func clearUserDefaultsForKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public class func clearUserDefaults(){
        let appDomain: String = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
    }
    
    public class func getDocumentDirectoryPath() -> String
    {
        let arrPaths : NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        return arrPaths[0] as! String
    }
    
    public class func stringByPathComponet(fileName : String , Path : String) -> String
    {
        var tmpPath : NSString = Path as NSString
        tmpPath = tmpPath.appendingPathComponent(fileName) as NSString
        return tmpPath as String
    }
    
    //  MARK: - UIDevice Methods
    
    public class func getDeviceIdentifier()->String{
        let deviceUUID: String = UIDevice.current.identifierForVendor!.uuidString
        return deviceUUID
    }
    
    //  MARK: - Misc Methods
   
    //  MARK: - Time-Date Methods
    
    public class func convertDateToLocalTime(_ iDate: Date) -> Date {
        let timeZone: TimeZone = TimeZone.autoupdatingCurrent
        let seconds: Int = timeZone.secondsFromGMT(for: iDate)
        return Date(timeInterval: TimeInterval(seconds), since: iDate)
    }
    
    public class func convertDateToGlobalTime(_ iDate: Date) -> Date {
        let timeZone: TimeZone = TimeZone.autoupdatingCurrent
        let seconds: Int = -timeZone.secondsFromGMT(for: iDate)
        return Date(timeInterval: TimeInterval(seconds), since: iDate)
    }
    
    public class func getCurrentDateInFormat(_ format: String)->String{
        
        let usLocale: Locale = Locale(identifier: "en_US")
        
        let timeFormatter: DateFormatter = DateFormatter()
        timeFormatter.dateFormat = format
        
        timeFormatter.timeZone = TimeZone.autoupdatingCurrent
        timeFormatter.locale = usLocale
        
        let date: Date = Date()
        let stringFromDate: String = timeFormatter.string(from: date)
        
        return stringFromDate
    }
    
    public class func getDate(_ date: Date, inFormat format: String) -> String {
        
        let usLocale: Locale = Locale(identifier: "en_US")
        let timeFormatter: DateFormatter = DateFormatter()
        
        timeFormatter.dateFormat = format
        timeFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        timeFormatter.locale = usLocale
        
        let stringFromDate: String = timeFormatter.string(from: date)
        
        return stringFromDate
    }
    
    
    public class func convertStringDateFromFormat(_ inputFormat:String, toFormat outputFormat:String, fromString dateString:String)->String{
        
        let usLocale: Locale = Locale(identifier: "en_US")
        
        var dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = usLocale
        dateFormatter.dateFormat = inputFormat
        
        dateFormatter = DateFormatter()
        let date: Date = dateFormatter.date(from: dateString)!
        
        dateFormatter.locale = usLocale
        dateFormatter.dateFormat = outputFormat
        
        let resultedDateString: String = dateFormatter.string(from: date)
        
        return resultedDateString
    }
    
    public class func getTimeStampForCurrentTime()->String{
        let timestampNumber: NSNumber = NSNumber(value: (Date().timeIntervalSince1970) * 1000 as Double)
        return timestampNumber.stringValue
    }
    
    public class func getTimeStampFromDate(_ iDate: Date) -> String {
        let timestamp: String = String(iDate.timeIntervalSince1970)
        return timestamp
    }
    
    public class func getCurrentTimeStampInGMTFormat() -> String {
        return AppUtility.getTimeStampFromDate(AppUtility.convertDateToGlobalTime(Date()))
    }
    
    //  MARK: - GCD Methods
    
    public class func executeTaskAfterDelay(_ delay: CGFloat, completion completionBlock: @escaping () -> Void)
    {
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * CGFloat(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            completionBlock()
        }
    }
    
    public class func executeTaskInMainThreadAfterDelay(_ delay: CGFloat, completion completionBlock: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * CGFloat(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            completionBlock()
        })
    }
    
    public class func executeTaskInGlobalQueueWithCompletion(_ completionBlock: @escaping () -> Void) {
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            completionBlock()
        })
    }
    
    public class func executeTaskInMainQueueWithCompletion(_ completionBlock: @escaping () -> Void) {
        DispatchQueue.main.async(execute: {() -> Void in
            completionBlock()
        })
    }
    
    public class func executeTaskInGlobalQueueWithSyncCompletion(_ completionBlock: () -> Void) {
        DispatchQueue.global(qos: .default).sync(execute: {() -> Void in
            completionBlock()
        })
    }
    
    public class func executeTaskInMainQueueWithSyncCompletion(_ completionBlock: () -> Void) {
        DispatchQueue.main.sync(execute: {() -> Void in
            completionBlock()
        })
    }
    
    //  MARK: - Data Validation Methods
    
    public class func isValidEmail(_ checkString: String)->Bool{
    
        let laxString: String = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let emailRegex: String = laxString
        
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailTest.evaluate(with: checkString)
    }
    
    public class func isValidPhone(_ phoneNumber: String) -> Bool {
        let phoneRegex: String = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@",phoneRegex)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    public class func isValidURL(_ candidate: String) -> Bool {
        let urlRegEx: String = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let urlTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@",urlRegEx)
        return urlTest.evaluate(with: candidate)
    }
    
    public class func isTextFieldBlank(_ textField : UITextField) -> Bool    {
        return (textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)!
    }
    
    public class func isValidPhoneNoCountTen(_ mobileNo : String) -> Bool    {
        return mobileNo.characters.count == 10 ? true : false
    }
    
    // check the name is between 4 and 16 characters
    public func validateCharCount(_ name: String,minLimit : Int,maxLimit : Int) -> Bool    {
        if !(minLimit...maxLimit ~= name.characters.count) {
            return false
        }
        return true
    }
    
    public func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
    
    ///Change file size
    
    //myImageView.image =  ResizeImage(myImageView.image!, targetSize: CGSizeMake(600.0, 450.0))
    //
    //let imageData = UIImageJPEGRepresentation(myImageView.image!,0.50)
    
    public func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
