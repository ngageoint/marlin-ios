//
//  DisclaimerView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/10/22.
//

import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            legalDisclaimer()
            securityPolicy()
            liabilityDisclaimer()
            endorsementDisclaimer()
        }
        .padding([.leading, .top, .bottom, .trailing], 16)
        .navigationTitle("Disclaimer")
    }
    
    @ViewBuilder
    private func legalDisclaimer() -> some View {
        Text("Legal Disclaimer")
            .fontWeight(.medium)
            .font(Font.headline6)
            .opacity(0.87)
            .padding(.bottom, 16)
        Text("""
            Under 10 U.S. Code §456, \"no civil action may be brought against the United States on the \
            basis of the content of geospatial information prepared or disseminated by the National \
            Geospatial-Intelligence Agency (NGA).\" This bar against civil action also applies to either \
            of NGA’s predecessor organizations, the National Imagery and Mapping Agency (NIMA) or the \
            Defense Mapping Agency. Geospatial information includes navigation information and any \
            navigational product or aid prepared or disseminated by NGA. The geospatial information at \
            this website was developed to meet the requirements of the United States Government. This \
            information is provided \"as is,\" and no warranty, express or implied, including but not \
            limited to the implied warranties of merchantability and fitness for particular purpose or \
            arising by statute or otherwise in law or from a course of dealing or usage in trade, is made \
            by NGA as to the accuracy and functioning of this geospatial information. Neither NGA nor its \
            personnel will be liable for any claims, losses, or damages arising from or connected with \
            the use of this geospatial information. The user agrees to hold harmless the United States \
            National Geospatial-Intelligence Agency. The user's sole and exclusive remedy is to stop \
            using the navigation information provided at this website.
            """)
            .font(Font.body2)
            .opacity(0.6)
            .padding(.bottom, 32)
    }
    
    @ViewBuilder
    private func securityPolicy() -> some View {
        Text("Security Policy")
            .fontWeight(.medium)
            .font(Font.headline6)
            .opacity(0.87)
            .padding(.bottom, 16)
        Text("""
            Information from this server resides on a computer system funded by the National \
            Geospatial-Intelligence Agency. This system and related equipment are intended for the \
            communication, transmission, processing and storage of U.S. Government information. These \
            systems and equipment are subject to monitoring to ensure proper functioning, to protect \
            against improper or unauthorized use or access, and to verify their presence or performance \
            of applicable security features or procedures, and for other like purposes. Such monitoring \
            may result in the acquisition, recording and analysis of all data being communicated, \
            transmitted, processed or stored in this system by a user. If monitoring reveals evidence \
            of possible criminal activity, such evidence may be provided to law enforcement personnel. \
            Use of this system constitutes consent to such monitoring.
            """)
            .font(Font.body2)
            .opacity(0.6)
            .padding(.bottom, 32)
    }
    
    @ViewBuilder
    private func liabilityDisclaimer() -> some View {
        Text("Disclaimer of Liability")
            .fontWeight(.medium)
            .font(Font.headline6)
            .opacity(0.87)
            .padding(.bottom, 16)
        Text("""
            With respect to documents available from this server, neither the United States Government \
            nor the National Geospatial-Intelligence Agency Agency nor any of their employees, makes \
            any warranty, express or implied, including the warranties of merchantability and fitness \
            for a particular purpose, or assumes any legal liability or responsibility for the accuracy, \
            completeness, or usefulness of any information, apparatus, product, or process disclosed, \
            or represents that its use would not infringe privately owned rights.
            """)
            .font(Font.body2)
            .opacity(0.6)
            .padding(.bottom, 32)
    }
    
    @ViewBuilder
    private func endorsementDisclaimer() -> some View {
        Text("Disclaimer of Endorsement")
            .fontWeight(.medium)
            .font(Font.headline6)
            .opacity(0.87)
            .padding(.bottom, 16)
        Text("""
            Reference herein to any specific commercial products, process, or service by trade name, \
            trademark, manufacture, or otherwise, does not necessarily constitute or imply its \
            endorsement, recommendation, or favoring by the United States Government or the National \
            Geospatial-Intelligence Agency. The views and opinions of authors expressed herein do not \
            necessarily state or reflect those of the United States Government or the National \
            Geospatial-Intelligence Agency, and shall not be used for advertising or product endorsement \
            purposes.
            """)
            .font(Font.body2)
            .opacity(0.6)
            .padding(.bottom, 32)
    }
}
