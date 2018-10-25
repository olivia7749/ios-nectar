//
//  NetworkEngine.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/7/28.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON



enum NeCTAREngineError : ErrorType {
    case CommonError(String?)
    case ErrorStatusCode(Int)
    case NSErrorWrapped(NSError)
}



class NeCTAREngine {
    static let sharedEngine = NeCTAREngine()
    
    //    let AuthURLString = "https://keystone.rc.nectar.org.au:5000/v2/auth/tokens"
    var manager:Alamofire.Manager
    
    init(){
        let sessionConfig = Alamofire.Manager.sharedInstance.session.configuration
        sessionConfig.HTTPCookieAcceptPolicy = .Never
        sessionConfig.HTTPShouldSetCookies = false
        self.manager = Alamofire.Manager(configuration: sessionConfig)
    }
    
    func doHttpRequest(
        method:Alamofire.Method,
        _ url: String,
          parameters: [String: AnyObject]? = nil,
          encoding: ParameterEncoding = .URL,
          headers: [String: String]? = nil)
        -> Promise<JSON>
    {
        var _params:[String:AnyObject]? = nil
        
        if let parameters = parameters {
            _params = parameters
            
        }
        
        return Promise() { fulfill, reject in
            let req = self.manager.request(
                method,
                url,
                parameters: _params,
                encoding: encoding,
                headers: headers)
            req.response
                {(req,resp,data,err) -> Void in
                    if let err = err {
                        reject(NeCTAREngineError.NSErrorWrapped(err))
                        return
                    }
                    if let resp = resp where resp.statusCode < 200 || resp.statusCode >= 300 {
                        reject(NeCTAREngineError.ErrorStatusCode(resp.statusCode))
                        return
                    }
                    if let data = data {
                        let json = JSON(data: data)
                        fulfill(json)
                    }
            }
        }
    }
}


// MARK: - Log in

extension NeCTAREngine {
    
    func login(tenantName: String, username: String, password: String) -> Promise<JSON> {
        let para: [String: AnyObject] = ["auth": [
            "tenantName": tenantName,
            "passwordCredentials": [
                "username": username,
                "password": password
            ]]]
        let authenticationURL = "https://keystone.rc.nectar.org.au:5000/v2.0/tokens"
        
        return doHttpRequest(.POST, authenticationURL, parameters: para, encoding: .JSON)
    }
}

// MARK: - Overall usage

