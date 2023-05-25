//
//  MountsView.swift
//  Quick Tasks
//
//  Created by Kevin Meziere on 3/8/23.
//

import SwiftUI

struct MountsView: View {
    
    @Environment(\.openURL) private var openURL
    
    @State var smbTargets: peersResult = .Ok([])
    //[(String, String, Optional<URL>)] = []
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("My Shares").fontWeight(.heavy)
                Button(action: { smbTargets = ts_smb_peers()}, label: { Image(systemName: "arrow.clockwise") }).buttonStyle(.borderless)
                Spacer()
            }.padding()
            
            switch smbTargets {
            case .Ok(let r_smbTargets):
                ForEach(r_smbTargets, id: \.0) { smbTarget in
                    Button(action: {
                        
                        if let u = smbTarget.2 {
                            finder_open(url:u.formatted())
                        }
                        else{
                            mount_smb_peer(peer: smbTarget.0)
                            smbTargets = ts_smb_peers()
                        }
                        }, label: {
                            HStack {
                                if smbTarget.2 != nil {
                                    Image(systemName: "externaldrive.connected.to.line.below.fill")
                                        .foregroundStyle(.blue, .black)
                                }
                                else {
                                    Image(systemName: "externaldrive.connected.to.line.below")
                                }
                                Text(smbTarget.1)
                            }
                        }).buttonStyle(.borderless).frame(alignment: .leading)
                }
            case .Error(let msg):
                Text(msg)
            }

            Spacer()
        }.onReceive(timer) { input in
            smbTargets = ts_smb_peers()
        }.onAppear(){
            smbTargets = ts_smb_peers()
        }
        }
}

struct MountsView_Previews: PreviewProvider {
    static var previews: some View {
        MountsView()
    }
}
