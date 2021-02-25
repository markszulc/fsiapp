//
//  offerlist.swift
//  foo
//
//  Created by Mark Szulc on 21/2/21.
//

import SwiftUI

struct offerlist: View {
    
    @ObservedObject var fetcher = AEM_offerFetcher()
    
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 7) {

             
                 Text("Our Offers")
                           .font(.title)
                           .bold()


                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack (alignment: .top, spacing: 20) {
                         ForEach(fetcher.offerlistheadless, id: \.headline) { offer in
                             

                                     VStack (alignment: .leading, spacing: 10) {
        
                                        let url = URL(string: offer.heroImage._publishUrl + "/_jcr_content/renditions/cq5dam.web.1280.1280.jpeg")!
                                        
                                        AsyncImage(
                                            url: url,
                                           placeholder: { Text("Loading ...") },
                                           image: { Image(uiImage: $0)
                                                .resizable()
                                           }
                                        ).frame(height: 160)

                                        
                                         Text(offer.headline)
                                          .font(.system(size: 24))
                                          .bold()
                                            .padding(10)

                                        Text(offer.details.plaintext)
                                          .font(.system(size: 18))
                                            .padding(10)

                                        Spacer()

                                     }
                                     .frame(width: 250, height: 350)
                                     .background(Color.orange)
                                     .border(Color.white)


                                    
                                 }
                             
                         }
                         .frame(height: 450)
                     }
       
             }.foregroundColor(.white)

        
        
    }
}

struct offerlist_Previews: PreviewProvider {
    static var previews: some View {
        offerlist()
    }
}


public class AEM_offerFetcher: ObservableObject {
    @Published var offerlistheadless = [Offer.Data.OfferList.Items]()
    
    init(){
        load()
    }
    
    func load() {
            
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = "{\"query\":\"{\\n  offersList {\\n    items {\\n      headline\\n      details {\\n        plaintext\\n      }\\n      heroImage {\\n        ... on ImageRef {\\n          _path\\n    _publishUrl\\n     }\\n      }\\n    }\\n  }\\n}\\n\",\"variables\":{}}"

        
        let postData = parameters.data(using: .utf8)

        let url = URL(string: "https://publish-p23811-e67708.adobeaemcloud.com/apps/graphql-enablement/content/endpoint.gql")!

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
    
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            //print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
            do {
                let offerJSON = try JSONDecoder().decode(Offer.self, from: data)
                let offerCount = offerJSON.data.offersList.items.count
                            print(offerCount)
                           
                            DispatchQueue.main.async {
                                self.offerlistheadless = offerJSON.data.offersList.items
                                dump(self.offerlistheadless)
                            }
                            
                            
                            } catch let jsonErr {
                                            print(".................................")
                                            print("Error serializing json:", jsonErr)
                            }
        
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()

      
    }

}


struct Offer: Codable {
    struct Data : Codable {
        struct OfferList : Codable {
                struct Items : Codable {
                    struct Details : Codable {
                        let plaintext:String
                    }
                    struct HeroImage : Codable {
                        let _publishUrl: String
                    }
                    let headline:String
                    let details:Details
                    let heroImage:HeroImage
                }
            let items:[Items]
        }
        let offersList:OfferList

    }
     let data:Data
}


