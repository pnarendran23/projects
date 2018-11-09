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
//    let projectURL = "https://elastic:dhLMyQUY4ZnDXVl3qIBDGS4P@b4eac287a05e468b934969945bb6b223.us-east-1.aws.found.io:9243/projects/_search"
    
    
    let projectURL = "https://elastic:7v6ttDeE48G7C4GVM3ERMhzF@616da458449344e6ae5e4bc6d69c267c.us-east-1.aws.found.io:9243/projects/_search"
    
    
    //let projectURL = "https://elastic:dhLMyQUY4ZnDXVl3qIBDGS4P@b4eac287a05e468b934969945bb6b223.us-east-1.aws.found.io:9243/projects/_search"
    
    let projectDetailsURL = "https://elastic:7v6ttDeE48G7C4GVM3ERMhzF@616da458449344e6ae5e4bc6d69c267c.us-east-1.aws.found.io:9243/projects"
    
    
    
    
    //"https://elastic:dhLMyQUY4ZnDXVl3qIBDGS4P@b4eac287a05e468b934969945bb6b223.us-east-1.aws.found.io:9243/projects"
    let baseUSGBCURL: String = "https://www.usgbc.org/mobile/services"
    
    
    var a : DataRequest!
    static let shared = Apimanager()
    let partneralias = "usgbcmobile"
    let partnerpwd = "usgbcmobilepwd"
    
    
    func getProjectobjects(field_name : String, callback: @escaping (NSMutableArray?, Int?) -> ()){
        var params: [String: Any] = [:]
        var arr = NSMutableArray()
        params = ["size": 0,"aggs": ["item": ["terms": ["field": field_name, "size":"5000"]]]
        ]
        var header = ["Content-Type" : "application/json", "partneralias" : partneralias, "partnerpwd" : partnerpwd]
        var url = projectURL
        print(params)
        a = Alamofire.request(url, method: .post, parameters: params, encoding : JSONEncoding.default)
            .validate()
            .responseJSON { response in
                //print(response.request!)
                switch response.result {
                case .success( _):
                    if let jsonString = response.data {
                        var people: [Project] = []
                        var json = JSON()
                        do{
                            json = try JSON(data: jsonString)
                        }catch let error as NSError{
                            
                        }
                        do {
                            let JSON = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0)))
                            guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                                return
                            }
                            arr = (((JSONDictionary["aggregations"] as! NSDictionary)["item"] as! NSDictionary)["buckets"] as! NSArray).mutableCopy() as! NSMutableArray
                            print(JSONDictionary)
                            callback(arr,-1)
                        }catch let JSONError as NSError {
                            print("\(JSONError)")
                            let status = response.response?.statusCode
                            print("STATUS \(status)")
                            callback(nil, status)
                        }
                        
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, status)
                }
        }
    }
    
    
    func getProjectsElasticWithpaginationNew(from: Int, sizee: Int, search: String, category: String, callback: @escaping (Int?, [Project]?, Int?) -> () ){
        // Old API var url = "https://elastic:ZxudNW0EKNpRQc8R6mzJLVhU@85d90afabe7d3656b8dd49a12be4b34e.us-east-1.aws.found.io:9243/elasticsearch_index_pantheon_mob/_search"
        var url = projectURL
        url = projectURL
        let searchText = "\(search)"
        if(!search.isEmpty){
            url = elasticbaseURL + "?q=*\(Payloads().converttoEncoded(parameter: searchText))*"
            url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        print(url)
        var params: [String: Any] = [:]
        params = [ "size": maximum, "from":from]
        if(category == "All"){
            
        }else{
            let cat = "\(category)"
            url = projectURL + "?q=\(cat)"
            if(!search.isEmpty){
                url = projectURL + "?q=*\(Payloads().converttoEncoded(parameter: searchText))* AND %28field_prjt_rating_system_version:%28\(cat)%29%29"
            }
            url = url.replacingOccurrences(of: "%25", with: "")
            url = url.replacingOccurrences(of: " ", with: "%20")
            //url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            //params = [ "size": sizee]
        }
        if(category.count == 0 && search.count == 0){
            url = projectURL + "projects_ios/_search"
            url = projectURL
        }else if(category.count == 0 && search.count > 0){
            url = projectURL + "?q=*\(Payloads().converttoEncoded(parameter: searchText))*"
        }else if(category.count > 0 && search.count > 0){
            if(category == "All"){
                url = projectURL + "?q=*\(Payloads().converttoEncoded(parameter: searchText))*"
            }else{
                let cat = "\(category)"
                url = projectURL + "?q=*\(Payloads().converttoEncoded(parameter: searchText))*%20AND%20%28field_prjt_rating_system_version:%28\(cat)%29%29"
            }
        }else if(category.count > 0 && search.count == 0 && category != "All"){
            let cat = "\(category)"
            url = projectURL + "?q=%28field_prjt_rating_system_version:%28\(cat)%29%29"
        }
        url = url.replacingOccurrences(of: "%25", with: "")
        url = url.replacingOccurrences(of: " ", with: "%20")
        url = url.replacingOccurrences(of: "+", with: "%2B")
        print(url)
        //        if let theJSONData = try?  JSONSerialization.data(
        //            withJSONObject: params,
        //            options: .prettyPrinted
        //            ),
        //            let theJSONText = String(data: theJSONData,
        //                                     encoding: String.Encoding.ascii) {
        //            print("JSON string = \n\(theJSONText)")
        //        }
        a = Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                print(response.request ?? "Error in request")
                switch response.result {
                case .success( _):
                    if let jsonString = response.data {
                        var projects = [Project]()
                        var json = JSON()
                        do{
                            json = try JSON(data: jsonString)
                        }catch let error as NSError{
                            
                        }
                        let totalRecords = json["hits"]["total"].intValue
                        for (_,subJson):(String, JSON) in json["hits"]["hits"] {
                            let project = Project()
                            print(subJson["_source"]["title"].stringValue)
                            project.title = subJson["_source"]["title"].stringValue
                            project.ID = subJson["_source"]["prjt_id"].stringValue
                            project.certification_level = subJson["_source"]["certification_level"].stringValue
                            
                            project.lat = subJson["_source"]["geo_code"]["lat"].stringValue
                            project.long = subJson["_source"]["geo_code"]["lon"].stringValue
                            
                            project.image = subJson["_source"]["profile_image"].stringValue
                            
                            project.rating_system_version = subJson["_source"]["rating_system"].stringValue
//                            printsubJson["_source"]["node_id"].string
                            project.address = subJson["_source"]["address"].stringValue
                            project.address = project.address.replacingOccurrences(of: "amp;", with: "&")
                            project.address = project.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                            project.node_id = subJson["_source"]["node_id"].stringValue
                            project.state = subJson["_source"]["add_state"].stringValue
                            project.country = subJson["_source"]["add_country"].stringValue
                            project.title = project.title.replacingOccurrences(of: "&amp;", with: "")
                            project.country = project.country.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                            project.state = project.state.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                            projects.append(project)
                        }
                        print("Project count: \(projects.count)")
                        callback(totalRecords, projects, -1)
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, nil ,status)
                }
        }
        
    }
    
    func getProjectScorecard(id:String, callback: @escaping ([Scorecard]?, Int?) -> ()){
        let url = "\(baseUSGBCURL)/scorecard"
        let parameters = ["project_id" : id]
        print(parameters)
        a = Alamofire.request(url, method: .get, parameters: parameters)
            .validate()
            .responseJSON { response in
                //print(response.request!)
                switch response.result {
                case .success( _):
                    if let jsonString = response.data {
                        var scoreCards: [Scorecard] = []
                        var json = JSON()
                        do{
                            json = try JSON(data: jsonString)
                        }catch let error as NSError{
                            
                        }
                        let type = json["status"].stringValue
                        if(type == "Error"){
                            let status = response.response?.statusCode
                            print("STATUS \(status)")
                            print(json)
                            callback(nil, status)
                        }else{
                            for (_,subJson):(String, JSON) in json {
                                let scoreCard = Scorecard(json: subJson)
                                print(scoreCard.name)
                                scoreCards.append(scoreCard)
                            }
                            //print(scoreCards)
                            callback(scoreCards, -1)
                        }
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, status)
                }
        }
    }
    
    func getProjectDetails(id:String, callback: @escaping (ProjectDetails?, Int?) -> ()){
        var url = "\(baseUSGBCURL)/projectdetails/\(id)"
        url = "\(projectDetailsURL)/projects/\(id)"
        print(url)
        a = Alamofire.request(url, method: .get)
            .validate()
            .responseJSON { response in
                //print(response.request!)
                switch response.result {
                case .success( _):
                    if let jsonString = response.data {
                        var projectDetails: ProjectDetails!
                        var json = JSON()
                        do{
                            json = try JSON(data: jsonString)
                        }catch let error as NSError{
                            
                        }
                        for (_,subJson):(String, JSON) in json {
                            for (_,innerJson):(String, JSON) in subJson {
                                print(subJson)
                                projectDetails = ProjectDetails()
                                projectDetails.title = subJson["title"].stringValue
                                projectDetails.zip_code = subJson["add_postal_code"].stringValue
                                projectDetails.project_id = subJson["prjt_id"].stringValue
                                projectDetails.project_certification_level = subJson["certification_level"].stringValue
                                
                                projectDetails.lat = subJson["geo_code"]["lat"].stringValue
                                projectDetails.long = subJson["geo_code"]["lon"].stringValue
                                
                                //projectDetails.p = subJson["profile_image"].stringValue
                                projectDetails.project_rating_system_version = subJson["rating_system_version"].stringValue
                                projectDetails.project_rating_system = subJson["rating_system"].stringValue
                                //                            printsubJson["node_id"].string
                                projectDetails.story = subJson["hide_story"].stringValue
                                projectDetails.project_type = subJson["prjt_type"].stringValue
                                projectDetails.project_size = subJson["site_size"].stringValue
                                projectDetails.project_setting = subJson["setting"].stringValue
                                projectDetails.certification_date = subJson["certification_date"].stringValue
                                projectDetails.registration_date = subJson["registration_date"].stringValue
                                projectDetails.project_walkscore = subJson["walkscore"].stringValue
                                projectDetails.energy_star_score = subJson["energy_star_score"].stringValue
                                projectDetails.site_context = subJson["foundation_statement"].stringValue
                                projectDetails.description_full = subJson["description"].stringValue
                                
                                if(subJson["geo_full_address"].stringValue == ""){
                                projectDetails.address = subJson["add_street"].stringValue
                                }else{
                                projectDetails.address = subJson["geo_full_address"].stringValue
                                }
                                
                                projectDetails.state = subJson["add_state"].stringValue
                                projectDetails.image = subJson["profile_image"].stringValue
                                projectDetails.path = subJson["url"].stringValue
                                print(projectDetails.image)
                                
                                projectDetails.city = subJson["add_city"].stringValue
                                projectDetails.country = subJson["add_country"].stringValue
                                
                                if(subJson["geo_street_name"].stringValue != ""){
                                    projectDetails.address = subJson["geo_street_name"].stringValue
                                }else{
                                    projectDetails.address = subJson["add_street"].stringValue
                                }
                                projectDetails.address = projectDetails.address.replacingOccurrences(of: "amp;", with: "&")
                                let a = projectDetails.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                
                                projectDetails.title = projectDetails.title.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                
                                projectDetails.title = projectDetails.title.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                
                                
                                projectDetails.address = a
                                
                                if(subJson["geo_state_name"].stringValue != ""){
                                    projectDetails.state = subJson["geo_state_name"].stringValue
                                }else{
                                    projectDetails.state = subJson["add_state"].stringValue
                                }
                                if(subJson["geo_country_name"].stringValue != ""){
                                    projectDetails.country = subJson["geo_country_name"].stringValue
                                }else{
                                    projectDetails.country = subJson["add_country"].stringValue
                                }
                                projectDetails.country = projectDetails.country.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                projectDetails.state = projectDetails.state.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                
                                projectDetails.title = projectDetails.title.replacingOccurrences(of: "&amp;", with: "")
//                                projectDetails.address = projectDetails.address.components(separatedBy: "[").first!
//                                projectDetails.country = projectDetails.country.components(separatedBy: "[").first!
//                                projectDetails.state = projectDetails.state.components(separatedBy: "[").first!
                                projectDetails.project_images = [String]()
                                for s in subJson["slideshow_images"].arrayValue{
                                    if let category = s.stringValue as? String {
                                        if(category.count > 0){
                                            print("zxcv ", category)
                                            projectDetails.project_images.append(s.stringValue)
                                        }
                                    }
                                }

                                break
                            }
                        }
                        callback(projectDetails, -1)
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, status)
                }
        }
    }
    
    
    func getProjectsNew(category: String, search: String, page: Int, callback: @escaping ([Project]?, Int?) -> ()){
        var parameters = ["from": "\(page)"]
        if(search != ""){
            parameters["search"] = search
        }
        let headers = ["Cache-Control" : "public, max-age=86400, max-stale=120"]
        a = Alamofire.request("\(baseUSGBCURL)/projectslist/\(category)", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
        let cachedResponse = URLCache.shared.cachedResponse(for: a.request!)
        if(cachedResponse == nil){
            print("cachedResponse nil")
            //response not found in cache and internet connection available
            a.validate()
                .responseJSON{ response in
                    //print(response.request!)
                    switch response.result {
                    case .success( _):
                        if let jsonString = response.data {
                            let cachedURLResponse = CachedURLResponse(response: response.response!, data: jsonString , userInfo: nil, storagePolicy: .allowed)
                            URLCache.shared.storeCachedResponse(cachedURLResponse, for: response.request!)
                            var projects: [Project] = []
                            var json = JSON()
                            do{
                                json = try JSON(data: jsonString)
                            }catch let error as NSError{
                                
                            }
                            for (_,subJson):(String, JSON) in json {
                                for (_,innerJson):(String, JSON) in subJson {
                                    let project = Project(json: innerJson["project"])
                                    projects.append(project)
                                }
                            }
                            print(projects.count)
                            callback(projects, -1)
                        }
                    case .failure(let error):
                        print("message: Error 4xx / 5xx: \(error)")
                        let status = response.response?.statusCode
                        print("STATUS \(status)")
                        callback(nil, status)
                    }
            }
        }else{
            print("cachedResponse not nil")
            var projects: [Project] = []
            var json = JSON()
            do{
                json = try JSON(data: cachedResponse!.data)
            }catch let error as NSError{
                
            }
            for (_,subJson):(String, JSON) in json {
                for (_,innerJson):(String, JSON) in subJson {
                    let project = Project(json: innerJson["project"])
                    projects.append(project)
                }
            }
            callback(projects, -1)
        }
    }
    
    func stopAllSessions() {
        if(self.a != nil){
            self.a.cancel()
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        }
    }
    
    func authenticateUser(userName: String, password: String, callback: @escaping (String?, Int?) -> ()){
        let params = ["partneralias": partneralias, "partnerpwd": partnerpwd, "email": userName, "pwd": password]
        print(params)
        a = Alamofire.request("https://dev.usgbc.org/api/v1/authenticate.json", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                //print(response.request!)
                switch response.result {
                case .success( _):
                    do{
                        if let jsonString = response.data {
                            print(jsonString)
                            let json = try JSON(data: jsonString)
                            let type = json["result"]["type"].stringValue
                            if(type == "S"){
                                callback(json["token"].stringValue, -1)
                            }else{
                                let status = response.response?.statusCode
                                print("STATUS \(status)")
                                callback(nil, status)
                            }
                        }
                    }catch let error as NSError{
                        
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, status)
                }
        }
    }
    
    func logoutUser(email: String, callback: @escaping (String?, Int?) -> ()){
        let params = ["partneralias": partneralias, "partnerpwd": partnerpwd, "email": email]
        print(params)
        a = Alamofire.request("\(baseUSGBCURL)/user_logout", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                //print(response.request!)
                switch response.result {
                case .success( _):
                    if let jsonString = response.data {
                        print(jsonString)
                        do{
                            let json = try JSON(data: jsonString)
                            let type = json["type"].stringValue
                            if(type == "S"){
                                callback(json["message"].stringValue, -1)
                            }else{
                                let status = response.response?.statusCode
                                print("STATUS \(status)")
                                callback(nil, status)
                            }
                        }catch let error as NSError{
                            
                        }
                    }
                    
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, status)
                }
        }
    }
    
    func getProjectsElasticForMap(from: Int, sizee: Int, search: String, category: String, callback: @escaping (Int?, [Project]?, Int?) -> () ){
        var url = elasticbaseURL + "projects_ios/_search"
        let searchText = search
        if(!search.isEmpty){
            url = elasticbaseURL + "projects_ios/_search?q=*\(Payloads().converttoEncoded(parameter: searchText))*"
            url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        print(url)
        var params: [String: Any] = [:]
        params = [ "size": sizee, "from":from]
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
                                project.node_id = (subJson["_source"]["node_id"].arrayValue.first?.stringValue ?? "")
                                project.address = (subJson["_source"]["field_prjt_address"].arrayValue.first?.stringValue)!
                                project.address = project.address.replacingOccurrences(of: "amp;", with: "&")
                                let a = project.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                project.title = project.title.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                project.address = a
                                project.title = project.title.replacingOccurrences(of: "&amp;", with: "")
                                projects.append(project)
                            }
                            print("Project count: \(projects.count) and data are \(projects)")
                            callback(totalRecords, projects, -1)
                        }catch let error as NSError {
                            // error
                        }
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, nil, status)
                }
        }
        
    }
    
    
    
    func getProjectsCount(category: [[String : Any]], callback: @escaping (Int?, Int?) -> () ){
        //var url = "https://elastic:ZxudNW0EKNpRQc8R6mzJLVhU@85d90afabe7d3656b8dd49a12be4b34e.us-east-1.aws.found.io:9243/elasticsearch_index_pantheon_mob/_search"
        var params: [String: Any] = [:]
        var url = projectURL + "?size=500000"
        var header = [String : Any]()
        var matchTitle = [String : Any]()
        
        header = [
            "_source": ["title","certification_level","geo_code", "add_country", "add_state","rating_system_version","rating_system","add_city","node_id", "add_street","profile_image","prjt_id"],
        ]
        header["query"] = [String : Any]()
        var query = header["query"] as! [String : Any]
        query["bool"] = [String : Any]()
        var bool = query["bool"] as! [String : Any]
        /*bool["must_not"] = [
            "geo_distance" : [
                "distance" : "1m",
                "geo_code" : [
                    "lat" : 0,
                    "lon" : 0
                ]]
        ]*/
        if(category.count > 0){
                bool["must"] = category
        }
        query["bool"] = bool
        header["query"] = query
        
        print(header)
        
        
        url = projectURL
        a = Alamofire.request(url, method: .post, parameters: header, encoding : JSONEncoding.default)
            .validate()
            .responseJSON { response in
                print(response.request ?? "Error in request")
                switch response.result {
                case .success( _):
                    if let jsonString = response.data {
                        var  json = JSON()
                        do{
                            json = try JSON(data: jsonString)
                        }catch let error as NSError{
                            
                        }
                        let totalRecords = json["hits"]["total"].intValue
                        callback(totalRecords, -1)
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, status)
                }
        }
        
    }
    
    func updateFCMDevice(params: [String: Any], callback: @escaping (String?, Int?) -> ()){
        a = Alamofire.request("\(baseUSGBCURL)/updatedeviceregister", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                //print(response.request!)
                switch response.result {
                case .success( _):
                    do{
                        if let jsonString = response.data {
                            let json = try JSON(data: jsonString)
                            print(json)
                            let type = json["result"]["type"].stringValue
                            if(type == "S"){
                                callback(json["result"]["message"].stringValue, -1)
                            }else{
                                let status = response.response?.statusCode
                                print("STATUS \(status)")
                                callback(nil, status)
                            }
                        }
                    }catch let error as NSError{
                        
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, status)
                }
        }
    }
    
    
    
    func getProjectsElasticForMapNew(from: Int, sizee: Int, search: String, category: [[String : Any]], lat : Double, lng : Double, distance : Double, callback: @escaping (Int?, [Project]?, Int?) -> () ){
        var cat = category
        var url = projectURL + "?size=500000"
        let searchText = search
        var header = [String : Any]()
        var matchTitle = [String : Any]()
        if(search.count > 0){
            matchTitle = ["bool": [
                "should": [
                    ["multi_match": [
                        "query": "\(search)",
                        "fields": ["title.raw^3","certification_level.raw","rating_system.raw","rating_system_version.raw","add_city.raw","add_country.raw^2","add_state.raw^2","add_street.raw^2","add_postal_code.raw","prjt_id.raw","geo_street_name.raw^2","geo_city_name.raw^2","geo_state_name.raw^2","geo_state_abbrv.raw^2","geo_country_name.raw^2","geo_country_abbrv.raw^2","geo_postal_code.raw","geo_full_address.raw^2","title^3","certification_level","rating_system","rating_system_version","add_city^2","add_country^2","add_state^2","add_street^2","add_postal_code","prjt_id","geo_street_name^2","geo_city_name^2","geo_state_name^2","geo_state_abbrv^2","geo_country_name^2","geo_country_abbrv^2","geo_postal_code","geo_full_address^2"
                        ],
                        "type": "cross_fields","operator": "and"]
                    ], ["multi_match": [
                        "query": "\(search)",
                        "fields":[
                            "title.raw^3","certification_level.raw","rating_system.raw","rating_system_version.raw","add_city.raw^2","add_country.raw^2","add_state.raw^2","add_street.raw^2","add_postal_code.raw","prjt_id.raw","geo_street_name.raw^2","geo_city_name.raw^2","geo_state_name.raw^2","geo_state_abbrv.raw^2","geo_country_name.raw^2","geo_country_abbrv.raw^2","geo_postal_code.raw","geo_full_address.raw^2","title^3","certification_level","rating_system","rating_system_version","add_city^2","add_country^2","add_state^2","add_street^2","add_postal_code","prjt_id","geo_street_name^2","geo_city_name^2","geo_state_name^2","geo_state_abbrv^2","geo_country_name^2","geo_country_abbrv^2","geo_postal_code","geo_full_address^2"
                        ],
                        "type": "phrase_prefix","operator": "and"]
                    ]
                ],"minimum_should_match": "1"]]
        }
        header = [
            "_source": ["title","certification_level","geo_code", "add_country", "add_state","rating_system_version","rating_system","add_city","node_id", "add_street","profile_image","prjt_id","geo_street_name","geo_city_name","geo_state_name","geo_country_name", "certification_date","certification_level","registration_date"],
            "query": [
                "bool" : [
                    "must_not":[
                        "geo_distance" : [
                            "distance" : "1m",
                            "geo_code" : [
                                "lat" : 0,
                                "lon" : 0
                            ]]
                        ],
                    "filter" : [
                        "geo_distance" : [
                            "distance" : "\(Double(distance))mi",
                            "geo_code" : [
                                "lat" : Double(lat),
                                "lon" : Double(lng)
                            ]
                        ]
                    ]
                ]
            ],
                "sort" : [
                    [
                        "_geo_distance" : [
                            "geo_code" : [Double(lng),Double(lat)],
                            "order" : "asc",
                            "unit" : "mi",
                            "mode" : "min",
                            "distance_type" : "plane",
                            "ignore_unmapped": true
                        ]
                    ]
                ]
            ]
        if(search.count > 0 || cat.count > 0){
            var query = header["query"] as! [String : Any]
            var bool = query["bool"] as! [String : Any]
            if(search.count > 0){
                cat.append(matchTitle)
            }
            if(cat.count > 0){
                bool["must"] = cat
            }
            query["bool"] = bool
            header["query"] = query
            
        }

        print(header)
        
    
        url = projectURL + "?from=\(from)&size=\(sizee)"
        
        print(url)
            a = Alamofire.request(url, method: .post, parameters: header, encoding : JSONEncoding.default)
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
                                var lat = subJson["_source"]["geo_code"]["lat"].stringValue
                                var lng = subJson["_source"]["geo_code"]["lon"].stringValue
                                if(lat != " " && lng != " " && lat != "0" && lng != "0"){
                                //print(subJson)
                                    project.title = subJson["_source"]["title"].stringValue
                                    project.ID = subJson["_source"]["prjt_id"].stringValue
                                    project.certification_level = subJson["_source"]["certification_level"].stringValue
                                    //
                                    project.lat = subJson["_source"]["geo_code"]["lat"].stringValue
                                    project.long = subJson["_source"]["geo_code"]["lon"].stringValue
                                    //
                                    //                                    project.image = subJson["_source"]["profile_image"].stringValue
                                    //
                                    project.rating_system_version = subJson["_source"]["rating_system_version"].stringValue
                                    project.rating_system = subJson["_source"]["rating_system"].stringValue
                                    //                                    //                            printsubJson["_source"]["node_id"].string
                                    project.city = subJson["_source"]["geo_city_name"].stringValue
                                    project.image = subJson["_source"]["profile_image"].stringValue
                                    project.certification_date = subJson["_source"]["certification_date"].stringValue
                                    project.registration_date = subJson["_source"]["registration_date"].stringValue
                                    project.certification_level = subJson["_source"]["certification_level"].stringValue
                                    //["title","certification_level","geo_code", "add_country", "add_state","rating_system_version","rating_system","add_city","node_id", "add_street","profile_image","prjt_id","geo_street_name","geo_city_name","geo_state_name","geo_country_name"]
                                    if(subJson["_source"]["geo_street_name"].stringValue != ""){
                                        project.address = subJson["_source"]["geo_street_name"].stringValue
                                    }else{
                                        project.address = subJson["_source"]["add_street"].stringValue
                                    }
                                    project.address = project.address.replacingOccurrences(of: "amp;", with: "&")
                                    let a = project.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                    project.address = a
                                    project.node_id = subJson["_source"]["node_id"].stringValue
                                    if(subJson["_source"]["geo_state_name"].stringValue != ""){
                                        project.state = subJson["_source"]["geo_state_name"].stringValue
                                    }else{
                                        project.state = subJson["_source"]["add_state"].stringValue
                                    }
                                    if(subJson["_source"]["geo_country_name"].stringValue != ""){
                                        project.country = subJson["_source"]["geo_country_name"].stringValue
                                    }else{
                                        project.country = subJson["_source"]["add_country"].stringValue
                                    }
                                    project.title = project.title.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                    project.address = project.address.components(separatedBy: "[").first!
                                    project.address = project.address.replacingOccurrences(of: "amp;", with: "&")
                                    project.address = project.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                    project.country = project.country.components(separatedBy: "[").first!
                                    project.title = project.title.replacingOccurrences(of: "&amp;", with: "")
                                    project.state = project.state.components(separatedBy: "[").first!
                                projects.append(project)
                                }
                            }
                            //print("Project count: \(projects.count) and data are \(projects)")
                            callback(totalRecords, projects, -1)
                        }catch let error as NSError {
                            // error
                        }
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error.localizedDescription)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, nil, status)
                }
        }
        
    }
    
    
    
    func searchProjectsElasticForMapNew(from: Int, sizee: Int, search: String, category: [[String : Any]], callback: @escaping (Int?, [Project]?, Int?) -> () ){
        var cat = category
        var url = projectURL + "?size=500000"
        let searchText = search
        var header = [String : Any]()
        var matchTitle = [String : Any]()
        if(search.count > 0){
            
            
            matchTitle = ["bool": [
                "should": [
                    ["multi_match": [
                        "query": "\(search)",
                        "fields": ["title.raw^3","certification_level.raw","rating_system.raw","rating_system_version.raw","add_city.raw","add_country.raw^2","add_state.raw^2","add_street.raw^2","add_postal_code.raw","prjt_id.raw","geo_street_name.raw^2","geo_city_name.raw^2","geo_state_name.raw^2","geo_state_abbrv.raw^2","geo_country_name.raw^2","geo_country_abbrv.raw^2","geo_postal_code.raw","geo_full_address.raw^2","title^3","certification_level","rating_system","rating_system_version","add_city^2","add_country^2","add_state^2","add_street^2","add_postal_code","prjt_id","geo_street_name^2","geo_city_name^2","geo_state_name^2","geo_state_abbrv^2","geo_country_name^2","geo_country_abbrv^2","geo_postal_code","geo_full_address^2"
                        ],
                        "type": "cross_fields","operator": "and"]
                    ], ["multi_match": [
                        "query": "\(search)",
                        "fields":[
                            "title.raw^3","certification_level.raw","rating_system.raw","rating_system_version.raw","add_city.raw^2","add_country.raw^2","add_state.raw^2","add_street.raw^2","add_postal_code.raw","prjt_id.raw","geo_street_name.raw^2","geo_city_name.raw^2","geo_state_name.raw^2","geo_state_abbrv.raw^2","geo_country_name.raw^2","geo_country_abbrv.raw^2","geo_postal_code.raw","geo_full_address.raw^2","title^3","certification_level","rating_system","rating_system_version","add_city^2","add_country^2","add_state^2","add_street^2","add_postal_code","prjt_id","geo_street_name^2","geo_city_name^2","geo_state_name^2","geo_state_abbrv^2","geo_country_name^2","geo_country_abbrv^2","geo_postal_code","geo_full_address^2"
                        ],
                        "type": "phrase_prefix","operator": "and"]
                    ]
                ],"minimum_should_match": "1"]]
        }
        header = [
            "_source": ["title","certification_level","geo_code", "add_country", "add_state","rating_system_version","rating_system","add_city","node_id", "add_street","profile_image","prjt_id","geo_street_name","geo_city_name","geo_state_name","geo_country_name", "certification_date","certification_level","registration_date"],
        ]
        header["query"] = [String : Any]()
        var query = header["query"] as! [String : Any]
        query["bool"] = [String : Any]()
        var bool = query["bool"] as! [String : Any]
//        bool["must_not"] = [
//            "geo_distance" : [
//                "distance" : "1m",
//                "geo_code" : [
//                    "lat" : 0,
//                    "lon" : 0
//                ]]]
        if(search.count > 0 || cat.count > 0){
            bool = query["bool"] as! [String : Any]
            if(search.count > 0){
                cat.append(matchTitle)
            }
            if(cat.count > 0){
                bool["must"] = cat
                
            }
            
        }
        query["bool"] = bool
        header["query"] = query
        
        print(header)
        
        
        url = projectURL + "?from=\(from)&size=\(sizee)"
        
        print(url)
        a = Alamofire.request(url, method: .post, parameters: header, encoding : JSONEncoding.default)
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
                                var lat = subJson["_source"]["geo_code"]["lat"].stringValue
                                var lng = subJson["_source"]["geo_code"]["lon"].stringValue
                                if(lat != " " && lng != " " && lat != "0" && lng != "0"){
                                    
                                }
                                    //print(subJson)
                                    project.title = subJson["_source"]["title"].stringValue
                                    project.ID = subJson["_source"]["prjt_id"].stringValue
                                    project.certification_level = subJson["_source"]["certification_level"].stringValue
                                    //
                                    project.lat = subJson["_source"]["geo_code"]["lat"].stringValue
                                    project.long = subJson["_source"]["geo_code"]["lon"].stringValue
                                    project.certification_date = subJson["_source"]["certification_date"].stringValue
                                project.registration_date = subJson["_source"]["registration_date"].stringValue
                                
                                    project.certification_level = subJson["_source"]["certification_level"].stringValue
                                    //                                    project.image = subJson["_source"]["profile_image"].stringValue
                                    //
                                    project.rating_system_version = subJson["_source"]["rating_system_version"].stringValue
                                    project.rating_system = subJson["_source"]["rating_system"].stringValue
                                    //                                    //                            printsubJson["_source"]["node_id"].string
                                    
                                    project.image = subJson["_source"]["profile_image"].stringValue
                                
                                    project.node_id = subJson["_source"]["node_id"].stringValue
                                    project.city = subJson["_source"]["geo_city_name"].stringValue
                                if(subJson["_source"]["geo_street_name"].stringValue != ""){
                                    project.address = subJson["_source"]["geo_street_name"].stringValue
                                }else{
                                    project.address = subJson["_source"]["add_street"].stringValue
                                }
                                project.address = project.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                project.node_id = subJson["_source"]["node_id"].stringValue
                                if(subJson["_source"]["geo_state_name"].stringValue != ""){
                                    project.state = subJson["_source"]["geo_state_name"].stringValue
                                }else{
                                    project.state = subJson["_source"]["add_state"].stringValue
                                }
                                if(subJson["_source"]["geo_country_name"].stringValue != ""){
                                    project.country = subJson["_source"]["geo_country_name"].stringValue
                                }else{
                                    project.country = subJson["_source"]["add_country"].stringValue
                                }
                                    project.title = project.title.replacingOccurrences(of: "&amp;", with: "")
                                project.title = project.title.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                    project.address = project.address.components(separatedBy: "[").first!
                                project.address = project.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                    project.country = project.country.components(separatedBy: "[").first!
                                    project.state = project.state.components(separatedBy: "[").first!
                                
                                project.country = project.country.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                project.state = project.state.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                
                                    projects.append(project)
                            }
                            //print("Project count: \(projects.count) and data are \(projects)")
                            callback(totalRecords, projects, -1)
                        }catch let error as NSError {
                            // error
                        }
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error.localizedDescription)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, nil, status)
                }
        }
        
    }
    
    
    func getProjectsElasticForMapNewOnce(from: Int, sizee: Int, search: String, category: String, lat : Double, lng : Double, distance : Double, callback: @escaping (Int?, [Project]?, Int?) -> () ){
        var url = projectURL + "?from=\(from)&size=\(sizee)"
        let searchText = search
        var header = [String : Any]()
        header = ["_source": ["title","country","certification_level","geo_code","address","node_id","state","city"]]
        print(url)
        //a = Alamofire.request(url, method: method!, parameters: header, encoding : JSONEncoding.default)
        url = projectURL + "?from=\(from)&size=\(sizee)"
        a = Alamofire.request(url, method: .post, parameters: header, encoding : JSONEncoding.default)
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
                                
                                    //print(subJson)
                                    project.title = subJson["_source"]["title"].stringValue
//                                    project.ID = subJson["_source"]["prjt_id"].stringValue
                                    project.certification_level = subJson["_source"]["certification_level"].stringValue
                                project.registration_date = subJson["_source"]["registration_date"].stringValue
//
                                    project.lat = subJson["_source"]["geo_code"]["lat"].stringValue
                                    project.long = subJson["_source"]["geo_code"]["lon"].stringValue
//
//                                    project.image = subJson["_source"]["profile_image"].stringValue
//
//                                    project.rating_system_version = subJson["_source"]["rating_system"].stringValue
//                                    //                            printsubJson["_source"]["node_id"].string
                                    project.address = subJson["_source"]["address"].stringValue
                                project.address = project.address.replacingOccurrences(of: "amp;", with: "&")
                                project.address = project.address.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                    project.node_id = subJson["_source"]["node_id"].stringValue
                                    project.state = subJson["_source"]["add_state"].stringValue
                                    project.country = subJson["_source"]["add_country"].stringValue
                                    project.title = project.title.replacingOccurrences(of: "&amp;", with: "")
                                project.country = project.country.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                project.state = project.state.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                                    projects.append(project)                                
                            }
                            //print("Project count: \(projects.count) and data are \(projects)")
                            callback(totalRecords, projects, -1)
                        }catch let error as NSError {
                            // error
                        }
                    }
                case .failure(let error):
                    print("message: Error 4xx / 5xx: \(error.localizedDescription)")
                    let status = response.response?.statusCode
                    print("STATUS \(status)")
                    callback(nil, nil, status)
                }
        }
        
    }
    
    
   }
