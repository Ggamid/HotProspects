//
//  EditView.swift
//  HotProspects
//
//  Created by Gamıd Khalıdov on 30.06.2024.
//

import SwiftUI

struct EditView: View {
    
    @State var prospect: Prospect
    
    var body: some View {
        Form{
            TextField(prospect.name, text: $prospect.name)
            TextField(prospect.emailAddress, text: $prospect.emailAddress)
            Toggle("is Contacted", isOn: $prospect.isContacted)
            DatePicker("meet date", selection: $prospect.date)
        }
    }
}

#Preview {
    EditView(prospect: Prospect(name: "Emir", emailAddress: "Emir@gmail.com", isContacted: false))
}
