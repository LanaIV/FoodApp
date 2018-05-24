
//
//  NetworkManager.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import Alamofire
import RxSwift
import RxAlamofire
import Unbox

enum NetworkError: Error {
    case http
    case api
    case jsonParse
    case undefined
}

typealias ResultDictionaryType = Dictionary<String, Any>
typealias RecipePhotoHandlerType = (Data, NetworkError?) -> Void
typealias RecipeDetailHandlerType = (Recipe, NetworkError?) -> Void
typealias RecipesListHandlerType = (RecipesArrayType, NetworkError?) -> Void

typealias UnboxableArray = Array<UnboxableDictionary>
struct NetworkManager {

    static let apiKey = "1b151d85ae6795114575832ef90d4483"
    static let detailRequestUrl = "https://food2fork.com/api/get"
    static let searchRequestUrl = "https://food2fork.com/api/search"

    static func searchRecipes(query: String) -> Observable<RecipesArrayType> {
        let url = "\(searchRequestUrl)?key=\(apiKey)&q=\(query)"
        return Observable.create { (observer) -> Disposable in
            let request = Alamofire.request(url).responseJSON { response in
                guard response.error == nil else {
                    observer.onError(NetworkError.http)
                    return
                }
                guard let result = response.result.value as? UnboxableDictionary, let recipesResult = result["recipes"] as? UnboxableArray else {
                    observer.onError(NetworkError.api)
                    return
                }

                do {
                    let recipes: RecipesArrayType = try unbox(dictionaries: recipesResult)
                    observer.onNext(recipes)
                } catch {
                    observer.onError(NetworkError.jsonParse)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }

    static func retrieveRecipeDetail(id: String) -> Observable<(Recipe?, Error?)> {
        let url = "\(detailRequestUrl)?key=\(apiKey)&rId=\(id)"
        return requestJSON(.get, url)
            .map({ (_, response) -> (Recipe?, Error?) in
                if type(of: response) is Error {
                    return (nil, NetworkError.http)
                }
                guard let result = response as? UnboxableDictionary else {
                    return (nil, NetworkError.api)
                }

                do {
                    let recipe: Recipe = try unbox(dictionary: result, atKey: "recipe")
                    return (recipe, nil)
                } catch {
                    return (nil, NetworkError.jsonParse)
                }
            })
            .observeOn(MainScheduler.instance)
    }


    static func retrieveRecipePhoto(imageUrl: String) -> Observable<Data> {
        let httpsImageUrl = imageUrl.replacingOccurrences(of: "http", with: "https")
        return Observable.create { (observer) -> Disposable in
            let request = Alamofire.request(httpsImageUrl).responseData { response in
                guard response.error == nil else {
                    observer.onError(NetworkError.http)
                    return
                }
                guard let data = response.result.value else {
                    observer.onError(NetworkError.api)
                    return
                }

                observer.onNext(data)
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

extension Data {
    func decodeHTMLCaracters() -> Data {
        let options: Dictionary<NSAttributedString.DocumentReadingOptionKey, Any> = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: self, options: options, documentAttributes: nil), let decodedData = attributedString.string.data(using: .utf8) else {
            return Data()
        }
        return decodedData
    }
}
