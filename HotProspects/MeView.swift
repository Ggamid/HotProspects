//
//  MeView.swift
//  HotProspects
//
//  Created by Gamıd Khalıdov on 28.06.2024.
//
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    
    @AppStorage("name") private var name = "Anonymous"
    @AppStorage("emailAddress") private var emailAddress = "you@yoursite.com"
    
    var context = CIContext()
    var filter = CIFilter.qrCodeGenerator()
    
    @State var qrCode = UIImage()
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
                .font(.title)
                .textContentType(.name)
            
            TextField("Email", text: $emailAddress)
                .font(.title2)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            
            Image(uiImage: qrCode)
                .interpolation(.none)
                .resizable()
                .scaledToFill()
                .contextMenu(menuItems: {
                    ShareLink(item: Image(uiImage: qrCode), preview: SharePreview("My QR code", image: Image(uiImage: qrCode)))
                })
        }
        .onAppear(perform: updateCode)
        .onChange(of: emailAddress, updateCode)
        .onChange(of: name, updateCode)
    }
    
    func updateCode() {
        qrCode = generateQRCode(frome: "\(name)\n\(emailAddress)")
    }
    
    func generateQRCode(frome string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    MeView()
}
