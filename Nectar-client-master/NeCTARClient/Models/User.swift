//
//  User.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/4.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
    var tokenID: String
    var tenantID: String
    var tenantDescription: String
    var tenantName: String
    var dnsServiceURL: String
    var computeServiceURL: String
    var networkServiceURL: String
    var volumnV2ServiceURL: String
    var S3ServiceURL: String
    var alarmingServiceURL: String
    var imageServiceURL: String
    var meteringServiceURL: String
    var cloudformationServiceURL: String
    var applicationCatalogURL: String
    var volumnV1ServiceURL: String
    var EC2ServiceURL: String
    var orchestrationServiceURL: String
    var username: String
    var userId: Int
    var owner: String
    var volumeV3ServiceURL: String
    var objectStorageServiceURL: String
    var databaseServiceURL: String
    
    
    
    init?(json:JSON) {
        let accessInfo = json["access"]
        let token = accessInfo["token"]
        let serviceCatalog = accessInfo["serviceCatalog"].arrayValue
        let userInfo = accessInfo["user"]
        //        print("user\(userInfo)")
        var urlDict = [String: String]()
        for service in serviceCatalog {
            urlDict[service["type"].stringValue] = service["endpoints"][0]["publicURL"].stringValue
        }
        //        print(urlDict)
        //
        self.tokenID = token["id"].stringValue
        self.tenantName = token["tenant"]["name"].stringValue
        self.tenantID = token["tenant"]["id"].stringValue
        self.tenantDescription = token["tenant"]["description"].stringValue
        //        print("tenantDescription:\(tenantDescription)")
        self.dnsServiceURL = urlDict["dns"]!
        self.computeServiceURL = urlDict["compute"]!
        self.networkServiceURL = urlDict["network"]!
        self.volumnV2ServiceURL = urlDict["volumev2"]!
        self.S3ServiceURL = urlDict["s3"]!
        self.alarmingServiceURL = urlDict["alarming"]!
        self.imageServiceURL = urlDict["image"]!
        self.meteringServiceURL = urlDict["metric"]!
        self.cloudformationServiceURL = urlDict["cloudformation"]!
        self.applicationCatalogURL = urlDict["application-catalog"]!
        self.volumnV1ServiceURL = urlDict["volume"]!
        self.EC2ServiceURL = urlDict["ec2"]!
        self.orchestrationServiceURL = urlDict["orchestration"]!
        self.objectStorageServiceURL = urlDict["object-store"]!
        self.databaseServiceURL = urlDict["database"]!
        //        print("orche\(orchestrationServiceURL)")
        //        self.dnsServiceURL = serviceCatalog[9]["endpoints"][0]["publicURL"].stringValue
        //        self.computeServiceURL = serviceCatalog[13]["endpoints"][0]["publicURL"].stringValue
        //        self.networkServiceURL = serviceCatalog[5]["endpoints"][0]["publicURL"].stringValue
        //        self.volumnV2ServiceURL = serviceCatalog[17]["endpoints"][0]["publicURL"].stringValue
        //        self.S3ServiceURL = serviceCatalog[6]["endpoints"][0]["publicURL"].stringValue
        //        self.alarmingServiceURL = serviceCatalog[7]["endpoints"][0]["publicURL"].stringValue
        //        self.imageServiceURL = serviceCatalog[10]["endpoints"][0]["publicURL"].stringValue
        //        self.meteringServiceURL = serviceCatalog[0]["endpoints"][0]["publicURL"].stringValue
        //        self.cloudformationServiceURL = serviceCatalog[2]["endpoints"][0]["publicURL"].stringValue
        //        self.applicationCatalogURL = serviceCatalog[8]["endpoints"][0]["publicURL"].stringValue
        //        self.volumnV1ServiceURL = serviceCatalog[12]["endpoints"][0]["publicURL"].stringValue
        //        self.EC2ServiceURL = serviceCatalog[3]["endpoints"][0]["publicURL"].stringValue
        //        self.orchestrationServiceURL = serviceCatalog[21]["endpoints"][0]["publicURL"].stringValue
        
        self.username = userInfo["username"].stringValue
        self.userId = userInfo["id"].intValue
        self.owner = orchestrationServiceURL.componentsSeparatedByString("/")[4]
        self.volumeV3ServiceURL = "https://cinder.rc.nectar.org.au:8776/"
    }
    
}