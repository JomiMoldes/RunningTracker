import Foundation

class CachedDateFormatter {

    static let sharedInstance = CachedDateFormatter()

    var cachedDateFormatters = [String: DateFormatter]()

    fileprivate init(){}

    func formatterWith(_ format:String, timeZone:TimeZone = TimeZone.autoupdatingCurrent, locale:Locale = Locale(identifier:"en_US")) -> DateFormatter {
        let key = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"

        if let cachedDateFormatter = cachedDateFormatters[key] {
            return cachedDateFormatter
        } else {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = format
            newDateFormatter.timeZone = timeZone
            newDateFormatter.locale = locale
            cachedDateFormatters[key] = newDateFormatter
            return newDateFormatter
        }
    }
}
