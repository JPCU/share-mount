//
//  statusMenu.swift
//  Quick Tasks
//
//  Created by Kevin Meziere on 3/8/23.
//

import SwiftUI


enum NavigationItem {
    case agenda
    case calendar
    case materie
    case subjects
}

struct statusMenu: View {
    
   // @Environment(\.managedObjectContext) var moc
   // @Binding var selection : Set<NavigationItem>

    var body: some View {
        HStack{
            //List() {
            VStack(alignment:.leading){
                Spacer()
                Button("\(Image(systemName: "globe")) Shares") {
                }.buttonStyle(.borderless).tint(Color(red: 0.8, green: 0.8, blue:0.8)).fontWeight(.semibold)
                                Spacer()
                Button("\(Image(systemName: "power")) Quit") {
                    NSApplication.shared.terminate(nil)
                }.buttonStyle(.borderless).tint(Color(red: 0.5, green: 0.5, blue:0.5)).padding()
            }.frame(width: 100, height: 300).background(Color(red: 0.66, green: 0.2, blue:0.235))
                              
           Spacer()

            MountsView()
            Spacer()
        }
        .frame(width: 350, height: 300)
    }
}

struct statusMenu_Previews: PreviewProvider {
    static var previews: some View {
       statusMenu()
    }
}
