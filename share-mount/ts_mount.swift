//
//  wg_mount.swift
//  Quick Tasks
//
//  Created by Kevin Meziere on 3/1/23.
//

import Foundation
import NetFS

struct tsStatus: Decodable {
    let Peer: [String: tsPeer]
    let BackendState: String
}

struct tsPeer: Decodable {
    let ID: String
    let HostName: String
    let DNSName: String
    let Tags: [String]
}

enum peersResult {
    case Ok([(String, String, Optional<URL>)])
    case Error(String)
}

func finder_open(url:String) {
    do {
        try safeShell("/usr/bin/open " + url)
    }
    catch {
        print("\(error)") //handle or silence the error here
    }
    
}

func ts_smb_peers() -> peersResult {
    var result:[(String, String, Optional<URL>)] = []
    do {
        let status = try safeShell("/Applications/Tailscale.app/Contents/MacOS/Tailscale status --json")
        let decoded = try JSONDecoder().decode(tsStatus.self, from: Data(status.utf8))
        if decoded.BackendState == "Running"{
            for(peer) in decoded.Peer {
                for(tag) in peer.value.Tags {
                    if tag.contains("smb") && !result.contains(where: {(k,_, _) in
                        if k == peer.value.DNSName {return true}
                        else {return false}}){
                        result.append(
                            (peer.value.DNSName,
                             peer.value.DNSName.components(separatedBy: ".")[0], nil)
                        )
                    }
                }
            }
        }
        else {
            return peersResult.Error("Tailscale Not Connected")
        }
    }
    catch {
        return peersResult.Error("\(error)")
    }
    
    let keys: [URLResourceKey] = [.volumeURLForRemountingKey, .volumeURLKey]
    let paths = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [])
    if let urls = paths {
        for url in urls {
            let components = url.pathComponents
            if components.count > 1
               && components[1] == "Volumes"
            {
                let remountUrl = try? url.resourceValues(forKeys: Set(arrayLiteral: .volumeURLForRemountingKey)).volumeURLForRemounting
                if let k = result.firstIndex(where: {(_,host,_) in
                    remountUrl?.formatted().contains(host) ?? false
                }){
                    
                    result[k].2 = url
                }
            }
        }
    }
    
    return peersResult.Ok(result)
}

func mount_smb_peer(peer:String) {
    let kNAUIOptionKey = "UIOption"
    let kNAUIOptionNoUI = "NoUI"
    let kNetFSUseGuestKey = "Guest"

    let dict = NSMutableDictionary()
        dict[kNAUIOptionKey] = kNAUIOptionNoUI
        dict[kNetFSUseGuestKey] = NSNumber(value: true)
    
    
    let url = URL(string: "smb://" + peer + "/share")!
    let err = NetFSMountURLSync(
        url as NSURL,           // url
        nil,                    // mountpath
        nil,                    // user
        nil,                    // passwd
        dict,                   // open_options
        nil,                    // mount_options,
        nil                     // mountpoints
    )
    print(err)
}

// See https://stackoverflow.com/questions/26971240/how-do-i-run-a-terminal-command-in-a-swift-script-e-g-xcodebuild
// updated answer by user3064009

@discardableResult // Add to suppress warnings when you don't want/need a result
func safeShell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
    task.standardInput = nil

    try task.run() //<--updated
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}
