//
//  Payloads.swift
//  USGBC
//
//  Created by Group X on 18/01/18.
//  Copyright © 2018 Group10 Technologies. All rights reserved.
//

import UIKit
import Foundation

class Payloads {
    func makePayloadForResources(typearray : [String], formatarray : [String], ratingarray :[String], versionarray : [String], accessarray : [String], languagearray : [String], categoriesarray : [String]) -> String{
        var size = 0
        var typestring = String()
        var formatstring = String()
        var accessstring = String()
        var versionstring = String()
        var languagestring = String()
        var ratingstring = String()
        var category_string = String()
        
        var temp = typearray
        for str in temp{
            if(str != ""){
                if(typestring.count > 0){
                    typestring = typestring + "%20OR%20%22" + str + "%22"
                }else{
                    typestring = "%28field_res_type:%28%22" + str + "%22"
                }
            }
        }
        
        if(typestring.count > 0){
            typestring = typestring + "%29%29"
        }
        
        for str in formatarray{
            if(str != ""){
                if(formatstring.count > 0){
                    formatstring = formatstring + "%20OR%20" + str
                }else{
                    if(typestring.count == 0){
                        formatstring = "%28field_format:%28%22" + str + "%22"
                    }else{
                        formatstring = "%20AND%20%28field_format:%28%22" + str + "%22"
                    }
                }
            }
        }
        
        if(formatstring.count > 0){
            formatstring = formatstring + "%29%29"
        }
        
        for str in ratingarray{
            if(str != ""){
                var s = str
                var arr = NSArray()
                if(str.contains(":")){
                    arr = str.components(separatedBy: ":") as NSArray
                    s = arr[1] as! String
                    //ratingstring = "%20AND%20field_res_rating:" + arr[1]
                }
                if(ratingstring.count > 0){
                    ratingstring = ratingstring + "%20OR%20%22" + s + "%22"
                }else{
                    if(typestring.count > 0 || formatstring.count > 0){
                        ratingstring = "%20AND%20%28field_res_rating:%28%22" + s + "%22"
                    }else{
                        ratingstring = "%28field_res_rating:%28%22" + s + "%22"
                    }
                }
            }
        }
        
        if(ratingstring.count > 0){
            ratingstring = ratingstring + "%29%29"
        }
        
        for str in accessarray{
            if(str != ""){
                if(accessstring.count > 0){
                    accessstring = accessstring + "%20AND%20%22" + str + "%22"
                }else{
                    if(typestring.count > 0 || formatstring.count > 0 || ratingstring.count > 0){
                        accessstring = "%20AND%20%28field_res_members:%28%22" + str + "%22"
                    }else{
                        accessstring = "%28field_res_members:%28%22" + str + "%22"
                    }
                }
            }
        }
        
        if(accessstring.count > 0){
            accessstring = accessstring + "%29%29"
        }
        
        for str in versionarray{
            if(str != ""){
                if(versionstring.count > 0){
                    versionstring = versionstring + "%20OR%20%22" + str + "%22"
                }else{
                    if(typestring.count > 0 || formatstring.count > 0 || ratingstring.count > 0 || accessstring.count > 0){
                        versionstring = "%20AND%20%28field_res_version:%28%22" + str + "%22"
                    }else{
                        versionstring = "%28field_res_version:%28%22" + str + "%22"
                    }
                }
            }
        }
        
        if(versionstring.count > 0){
            versionstring = versionstring + "%29%29"
        }
        
        for str in languagearray{
            if(str != ""){
                if(languagestring.count > 0){
                    languagestring = languagestring + "%20OR%20%22" + str + "%22"
                }else{
                    if(typestring.count > 0 || formatstring.count > 0 || ratingstring.count > 0 || accessstring.count > 0 || versionstring.count > 0){
                        languagestring = "%20AND%20%28field_res_language:%28%22" + str + "%22"
                    }else{
                        languagestring = "%28field_res_language:%28%22" + str + "%22"
                    }
                }
            }
        }
        if(languagestring.count > 0){
            languagestring = languagestring + "%29%29"
        }
        
        print(typestring+formatstring+ratingstring+accessstring+versionstring+languagestring)
        var parameter = typestring+formatstring+ratingstring+accessstring+versionstring+languagestring
        parameter = parameter.replacingOccurrences(of: " ", with: "%20")
        parameter = parameter.replacingOccurrences(of: "partners", with: "partner")
        return converttoEncoded(parameter: parameter)
    }
    
    
    
    
    
    
    func makePayloadForCourses(formatarr : NSMutableArray, levelarr : NSMutableArray, languagearr : NSMutableArray, posteddatesarray : NSMutableArray) -> String{
        var formatstring = String()
        var levelstring = String()
        var languagestring = String()
        var posteddatestring = String()
    
        for s in formatarr{
            var str = s as! String
            if(str != ""){
            if(formatstring.count > 0){
                str = str.replacingOccurrences(of: ":", with: "%3A")
                formatstring = formatstring + "%20OR%20" + "\"" + str + "\""
            }else{
                    formatstring = "courses_format:" + "\"" + str + "\""
            }
            }
        }
        
        for s in levelarr{
            var str = s as! String
            if(str != ""){
            str = str.replacingOccurrences(of: ":", with: "%3A")
            if(levelstring.count > 0){
                str = str.replacingOccurrences(of: ":", with: "%3A")
                levelstring = levelstring + "%20OR%20" + "\"" + str + "\""
            }else{
                str = str.replacingOccurrences(of: ":", with: "%3A")
                if(formatstring.count > 0){
                    levelstring = "%20AND%20course_level:" + "\"" + str + "\""
                }else{
                    levelstring = "course_level:" + "\"" + str + "\""
                }
            }
            }
        }
        
        for s in languagearr{
            var str = s as! String
            if(str != ""){
            str = str.replacingOccurrences(of: ":", with: "%3A")
            if(languagestring.count > 0){
                languagestring = languagestring + "%20OR%20" + "\"" + str + "\""
            }else{
                if(formatstring.count > 0 || levelstring.count > 0){
                    languagestring = "%20AND%20language:" + "\"" + str + "\""
                }else{
                    languagestring = "language:" + "\"" + str + "\""
                }
            }
            }
        }
        
        if(!posteddatesarray.contains("")){
            for s in posteddatesarray{
                var str = s as! String
                if(str != ""){
                if(str != ""){
                    if(posteddatestring.count > 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        var date = NSDate()
                        var dateformat = DateFormatter()
                        dateformat.dateFormat = "MM/dd/yyyy"
                        date = dateformat.date(from: str) as! NSDate
                        dateformat.dateFormat = "yyyy-MM-dd"
                        str = dateformat.string(from: date as Date)
                        posteddatestring = posteddatestring + "%20TO%20" + str + "]"
                    }else{
                        if(formatstring.count > 0 || levelstring.count > 0 || languagestring.count > 0){
                            var date = NSDate()
                            var dateformat = DateFormatter()
                            dateformat.dateFormat = "MM/dd/yyyy"
                            date = dateformat.date(from: str) as! NSDate
                            dateformat.dateFormat = "yyyy-MM-dd"
                            str = dateformat.string(from: date as Date)
                            str = str.replacingOccurrences(of: ":", with: "%3A")
                            posteddatestring = "%20AND%20courses_published_date:[" + str
                        }else{
                            var date = NSDate()
                            var dateformat = DateFormatter()
                            dateformat.dateFormat = "MM/dd/yyyy"
                            date = dateformat.date(from: str) as! NSDate
                            dateformat.dateFormat = "yyyy-MM-dd"
                            str = dateformat.string(from: date as Date)
                            str = str.replacingOccurrences(of: ":", with: "%3A")
                            posteddatestring = "courses_published_date:[" + str
                        }
                    }
                    }
                }
            }
        }
        
        
        var parameter = formatstring + levelstring + languagestring + posteddatestring
        return converttoEncoded(parameter: parameter)
    }
    
    
    func makePayloadForArticles(channelarray : NSMutableArray, authorarray : NSMutableArray, posteddatearray : NSMutableArray, mediaarray : NSMutableArray) -> String{
        
        var channelstring = String()
        var authorstring = String()
        var posteddatestring = String()
        var media = String()
        
        for s in channelarray{
            var str = s as! String
            if(str != ""){
                if(channelstring.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    channelstring = channelstring + "%20OR%20" + "\"" + str + "\""
                }else{
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    channelstring = "field_p_channel:" + "\"" + str + "\""
                }
            }
        }
        
        for s in mediaarray{
            var str = s as! String
            if(str != ""){
                if(media.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    media = media + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(channelstring.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        media = "media_type:" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        media = "%20AND%20media_type:" + "\"" + str + "\""
                    }
                }
            }
        }
        
        for s in authorarray{
            var str = s as! String
            if(str != ""){
                if(authorstring.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    authorstring = authorstring + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(channelstring.count == 0 && media.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        authorstring = "field_p_author:" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        authorstring = "%20AND%20field_p_author:" + "\"" + str + "\""
                    }
                }
            }
        }
        if(!posteddatearray.contains("")){
            for s in posteddatearray{
                var str = s as! String
                if(str != ""){
                    if(posteddatestring.count > 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        var date = NSDate()
                        var dateformat = DateFormatter()
                        dateformat.dateFormat = "MM/dd/yyyy"
                        date = dateformat.date(from: str) as! NSDate
                        dateformat.dateFormat = "yyyy-MM-dd"
                        str = dateformat.string(from: date as Date)
                        posteddatestring = posteddatestring + "%20TO%20" + str + "]"
                    }else{
                        if(channelstring.count > 0 || authorstring.count > 0 || media.count > 0){
                            var date = NSDate()
                            var dateformat = DateFormatter()
                            dateformat.dateFormat = "MM/dd/yyyy"
                            date = dateformat.date(from: str) as! NSDate
                            dateformat.dateFormat = "yyyy-MM-dd"
                            str = dateformat.string(from: date as Date)
                            str = str.replacingOccurrences(of: ":", with: "%3A")
                            posteddatestring = "%20AND%20field_p_posteddate:[" + str
                        }else{
                            var date = NSDate()
                            var dateformat = DateFormatter()
                            dateformat.dateFormat = "MM/dd/yyyy"
                            date = dateformat.date(from: str) as! NSDate
                            dateformat.dateFormat = "yyyy-MM-dd"
                            str = dateformat.string(from: date as Date)
                            str = str.replacingOccurrences(of: ":", with: "%3A")
                            posteddatestring = "field_p_posteddate:[" + str
                        }
                    }
                }
            }
        }
        
        
        print(channelstring + media + authorstring + posteddatestring )
        var parameter = channelstring + media + authorstring + posteddatestring 
        return converttoEncoded(parameter: parameter)
    }
    
    
    func makePayloadForCredits(categoryarray : NSMutableArray, requiredarray : NSMutableArray, regionalarray : NSMutableArray, versionarray : NSMutableArray, ratingsarray : NSMutableArray) -> String{
        
        var category = String()
        var required = String()
        var regional = String()
        var versions = String()
        var ratings = String()
        
        for s in categoryarray{
            var str = s as! String
            if(str != ""){
                if(category.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    category = category + "%20OR%20" + "\"" + str + "\""
                }else{
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    category = "field_credit_category:" + "\"" + str + "\""
                }
            }
        }
        
        for s in versionarray{
            var str = s as! String
            if(str != ""){
                if(versions.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    versions = versions + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(category.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        versions = "field_credit_version:" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        versions = "%20AND%20field_credit_version:" + "\"" + str + "\""
                    }
                }
            }
        }
        
        for s in requiredarray{
            var str = s as! String
            if(str != ""){
                if(required.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    required = required + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(category.count == 0 && versions.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        required = "field_credit_required:" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        required = "%20AND%20field_credit_required:" + "\"" + str + "\""
                    }
                }
            }
        }
        
        for s in ratingsarray{
            var str = s as! String
            if(str != ""){
                if(ratings.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    ratings = ratings + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(category.count == 0 && versions.count == 0 && required.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        ratings = "field_credit_rating_system:" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        ratings = "%20AND%20field_credit_rating_system:" + "\"" + str + "\""
                    }
                }
            }
        }
        
        var parameter = category + versions + required + ratings
        return converttoEncoded(parameter: parameter)
    }
    
    
    func makePayloadForOrganizations(levelsarray : NSMutableArray, relationshipsarray : NSMutableArray, statesarray : NSMutableArray, countriesarray : NSMutableArray) -> String{
        print(statesarray)
        var levels = String()
        var relationships = String()
        var states = String()
        var countries = String()
        
        
        for s in levelsarray{
            var str = s as! String
            if(str != ""){
                if(levels.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    levels = levels + "%20OR%20" + "\"" + str + "\""
                }else{
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    levels = "%28level:%28" + "\"" + str + "\""
                }
            }
        }
        if(levels.count > 0){
            levels = levels + "%29%29"
        }
        
        for s in relationshipsarray{
            var str = s as! String
            if(str != ""){
                if(relationships.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    relationships = relationships + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(levels.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        relationships = "%28relationship:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        relationships = "%20AND%20%28relationship:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(relationships.count > 0){
            relationships = relationships + "%29%29"
        }
        
        for s in statesarray{
            var str = s as! String
            if(str != ""){
                if(states.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    states = states + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(levels.count == 0 && relationships.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        states = "%28state:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        states = "%20AND%20%28state:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(states.count > 0){
            states = states + "%29%29"
        }
        
        for s in countriesarray{
            var str = s as! String
            if(str != ""){
                if(countries.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    countries = countries + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(levels.count == 0 && relationships.count == 0 && states.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        countries = "%28country:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        countries = "%20AND%20%28country:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(countries.count > 0){
            countries = countries + "%29%29"
        }
        
        var parameter = levels + relationships + states + countries
        return converttoEncoded(parameter: parameter)
    }
    
    
    func makePayloadForPeople(jobtitlesarray : NSMutableArray, orgnamesarray : NSMutableArray, relationshipsarray : NSMutableArray, statesarray : NSMutableArray, countriesarray : NSMutableArray) -> String{
        
        var jobtitles = String()
        var relationships = String()
        var orgnames = String()
        var states = String()
        var countries = String()
        
        for s in jobtitlesarray{
            var str = s as! String
            if(str != ""){
                if(jobtitles.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    jobtitles = jobtitles + "%20OR%20" + "\"" + str + "\""
                }else{
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    jobtitles = "%28job_title:%28" + "\"" + str + "\""
                }
            }
        }
        
        if(jobtitles.count > 0){
            jobtitles = jobtitles + "%29%29"
        }
        
        for s in orgnamesarray{
            var str = s as! String
            if(str != ""){
                if(orgnames.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    orgnames = orgnames + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(jobtitles.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        orgnames = "%28organization_name:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        orgnames = "%20AND%20%28organization_name:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(orgnames.count > 0){
            orgnames = orgnames + "%29%29"
        }
        
        for s in relationshipsarray{
            var str = s as! String
            if(str != ""){
                if(relationships.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    relationships = relationships + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(jobtitles.count == 0 && orgnames.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        relationships = "%28relationship:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        relationships = "%20AND%20%28relationship:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(relationships.count > 0){
            relationships = relationships + "%29%29"
        }
        
        for s in statesarray{
            var str = s as! String
            if(str != ""){
                if(states.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    states = states + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(jobtitles.count == 0 && orgnames.count == 0 && relationships.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        states = "%28state:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        states = "%20AND%20%28state:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(states.count > 0){
            states = states + "%29%29"
        }
        
        for s in countriesarray{
            var str = s as! String
            if(str != ""){
                if(countries.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    countries = countries + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(jobtitles.count == 0 && orgnames.count == 0 && relationships.count == 0 && states.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        countries = "%28country:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        countries = "%20AND%20%28country:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(countries.count > 0){
            countries = countries + "%29%29"
        }
        
        var parameter = jobtitles + orgnames + relationships + states + countries
        return converttoEncoded(parameter: parameter)
    }
    
    func converttoEncoded(parameter : String) -> String{
        var s = parameter
        s = s.replacingOccurrences(of: "\"", with: "%22")
        s = s.replacingOccurrences(of: "+", with: "%2B")
        s = s.replacingOccurrences(of: "[", with: "%5B")
        s = s.replacingOccurrences(of: "]", with: "%5D")
        s = s.replacingOccurrences(of: "-", with: "%2D")
        s = s.replacingOccurrences(of: " ", with: "%20")
        s = s.replacingOccurrences(of: "&", with: "%26")
        s = s.replacingOccurrences(of: " ", with: "%20")
        s = s.replacingOccurrences(of: ":", with: "%3A")
        s = s.replacingOccurrences(of: ";", with: "%3B")
        s = s.replacingOccurrences(of: "<", with: "%3C")
        s = s.replacingOccurrences(of: "=", with: "%3D")
        s = s.replacingOccurrences(of: ">", with: "%3E")
        s = s.replacingOccurrences(of: "?", with: "%3F")
        s = s.replacingOccurrences(of: ".", with: "%2E")
        s = s.replacingOccurrences(of: ",", with: "%2C")
        return s
    }
    
    
    func makePayloadForProject(certificationsarray: NSMutableArray, ratingsarray: NSMutableArray, versionsarray: NSMutableArray, statesarray : NSMutableArray, countriesarray : NSMutableArray) -> String{
        
        var certifications = String()
        var ratings = String()
        var versions = String()
        var states = String()
        var countries = String()
        
        for s in certificationsarray{
            var str = s as! String
            if(str != ""){
                if(certifications.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    certifications = certifications + "%20OR%20" + "\"" + str + "\""
                }else{
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    certifications = "%28field_prjt_certification_level:%28" + "\"" + str + "\""
                }
            }
        }
        
        if(certifications.count > 0){
            certifications = certifications + "%29%29"
        }
        
        for s in ratingsarray{
            var str = s as! String
            if(str != ""){
                if(ratings.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    ratings = ratings + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(certifications.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        ratings = "%28field_prjt_rating_system_version:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        ratings = "%20AND%20%28field_prjt_rating_system_version:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(ratings.count > 0){
            ratings = ratings + "%29%29"
        }
        
        for s in versionsarray{
            var str = s as! String
            if(str != ""){
                if(versions.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    versions = versions + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(ratings.count == 0 && certifications.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        versions = "%28field_prjt_version:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        versions = "%20AND%20%28field_prjt_version:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(versions.count > 0){
            versions = versions + "%29%29"
        }
        
        for s in statesarray{
            var str = s as! String
            if(str != ""){
                if(states.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    states = states + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(ratings.count == 0 && certifications.count == 0 && versions.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        states = "%28field_prjt_state:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        states = "%20AND%20%28field_prjt_state:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(states.count > 0){
            states = states + "%29%29"
        }
        
        for s in countriesarray{
            var str = s as! String
            if(str != ""){
                if(countries.count > 0){
                    str = str.replacingOccurrences(of: ":", with: "%3A")
                    countries = countries + "%20OR%20" + "\"" + str + "\""
                }else{
                    if(ratings.count == 0 && certifications.count == 0 && versions.count == 0 && states.count == 0){
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        countries = "%28field_prjt_country:%28" + "\"" + str + "\""
                    }else{
                        str = str.replacingOccurrences(of: ":", with: "%3A")
                        countries = "%20AND%20%28field_prjt_country:%28" + "\"" + str + "\""
                    }
                }
            }
        }
        
        if(countries.count > 0){
            countries = countries + "%29%29"
        }
        
        var parameter = certifications + ratings + versions + states + countries
        return converttoEncoded(parameter: parameter)
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
