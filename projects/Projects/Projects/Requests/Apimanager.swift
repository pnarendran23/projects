//
//  Apimanager.swift
//  Projects
//
//  Created by Group X on 07/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class Apimanager{

    var maximum = 15
    let elasticbaseURL = "https://elastic:MK3LYTX4Na7P4C0NideSkuZR@bc4873cb03004570b352903584124c54.us-east-1.aws.found.io:9243/elasticsearch_index_pantheon_"
    let baseUSGBCURL: String = "https://dev.usgbc.org/mobile/services"
    var a : DataRequest!
    static let shared = Apimanager()
    let partneralias = "usgbcmobile"
    let partnerpwd = "usgbcmobilepwd"
    
    // To get Projects data for map
    func getProjectsElasticForMap(from: Int, sizee: Int, search: String, category: String, callback: @escaping (Int?, [Project]?, Int?) -> () ){
        var url = elasticbaseURL + "projects_ios/_search"
        let searchText = search
        if(!search.isEmpty){
            url = elasticbaseURL + "projects_ios/_search?q=*\(Payloads().converttoEncoded(parameter: searchText))*"
            url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        print(url)
        var params: [String: Any] = [:]
        params = [ "size": 500000, "from":from]
        if(category == "All"){
            
        }else{
            let cat = "\(category)"
            url = elasticbaseURL + "projects_ios/_search?q=\(cat)"
            if(!search.isEmpty){
                url = elasticbaseURL + "projects_ios/_search?q=%22\(Payloads().converttoEncoded(parameter: searchText))%22 AND %28field_prjt_rating_system_version:%28\(cat)%29%29"
            }
            url = url.replacingOccurrences(of: "%25", with: "")
            url = url.replacingOccurrences(of: " ", with: "%20")
            //url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            //params = [ "size": sizee]
        }
        if(category.count == 0 && search.count == 0){
            url = elasticbaseURL + "projects_ios/_search"
        }else if(category.count == 0 && search.count > 0){
            url = elasticbaseURL + "projects_ios/_search?q=*\(Payloads().converttoEncoded(parameter: searchText))*"
        }else if(category.count > 0 && search.count > 0){
            if(category == "All"){
                url = elasticbaseURL + "projects_ios/_search?q=*\(Payloads().converttoEncoded(parameter: searchText))*"
            }else{
                let cat = "\(category)"
                url = elasticbaseURL + "projects_ios/_search?q=*\(Payloads().converttoEncoded(parameter: searchText))*%20AND%20%28field_prjt_rating_system_version:%28\(cat)%29%29"
            }
        }else if(category.count > 0 && search.count == 0 && category != "All"){
            let cat = "\(category)"
            url = elasticbaseURL + "projects_ios/_search?q=%28field_prjt_rating_system_version:%28\(cat)%29%29"
        }
        url = url.replacingOccurrences(of: "%25", with: "")
        url = url.replacingOccurrences(of: " ", with: "%20")
        url = url.replacingOccurrences(of: "+", with: "%2B")
        print(url)
        a = Alamofire.request(url, method: .get, parameters: params)
            .validate()
            .responseJSON { response in
                print(response.request ?? "Error in request")
                switch response.result {
                case .success( _):
                    if let jsonString = response.data {
                        do{
                            var projects = [Project]()
                            let json = try JSON(data: jsonString)
                            let totalRecords = json["hits"]["total"].intValue
                            for (_,subJson):(String, JSON) in json["hits"]["hits"] {
                                let project = Project()
                                project.title = (subJson["_source"]["title"].arrayValue.first?.stringValue)!
                                project.ID = (subJson["_source"]["field_prjt_id"].arrayValue.first?.stringValue)!
                                project.certification_level = (subJson["_source"]["field_prjt_certification_level"].arrayValue.first?.stringValue)!
                                project.lat = (subJson["_source"]["lat"].arrayValue.first?.stringValue)!
                                project.long = (subJson["_source"]["lng"].arrayValue.first?.stringValue)!
                                project.image = (subJson["_source"]["field_prjt_profile_image"].arrayValue.first?.stringValue)!
                                project.rating_system_version = (subJson["_source"]["field_prjt_rating_system_version"].arrayValue.first?.stringValue ?? "")
                                project.address = (subJson["_source"]["field_prjt_address"].arrayValue.first?.stringValue)!
                                projects.append(project)
                            }
                            print("Project count: \(projects.count) and data are \(projects)")
                            callback(totalRecords, projects, -1)
                        }catch _ as NSError {
                            // error
                        }
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(String(describing: status))")
                    callback(nil, nil, status)
                }
        }
        
    }
    
    
}
