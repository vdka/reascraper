
import Foundation
import Regex
import Kanna

extension URLSession {

    func syncDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {

        let semaphore = DispatchSemaphore(value: 0)

        var data: Data?
        var response: URLResponse?
        var error: Error?

        dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }.resume()

        semaphore.wait()

        return (data, response, error)
    }
}

var links: [String] = []
while let link = readLine() { links.append(link) }
links = links.filter({ $0.hasPrefix("http") })
guard !links.isEmpty else { print("ERROR: Bad invocation"); exit(1) }

func column(_ thing: Any?) {
    print(thing ?? " ", terminator: "\t")
}

for link in links {
    let (data, response, error) = URLSession.shared.syncDataTask(with: URL(string: link)!)

    guard (response as! HTTPURLResponse).statusCode != 404 else { print("\(link)\tREMOVED"); continue }
    if let error = error { print("\(link)\tERROR"); continue }
    guard data != nil else { print("\(link)\tNODATA"); continue }
    guard let doc = HTML(html: data!, encoding: .utf8) else { print("\(link)\tBADDATA"); continue }


    let info = doc.at_xpath("//div[@id='baseInfo']")!

    let street = info.at_xpath("//span[@itemprop='streetAddress']")?.text
    let suburb = info.at_xpath("//span[@itemprop='addressLocality']")?.text
    let postCode = info.at_xpath("//span[@itemprop='postalCode']")?.text
    let price = Regex("(\\$\\d+)").match(info.at_xpath("//p[@class='priceText']")?.text ?? "")?.captures[0]
    let stats = info.at_xpath("//li[@class='property_info']")!
    let available = info.at_xpath("//div[@class='available_date']/span")?.text
    let nBeds = stats.at_xpath("//dd[1]")?.text
    let nBaths = stats.at_xpath("//dd[2]")?.text

    column(link)
    column(" ")
    column(street)
    column(suburb)
    column(postCode)
    column(available)
    column(price)
    column(nBeds)
    column(nBaths)
    print()
}
