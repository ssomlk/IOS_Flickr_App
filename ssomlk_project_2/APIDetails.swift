//
//  APIDetails.swift
//  ssomlk_project_2
//
//  Created by Wijekoon Mudiyanselage Shanka Primal Somasiri on 13/11/17.
//  Copyright © 2017 Wijekoon Mudiyanselage Shanka Primal Somasiri. All rights reserved.
//

import Foundation

struct ApiInfo {
    
    struct ApiParameters{
        static let DOMAIN = "https://"
        static let METHOD = "method="
        static let API_KEY = "api_key="
        static let TEXT = "text="
        static let BBOX = "bbox="
        static let FORMAT = "format="
        static let JSONCALLBACK = "nojsoncallback="
        static let AUTH_TOKEN = "auth_token="
        static let API_SIG = "api_sig="
    }
    
    struct ApiParameterValues {
        static let DOMAIN = "api.flickr.com/services/rest/?"
        static let METHOD = "flickr.photos.search"
        static var API_KEY = "dc67297cf9ce36994deac679d131dccc"
        static var TEXT = "Sri+Lanka"
        static var BBOX = "-180%2C-90%2C180%2C90"
        static let FORMAT = "json"
        static let JSONCALLBACK = "1"
        static var AUTH_TOKEN = "72157666273619329-8a500c0f94e31a37"
        static var API_SIG = "18163bb6369c8eaabc04f304c618358d"
    }
    
}
