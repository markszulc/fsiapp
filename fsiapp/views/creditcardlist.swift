//
//  creditcardlist.swift
//  foo
//
//  Created by Mark Szulc on 21/2/21.
//

import SwiftUI

struct creditcardlist: View {
    
    @ObservedObject var fetcher = AEM_CreditCardFetcher()
    
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 7) {
            
            
                 Text("Our Credit Cards")
                           .font(.title)
                           .bold()


                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack (alignment: .top, spacing: 20) {
                         ForEach(fetcher.creditcardlistheadless, id: \.creditCardName) { creditcard in
                             

                                     VStack (alignment: .leading, spacing: 10) {
        
                                       // let url = URL(String: creditcard.creditCardImage._publishUrl)!
                                        //let url = URL(string: "https://image.tmdb.org/t/p/original/pThyQovXQrw2m0s9x82twj48Jq4.jpg")!
                                        let url = URL(string: creditcard.creditCardImage._publishUrl)!
                                        
                                        
                                        AsyncImage(
                                            url: url,
                                           placeholder: { Text("Loading ...") },
                                           image: { Image(uiImage: $0)
                                                .resizable()
                                               
                                           }
                                        ).frame(width: 202, height: 127)

                                        
                                         Text(creditcard.creditCardName)
                                          .font(.system(size: 24))
                                          .bold()
             
                                        Text(creditcard.shortSummary.plaintext)
                                          .font(.system(size: 18))
                                        
                                     }
                                     .padding()
                                     .frame(width: 250, height: 400)
                                     .background(Color.orange)
                                     .border(Color.white)



                                 }
                             
                         }
                         .frame(height: 450)
                     }
       
             }.foregroundColor(.white)

        
        
    }
}

struct creditcardlist_Previews: PreviewProvider {
    static var previews: some View {
        creditcardlist()
    }
}


public class AEM_CreditCardFetcher: ObservableObject {
    @Published var creditcardlistheadless = [CreditCard.Data.CreditCardList.Items]()
    
    init(){
        load()
    }
    
    func load() {
            
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = "{\"query\":\"{\\n  creditCardsList {\\n    items {\\n      creditCardName\\n      shortSummary {\\n        plaintext\\n      }\\n      creditCardImage {\\n        ... on ImageRef {\\n            _publishUrl\\n            width\\n            height\\n            }\\n      }\\n    }\\n}\\n}\\n\",\"variables\":{}}"
        
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
                let creditcardJSON = try JSONDecoder().decode(CreditCard.self, from: data)
                let creditcardCount = creditcardJSON.data.creditCardsList.items.count
                            print(creditcardCount)
                           
                            DispatchQueue.main.async {
                                self.creditcardlistheadless = creditcardJSON.data.creditCardsList.items
                                dump(self.creditcardlistheadless)
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


struct CreditCard: Codable {
    struct Data : Codable {
        struct CreditCardList : Codable {
                struct Items : Codable {
                    struct ShortSummary : Codable {
                        let plaintext:String
                    }
                    struct CreditCardImage : Codable {
                        let _publishUrl: String
                    }
                    let creditCardName:String
                    let shortSummary:ShortSummary
                    let creditCardImage:CreditCardImage
                }
            let items:[Items]
        }
        let creditCardsList:CreditCardList

    }
     let data:Data
}


