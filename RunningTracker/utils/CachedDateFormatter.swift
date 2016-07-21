import Foundation

class CachedDateFormatter {

    static let sharedInstance = CachedDateFormatter()

    var cachedDateFormatters = [String: NSDateFormatter]()

    private init(){}

    func formatterWith(format:String, timeZone:NSTimeZone = NSTimeZone.localTimeZone(), locale:NSLocale = NSLocale(localeIdentifier:"en_US")) -> NSDateFormatter {
        let key = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"

        if let cachedDateFormatter = cachedDateFormatters[key] {
            return cachedDateFormatter
        } else {
            let newDateFormatter = NSDateFormatter()
            newDateFormatter.dateFormat = format
            newDateFormatter.timeZone = timeZone
            newDateFormatter.locale = locale
            cachedDateFormatters[key] = newDateFormatter
            return newDateFormatter
        }
    }
}