extension NeCTAREngine {
    func getLimit(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/limits"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func checkUsage(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-simple-tenant-usage"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func getVolumeLimit(url: String, projectId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/limits"
        let header = ["X-Auth-Token": token]
        print(fullURL)
        print(token)
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
}


// MARK: - instance management
extension NeCTAREngine {
    
    func listInstances(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/detail"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func queryInstances(serverId:String, url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createInstance(url: String, name: String, flavor: String,
                        image: String, key: String, security: [String], azone: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/servers"
        
        var para: [String: AnyObject]?
        
        var para1: [[String: AnyObject]] = []
        
        for one in security{
            para1.append(["name": one])
        }
        
        if key.isEmpty && (azone.isEmpty||azone == "(Any availability zone)"){
            para = [
                "server":[
                    "name": name,
                    "flavorRef": flavor,
                    "imageRef": image,
                    "security_groups": para1]]
            
        } else if !key.isEmpty && (!azone.isEmpty && azone != "(Any availability zone)") {
            para = [
                "server":[
                    "name": name,
                    "flavorRef": flavor,
                    "imageRef": image,
                    "key_name": key,
                    "availability_zone": azone,
                    "security_groups": para1]]
        } else if key.isEmpty && (!azone.isEmpty && azone != "(Any availability zone)") {
            para = [
                "server":[
                    "name": name,
                    "flavorRef": flavor,
                    "imageRef": image,
                    "availability_zone": azone,
                    "security_groups": para1]]
        } else if !key.isEmpty && (azone.isEmpty||azone == "(Any availability zone)"){
            para = [
                "server":[
                    "name": name,
                    "flavorRef": flavor,
                    "imageRef": image,
                    "key_name": key,
                    "security_groups": para1]]
        }
        
        print(para)
        print(token)
        print(fullURL)
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteInstance(serverId: String, url:String, token: String) -> Promise<JSON>{
        let fullURL = url + "/servers/\(serverId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
}

// MARK: - instance action

extension NeCTAREngine {
    
    func instanceSecurityGroup(action: String, serverID: String,
                               url: String, sgName: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        var para: [String:AnyObject]
        if (action == "add"){
            para = ["addSecurityGroup": ["name":sgName]]
        }else {
            para = ["removeSecurityGroup": ["name":sgName]]
        }
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func createSnapshot(serverID: String, url: String,
                        snapshotName: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["createImage": ["name":snapshotName]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func rebuildInstance(serverID:String, url:String, image: String,
                         securityGroupName:String, token:String ) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["rebuild": ["imageRef": image, "name": securityGroupName ]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func instanceAction(serverID: String, url: String,
                        action: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        var para: [String: AnyObject]?
        switch action {
        case "pause":
            para = ["pause": NSNull()]
        case "unpause":
            para = ["unpause": NSNull()]
        case "lock":
            para = ["lock": NSNull()]
        case "unlock":
            para = ["unlock": NSNull()]
        case "resume":
            para = ["resume": NSNull()]
        case "start":
            para = ["os-start": NSNull()]
        case "stop":
            para = ["os-stop": NSNull()]
        case "suspend":
            para = ["suspend": NSNull()]
        case "forceDelete":
            para = ["forceDelete": NSNull()]
        default:
            ()
        }
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func rebootInstance(serverID: String, method: String,
                        url: String, token:String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["reboot":["type":method]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func checkServerUsage(serverID: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/diagnostics"
        let header = ["X-Auth-Token": token]
        let para = ["server_id": serverID]
        return doHttpRequest(.GET, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
}

// MARK: - instance administrative action

extension NeCTAREngine {
    
    func createBackUp(serverID: String, url: String, name: String,
                      backupType:String, rotation: Int, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/action"
        let header = ["X-Auth-Token": token]
        let para = ["createBackup":["name":name, "backup_type": backupType, "rotation": rotation]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func showUsage(serverID: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/diagnostics"
        let header = ["X-Auth-Token": token]
        let para = ["server_id": serverID]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
}

// MARK: - Security Group


// MARK: - volume attachment

extension NeCTAREngine{
    func listVolume(projectId: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/volumes/detail"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func queryVolume(projectId: String, volumeId: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/volumes/\(volumeId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    
    func attachVolume(volumeId: String, instanceId: String, url: String,
                      token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(instanceId)/os-volume_attachments"
        let header = ["X-Auth-Token": token]
        let para = ["volumeAttachment": [
            "volumeId": volumeId]]
        print(fullURL)
        print(para)
        print(token)
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func upAttachment(serverID: String, attahmentId: String,
                      newVolumeId: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/os-volume_attachments/\(attahmentId)"
        let header = ["X-Auth-Token": token]
        let para = ["volumeAttachment":["volumeId": newVolumeId]]
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .URL, headers: header)
    }
    
    func deleteAttachment(serverID: String, volumeId: String,
                          url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/servers/\(serverID)/os-volume_attachments/\(volumeId)"
        //let para = ["os-detach": NSNull()]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func deleteVolume(projectId: String, volumeId: String,
                      url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/volumes/\(volumeId)"
        let header = ["X-Auth-Token": token]
        print(fullURL)
        print(token)
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func updateVolume(projectId: String, volumeId: String, name: String, description: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/volumes/\(volumeId)"
        let para = ["volume" : [
            "name": name,
            "description": description]]
        let header = ["X-Auth-Token": token]
        print(fullURL)
        print(para)
        print(token)
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func extendVolume(projectId: String, volumeId: String, size: Int, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/volumes/\(volumeId)/action"
        let para = ["os-extend" : [
            "new_size": size]]
        let header = ["X-Auth-Token": token]
        print(fullURL)
        print(para)
        print(token)
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func createVolume(url: String, projectId: String, name: String, vdescription: String,
                      type: String, size: Int, azone: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/v3/\(projectId)/volumes"
        
        var para: [String: AnyObject]?
        
        if vdescription.isEmpty && (type == "No volume type"||type.isEmpty) {
            para = ["volume":[
                "name": name,
                "description": NSNull(),
                "volume_type": NSNull(),
                "size": size,
                "availability_zone": azone]]
        } else if !vdescription.isEmpty && (type == "No volume type"||type.isEmpty) {
            para = ["volume":[
                "name": name,
                "description": vdescription,
                "volume_type": NSNull(),
                "size": size,
                "availability_zone": azone]]
        } else if vdescription.isEmpty && (type != "No volume type" && !type.isEmpty) {
            para = ["volume":[
                "name": name,
                "description": NSNull(),
                "volume_type": type,
                "size": size,
                "availability_zone": azone]]
        } else if !vdescription.isEmpty && (type != "No volume type" && !type.isEmpty) {
            para = ["volume":[
                "name": name,
                "description": vdescription,
                "volume_type": type,
                "size": size,
                "availability_zone": azone]]
        }
        
        print(para)
        print(token)
        print(fullURL)
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
}

// MARK: - flavors

extension NeCTAREngine {
    
    func listFlavors(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/flavors/detail"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createFlavor(url: String, token: String, name: String,
                      id: String, ram: Int, disk: Int, vcpus: Int, ephemeralDisk: Int,
                      swap: Int, rxtxFactor: Float, isPublic: Bool) -> Promise<JSON> {
        let fullURL = url + "/flavors"
        let header = ["X-Auth-Token": token]
        let para = ["flavor": ["name": name, "id": id,"ram": ram, "disk": disk, "vcpus": vcpus,
            "OS-FLV-EXT-DATA:ephemeral":ephemeralDisk, "swap": swap, "rxtx_factor": rxtxFactor,
            "os-flavor-access:is_public": isPublic]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteFlavor(url: String, token:String, flavorId:String) -> Promise<JSON> {
        let fullURL = url + "/flavors"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: ["flavor_id": flavorId],
                             encoding: .URL, headers: header)
    }
    
    func listZone(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-availability-zone"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
}

// MARK: - keypairs

extension NeCTAREngine {
    
    func createKeyPair(keyName: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs"
        let para = ["keypair":["name": keyName]]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
        
    }
    
    func importKeypair(keyName: String, url: String,
                       publicKey: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs"
        let para = ["keypair":["name": keyName, "public_key": publicKey]]
        let header = ["X-Auth-Token": token]
        
        print(token)
        print(fullURL)
        print(para)
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func listKeyPair(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func keypairDetail(keyName: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs/\(keyName)"
        let para = ["keypair_name": keyName]
        let header = ["X-Auth-Token": token]
        
        print(fullURL)
        print(para)
        print(header)
        
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func deleteKeyPair(keyName: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/os-keypairs/\(keyName)"
        let header = ["X-Auth-Token": token]
        let para = ["keypair_name": keyName]
        return doHttpRequest(.DELETE, fullURL, parameters: para, encoding: .URL, headers: header)
    }
}

// MARK: - snapshot

extension NeCTAREngine{
    
    func listVolumeSnapshot(projectId: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/snapshots"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createVolumeSnapshot(volumeId: String, projectId: String, description: String, url: String,
                              name: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/snapshots"
        let header = ["X-Auth-Token": token]
        let para = ["snapshot":[
            "volume_id": volumeId,
            "description": description,
            "name": name]]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteVolumeSnapshot(projectId: String, snapshotId: String, url: String,
                              token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/snapshots/\(snapshotId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func updateVolumeSnapshot(projectId: String, snapshotId: String, name: String, description: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v3/\(projectId)/snapshots/\(snapshotId)"
        let para = ["snapshot" : [
            "name": name,
            "description": description]]
        let header = ["X-Auth-Token": token]
        print(fullURL)
        print(para)
        print(token)
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
}

// MARK: - Images

extension NeCTAREngine {
    func listImages(url:String, token: String, owner: String) -> Promise<JSON> {
        
        let header = ["X-Auth-Token": token]
        let para = ["owner": owner]
        return doHttpRequest(.GET, url, parameters: para, encoding: .URL, headers: header)
    }
    
    func listImages(url:String, token: String) -> Promise<JSON> {
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, url, parameters: nil, encoding: .URL, headers: header)
    }
    
    func queryImage (url: String, token: String, imageID: String) -> Promise<JSON> {
        let fullURL = url + "/v2/images/\(imageID)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func deleteImage (url: String, token: String, imageId: String) -> Promise<JSON> {
        let fullURL = url + "/v2/images/\(imageId)"
        let header = ["X-Auth-Token": token]
        let para = ["image_id": imageId]
        print(fullURL)
        return doHttpRequest(.DELETE, fullURL, parameters: para, encoding: .URL, headers: header)
        
    }
    
    //    func updateImage(url: String, imageId: String, name: String, format: String, disk: String, ram: String, isPublic: String, isProtected: String, token: String)  -> Promise<JSON> {
    //        let fullURL = url + "/v2/images/\(imageId)"
    //        let header = ["X-Auth-Token": token, "Content-Type": "application/openstack-images-v2.1-json-patch"]
    //        var para: [[String: AnyObject]] = [["op": "replace", "path": "/name", "value": name]]
    //
    //        para.append(["op": "replace", "path": "/disk_format", "value": format])
    //
    //        para.append(["op": "replace", "path": "/min_disk", "value": disk])
    //
    //         para.append(["op": "replace", "path": "/min_ram", "value": ram])
    //
    //         para.append(["op": "replace", "path": "/visibility", "value": isPublic])
    //
    //        if isProtected == "true" {
    //             para.append(["op": "replace", "path": "/protected", "value": true])
    //        } else {
    //             para.append(["op": "replace", "path": "/protected", "value": false])
    //        }
    //
    //        print(fullURL)
    //        print(para)
    //        print(token)
    //        return doHttpRequest1(.PATCH, fullURL, parameters: para, encoding: .JSON, headers: header)
    //
    //    }
    
}


extension NeCTAREngine {
    
    func listSecurityGroups(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/security-groups"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func querySecurityGroups(url: String, token: String, securityId: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/security-groups/\(securityId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createSecurityGroup(name: String, description: String,
                             url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/security-groups"
        let para = ["security_group": [
            "name": name,
            "description": description]]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteSecurityGroups(securityGroupID: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/security-groups/\(securityGroupID)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .JSON, headers: header)
    }
    
    func updateSecurityGroups(securityGroupID: String, name: String, description: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/security-groups/\(securityGroupID)"
        let header = ["X-Auth-Token": token]
        let para = ["security_group": [
            "name": name,
            "description": description]]
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteSecurityGroupsRule(securityGroupRuleID: String, url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/security-group-rules/\(securityGroupRuleID)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .JSON, headers: header)
    }
    
    func addSecurityGroupsRule(url: String, securityGroupRuleID: String, rule: String, direction: String, min: Int, max: Int, type: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/security-group-rules"
        let header = ["X-Auth-Token": token]
        let para = ["security_group_rule": [
            "protocol": rule,
            "direction": direction,
            "port_range_min": min,
            "port_range_max": max,
            "ethertype": type,
            "security_group_id": securityGroupRuleID]]
        print(para)
        print(fullURL)
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    
}

// MARK: - instance action

extension NeCTAREngine {
    
    func listRouters(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/routers"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createRouter(url: String, name: String, snat: String, external_gateway_info: String, admin_state_up: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/v2.0/routers"
        
        var para: [String: AnyObject]?
        
        if external_gateway_info == "" {
            para = [
                "router":[
                    "name": name,
                    "external_gateway_info": NSNull(),
                    "admin_state_up": admin_state_up]]
        } else {
            para = [
                "router":[
                    "name": name,
                    "external_gateway_info":[
                        "network_id": external_gateway_info
                    ],
                    "admin_state_up": admin_state_up
                ]
            ]
        }
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteRouter(routerId: String, url:String, token: String) -> Promise<JSON>{
        let fullURL = url + "/v2.0/routers/\(routerId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func editRouter(url: String, name: String, external_gateway_info: String, admin_state_up: String, routerID: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/v2.0/routers/\(routerID)"
        
        var para: [String: AnyObject]?
        
        
        if external_gateway_info == "" {
            para = [
                "router":[
                    "name": name,
                    "external_gateway_info": NSNull(),
                    "admin_state_up": admin_state_up]]
            
        } else {
            para = [
                "router":[
                    "name": name,
                    "external_gateway_info":[
                        "network_id": external_gateway_info
                    ],
                    "admin_state_up": admin_state_up
                ]
            ]
        }
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
}

// MARK: - FloatingIP action

extension NeCTAREngine {
    
    func listFloatingIPs(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/floatingips"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createFloatingIP(url: String, floating_network_id: String, descrip: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/v2.0/floatingips"
        
        var para: [String: AnyObject]?
        para = [
            "floatingip":[
                "floating_network_id": floating_network_id,
                "description": descrip
            ]
        ]
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteFloatingIP(floatingip_id: String, url:String, token: String) -> Promise<JSON>{
        let fullURL = url + "/v2.0/floatingips/\(floatingip_id)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
}

// MARK: - Container action

extension NeCTAREngine {
    
    func listContainers(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "?format=json"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createPrivateContainer(url: String, name: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/" + name
        
        let header = ["X-Auth-Token": token, "X-Container-Read": ""]
        return doHttpRequest(.PUT, fullURL, parameters: nil, encoding: .JSON, headers: header)
    }
    
    func createPublicContainer(url: String, name: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/" + name
        
        let header = ["X-Auth-Token": token, "X-Container-Read": ".r:*"]
        return doHttpRequest(.PUT, fullURL, parameters: nil, encoding: .JSON, headers: header)
    }
    
    func deleteContainer(name: String, url: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/" + name
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .JSON, headers: header)
    }
    
    func listObjects(url:String, containerName: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/" + containerName + "?format=json"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func deleteObject(containerName: String, objectName: String, url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/"+containerName+"/"+objectName
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createObject(containerName: String, objectName: String, url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/"+containerName+"/"+objectName
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.PUT, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    
}

// MARK: - Network action

extension NeCTAREngine {
    
    
    func queryNetwork (url: String, token: String, networkID: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/networks/\(networkID)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func listNetworks(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/networks"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func deleteNetwork(url:String, networkID: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/networks/\(networkID)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createNetwork(url: String, adminState: String, name: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/v2.0/networks"
        
        var para: [String: AnyObject]?
        para = [
            "network":[
                "name": name,
                "admin_state_up": adminState
            ]
        ]
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func querySubnet (url: String, token: String, subnetID: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/subnets/\(subnetID)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func createSubnet(url: String, name: String, networkId: String, ipVersion: String, cidr: String, token: String) -> Promise<JSON>{
        let fullURL = url + "v2.0/subnets"
        
        var para: [String: AnyObject]?
        para = [
            "subnet":[
                "name": name,
                "network_id": networkId,
                "ip_version": ipVersion,
                "cidr": cidr
            ]
        ]
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteSubnet(url:String, subnetId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/subnets/\(subnetId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func listPorts(url: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/ports"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .JSON, headers: header)
    }
    
    func deletePort(url:String, portId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/v2.0/ports/\(portId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createPort(url: String, name: String, networkId: String, adminState: String, token: String) -> Promise<JSON>{
        
        let fullURL = url + "/v2.0/ports"
        
        var para: [String: AnyObject]?
        if name == "" && adminState == "" {
            para = [
                "port":[
                    "network_id": networkId
                ]
            ]
        } else if name == "" {
            para = [
                "port":[
                    "network_id": networkId,
                    "admin_state_up": adminState
                ]
            ]
        } else if adminState == "" {
            para = [
                "port":[
                    "network_id": networkId,
                    "name": name]]
        } else {
            para = [
                "port":[
                    "network_id": networkId,
                    "name": name,
                    "admin_state_up": adminState
                ]
            ]
        }
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
}

// MARK: - Database action

extension NeCTAREngine {
    
    func listDatabaseInstances(url:String, tenantId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func queryDatabaseInstance (url: String, token: String,tenantId: String, instanceId: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func queryDatabaseRoot (url: String, token: String,tenantId: String, instanceId: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)/root"
        print("fullURL: \(fullURL)")
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func queryDatabaseflavor (url: String, token: String,tenantId: String, flavorId: String) -> Promise<JSON> {
        let fullURL = url + "/flavors/\(flavorId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
        
    }
    
    func createBackup(url: String, name: String, instanceId: String, descrip: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/backups"
        
        var para: [String: AnyObject]?
        para = [
            "backup":[
                "description": descrip,
                
                "instance": instanceId,
                "name": name
            ]
        ]
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func listBackups(url:String, instanceId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)/backups"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func deleteBackup(url:String, backupId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/backups/\(backupId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createDatabaseinstance(url: String, instanceName: String, lacality: String, datastoreVersion: String,datastoreType: String,flavorRef: String, volumeSize: String, availableZone: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/instances"
        let volumeInt: Int = Int(volumeSize)!
        var para: [String: AnyObject]?
        if lacality == "None" {
            para = [
                "instance":[
                    "name": instanceName,
                    "flavorRef": flavorRef,
                    "availability_zone": availableZone,
                    "datastore" : [
                        "version" : datastoreVersion,
                        "type" : datastoreType
                    ],
                    "volume": [
                        "size": volumeInt
                    ]
                ]
            ]
        } else {
            para = [
                "instance":[
                    "name": instanceName,
                    "flavorRef": flavorRef,
                    "availability_zone": availableZone,
                    "locality": lacality,
                    "datastore" : [
                        "version" : datastoreVersion,
                        "type" : datastoreType
                    ],
                    "volume": [
                        "size": volumeInt
                    ]
                ]
            ]
        }
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteDatabaseInstance(url:String, instanceId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func listDatabaseFlavors(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/flavors"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func listConfigurations(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/configurations"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func deleteConfigurationGroup(url:String, configId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/configurations/\(configId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func createConfigGroup(url: String, name: String, descrip: String, datastoreVersion: String,datastoreType: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/configurations"
        var para: [String: AnyObject]?
        para = [
            "configuration":[
                "name": name,
                "description": descrip,
                "datastore" : [
                    "version" : datastoreVersion,
                    "type" : datastoreType
                ]
            ]
        ]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    func createConfigurationGroup(url: String, name: String, descrip: String, datastoreVersion: String,datastoreType: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/configurations"
        var para: [String: AnyObject]?
        para = [
            "configuration":[
                "datastore" : [
                    "type" : datastoreType,
                    "version" : datastoreVersion
                ],
                "description": descrip,
                "values": NSDictionary(),
                "name": name
            ]
        ]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func listAvailabilityZone(url: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/os-availability-zone"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .JSON, headers: header)
        
    }
    
}

// MARK: - Edit database instance action

extension NeCTAREngine {
    
    func resizeDatabaseInstanceVolume(url:String, instanceId: String, newSize: Int, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)/action"
        var para: [String: AnyObject]?
        para = [
            "resize":[
                "volume":[
                    "size": newSize
                ]
            ]
        ]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func attachDatabaseInstanceConfig(url:String, instanceId: String, configId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)"
        var para: [String: AnyObject]?
        para = [
            "instance":[
                "configuration": configId
            ]
        ]
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func detachDatabaseInstanceConfig(url:String, instanceId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)"
        var para: [String: AnyObject]?
        para = [
            "instance":NSDictionary()
        ]
        
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.PUT, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func enableDatabaseInstanceRoot(url:String, instanceId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)/root"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func disableDatabaseInstanceRoot(url:String, instanceId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)/root"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func restartDatabaseInstance(url:String, instanceId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/instances/\(instanceId)/action"
        var para: [String: AnyObject]?
        para = [
            "restart":NSDictionary()
        ]
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func listInstanceForConfigGroup(url:String, configId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/configurations/\(configId)/instances"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
}

// MARK: - Orchestration action

extension NeCTAREngine {
    
    func listResourceType(url:String, tenantId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/resource_types"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func queryResourceType(url:String, typeName: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/resource_types/\(typeName)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func listTemplateVersion(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/template_versions"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func queryTemplateVersion(url:String, template_version: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/template_versions/\(template_version)/functions"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func listStacks(url:String, token: String) -> Promise<JSON> {
        let fullURL = url + "/stacks"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func queryStack(url:String, stackName: String, stackId: String, token: String) -> Promise<JSON> {
        let fullURL = url + "/stacks/\(stackName)/\(stackId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.GET, fullURL, parameters: nil, encoding: .URL, headers: header)
    }
    
    func suspendStack(url: String,stackName: String, stackId: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/stacks/\(stackName)/\(stackId)/actions"
        let header = ["X-Auth-Token": token]
        var para: [String: AnyObject]?
        para = [
            "suspend": NSNull()
        ]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func checkStack(url: String, stackName: String, stackId: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/stacks/\(stackName)/\(stackId)/actions"
        let header = ["X-Auth-Token": token]
        var para: [String: AnyObject]?
        para = [
            "check": NSNull()
        ]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func resumeStack(url: String,stackName: String, stackId: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/stacks/\(stackName)/\(stackId)/actions"
        let header = ["X-Auth-Token": token]
        var para: [String: AnyObject]?
        para = [
            "resume": NSNull()
        ]
        return doHttpRequest(.POST, fullURL, parameters: para, encoding: .JSON, headers: header)
    }
    
    func deleteStack(url: String, stackName: String, stackId: String, token: String) -> Promise<JSON>{
        let fullURL = url + "/stacks/\(stackName)/\(stackId)"
        let header = ["X-Auth-Token": token]
        return doHttpRequest(.DELETE, fullURL, parameters: nil, encoding: .URL, headers: header)
    }

}