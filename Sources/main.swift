
import Foundation
import Kanna

struct log {
    static func error(_ msg: Any) -> Never {
        print("ERROR: \(msg)")
        fflush(stdout)
        exit(1)
    }
    
    static func warning(_ msg: Any) {
        print("WARN: \(msg)")
    }
}

struct Property {
    
    var street: String
    var suburb: String
    var postCode: String
    
    var price: String
//    var priceUpper: String?
    
    var nBeds: String
    var nBaths: String
    var nParks: String
    
    init?(doc: HTMLDocument) {
        let info = doc.at_xpath("//div[@id='baseInfo']")!
        guard 
            let street = info.at_xpath("//span[@itemprop='streetAddress']")?.text,
            let suburb = info.at_xpath("//span[@itemprop='addressLocality']")?.text,
            let postCode = info.at_xpath("//span[@itemprop='postalCode']")?.text,
            let price = info.at_xpath("//p[@class='priceText']")?.text,
            let stats = info.at_xpath("//li[@class='property_info']"),
            let nBeds = stats.at_xpath("//dd[1]")?.text,
            let nBaths = stats.at_xpath("//dd[2]")?.text,
            let nParks = stats.at_xpath("//dd[3]")?.text
            else { return nil }
        self.street = street
        self.suburb = suburb
        self.postCode = postCode
        
        self.price = price
        
        self.nBeds = nBeds
        self.nBaths = nBaths
        self.nParks = nParks
    }
    
    var tabulated: String {
        return [street, suburb, postCode, price, nBeds, nBaths].joined(separator: "\t")
    }
}

let links = CommandLine.arguments.filter({ $0.hasPrefix("http") })
guard !links.isEmpty else { log.error("Bad invocation") }

var running = 0

for link in links {
    guard let url = URL(string: link) else {
        print("bad url: \(link)")
        continue
    }
    
    running += 1
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error { log.error(error) }
        guard let data = data else { log.error("No data received") }
        guard let doc = HTML(html: data, encoding: .utf8) else { log.error("Bad data") }
        
        if let prop = Property(doc: doc) {
            print(link, terminator: "\t")
            print(prop.tabulated)
        } else {
            log.warning("Failed to initialize property")
        }
        
        running -= 1
    }.resume()
}

while running > 0 {}

