//
//  Subnet.swift
//  NeCTARClient
//
//  Created by Qi Qi on 23/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Subnet {
    
    var name: String
    var id: String
    var subnetPool: String
    var ipVersion: String
    var cidr: String
    var ipAllocationPools: String
    var gatewayIp: String
    var dhcpEnabled: String
    var dnsNameServers: String = ""
    
    
    init?(json: JSON){
        name = json["subnet"]["name"].stringValue
        id = json["subnet"]["id"].stringValue
        
        subnetPool = json["subnet"]["subnetpool_id"].stringValue
        if subnetPool == "" {
            subnetPool = "None"
        }
        
        let ipVersionValue = json["subnet"]["ip_version"].stringValue
        ipVersion = "IPv\(ipVersionValue)"
        cidr = json["subnet"]["cidr"].stringValue
        
        let poolStart = json["subnet"]["allocation_pools"][0]["start"].stringValue
        let poolEnd = json["subnet"]["allocation_pools"][0]["end"].stringValue
        ipAllocationPools =  "Start \(poolStart) - End \(poolEnd)"
        
        gatewayIp = json["subnet"]["gateway_ip"].stringValue
        
        let dhcpEnableValue = json["subnet"]["enable_dhcp"].stringValue
        if dhcpEnableValue == "true" {
            dhcpEnabled = "Yes"
        } else {
            dhcpEnabled = "No"
        }
        
        let dnsNameServersList = json["subnet"]["dns_nameservers"].arrayValue
        for dns in dnsNameServersList{
            let dnsValue = dns.stringValue
            dnsNameServers = dnsNameServers + " " + dnsValue
        }
        
    }
}

