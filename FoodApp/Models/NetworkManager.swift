
//
//  NetworkManager.swift
//  FoodApp
//
//  Created by Lana on 06/05/2018.
//  Copyright © 2018 Rizna. All rights reserved.
//

import Alamofire
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

    static func searchRecipes(query: String, handler: @escaping RecipesListHandlerType) {
        let url = "\(searchRequestUrl)?key=\(apiKey)&q=\(query)"
        let request = Alamofire.request(url).responseJSON { response in
            guard response.error == nil else {
                handler([], NetworkError.http)
                return
            }
            guard let result = response.result.value as? UnboxableDictionary, let recipesResult = result["recipes"] as? UnboxableArray else {
                handler([], NetworkError.api)
                return
            }

            do {
                let recipes: RecipesArrayType = try unbox(dictionaries: recipesResult)
                handler(recipes, nil)
            } catch {
                handler([], NetworkError.jsonParse)
            }
        }
    }

    static func retrieveRecipeDetail(id: String, handler: @escaping RecipeDetailHandlerType) {
        let url = "\(detailRequestUrl)?key=\(apiKey)&rId=\(id)"
        Alamofire.request(url).responseJSON { response in
            guard response.error == nil else {
                handler(Recipe(), NetworkError.http)
                return
            }
            guard let result = response.result.value as? UnboxableDictionary else {
                handler(Recipe(), NetworkError.api)
                return
            }

            do {
                let recipe: Recipe = try unbox(dictionary: result, atKey: "recipe")
                handler(recipe, nil)
            } catch {
                handler(Recipe(), NetworkError.jsonParse)
            }
        }
    }


    static func retrieveRecipePhoto(imageUrl: String, handler: @escaping RecipePhotoHandlerType) {
        let url = imageUrl.replacingOccurrences(of: "http", with: "https")
        Alamofire.request(url).responseData { response in
            guard response.error == nil else {
                handler(Data(), NetworkError.http)
                return
            }
            guard let data = response.result.value else {
                handler(Data(), NetworkError.api)
                return
            }

            handler(data, nil)
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
