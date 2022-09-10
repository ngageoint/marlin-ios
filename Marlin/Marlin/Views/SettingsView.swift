//
//  SettingsView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/2/22.
//

import SwiftUI

struct SettingsView: View {
    //First get the nsObject by defining as an optional anyObject
    let version = Bundle.main.releaseVersionNumber ?? ""
    let buildVersion = Bundle.main.buildVersionNumber ?? ""
    @State var tapCount: Int = 1
    
    @AppStorage("lifeSizeLights") var lifeSizeLights = false
    @AppStorage("showMapScale") var showMapScale = false
    
    var body: some View {
        List {
            NavigationLink {
                ScrollView {
                    VStack (alignment: .leading) {
                        Text("LEGAL DISCLAIMER")
                            .font(Font.headline6)
                            .fontWeight(.medium)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 16)
                        Text("Under 10 U.S. Code §456, \"no civil action may be brought against the United States on the basis of the content of geospatial information prepared or disseminated by the National Geospatial-Intelligence Agency (NGA).\" This bar against civil action also applies to either of NGA’s predecessor organizations, the National Imagery and Mapping Agency (NIMA) or the Defense Mapping Agency. Geospatial information includes navigation information and any navigational product or aid prepared or disseminated by NGA. The geospatial information at this website was developed to meet the requirements of the United States Government. This information is provided \"as is,\" and no warranty, express or implied, including but not limited to the implied warranties of merchantability and fitness for particular purpose or arising by statute or otherwise in law or from a course of dealing or usage in trade, is made by NGA as to the accuracy and functioning of this geospatial information. Neither NGA nor its personnel will be liable for any claims, losses, or damages arising from or connected with the use of this geospatial information. The user agrees to hold harmless the United States National Geospatial-Intelligence Agency. The user's sole and exclusive remedy is to stop using the navigation information provided at this website.")
                            .font(Font.body2)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 32)
                        Text("DISCLAIMER NOTICE")
                            .font(Font.headline6)
                            .fontWeight(.medium)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 16)
                        Text("Information from this server resides on a computer system funded by the National Geospatial-Intelligence Agency. This system and related equipment are intended for the communication, transmission, processing and storage of U.S. Government information. These systems and equipment are subject to monitoring to ensure proper functioning, to protect against improper or unauthorized use or access, and to verify their presence or performance of applicable security features or procedures, and for other like purposes. Such monitoring may result in the acquisition, recording and analysis of all data being communicated, transmitted, processed or stored in this system by a user. If monitoring reveals evidence of possible criminal activity, such evidence may be provided to law enforcement personnel. Use of this system constitutes consent to such monitoring.")
                            .font(Font.body2)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 32)
                        Text("DISCLAIMER OF LIABILITY")
                            .font(Font.headline6)
                            .fontWeight(.medium)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 16)
                        Text("With respect to documents available from this server, neither the United States Government nor the National Geospatial-Intelligence Agency Agency nor any of their employees, makes any warranty, express or implied, including the warranties of merchantability and fitness for a particular purpose, or assumes any legal liability or responsibility for the accuracy, completeness, or usefulness of any information, apparatus, product, or process disclosed, or represents that its use would not infringe privately owned rights.")
                            .font(Font.body2)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 32)
                        Text("DISCLAIMER OF ENDORSEMENT")
                            .font(Font.headline6)
                            .fontWeight(.medium)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 16)
                        Text("Reference herein to any specific commercial products, process, or service by trade name, trademark, manufacture, or otherwise, does not necessarily constitute or imply its endorsement, recommendation, or favoring by the United States Government or the National Geospatial-Intelligence Agency. The views and opinions of authors expressed herein do not necessarily state or reflect those of the United States Government or the National Geospatial-Intelligence Agency, and shall not be used for advertising or product endorsement purposes.")
                            .font(Font.body2)
                            .tint(Color.onSurfaceColor)
                            .padding(.bottom, 32)
                        Spacer()
                    }
                    .padding([.leading, .top, .bottom, .trailing], 16)
                    .background(Color.surfaceColor)
                }
                .navigationTitle("Disclaimer")
            } label: {
                Text("Disclaimer")
            }
            NavigationLink {
                VStack {
                    Text("Marlin v\(version)b\(buildVersion)")
                    .font(Font.headline6)
                    Spacer()
                }
                .padding([.leading, .top, .bottom, .trailing], 16)
                .navigationTitle("About Marlin v\(version)")
            } label: {
                Text("About")
            }
            HStack {
                Text("Marlin v\(version)")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tapCount += 1
            }
            
            if tapCount > 5 {
                Section("Developer Tools") {
                    Toggle(isOn: $lifeSizeLights, label: {
                        Image(systemName: "lightbulb.fill")
                        Text("Lights Show Distance")
                    })
                    .padding([.top, .bottom], 8)
                    Toggle(isOn: $showMapScale, label: {
                        Image(systemName: "ruler.fill")
                        Text("Show Map Scale (requires restart)")
                    })
                    .padding([.top, .bottom], 8)
                }.toggleStyle(SwitchToggleStyle(tint: .primaryColorVariant))
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
