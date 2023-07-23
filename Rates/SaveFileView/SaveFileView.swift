//
//  SaveFileView.swift
//  Rates
//
//  Created by Justin Bush on 7/19/23.
//

import SwiftUI

struct SaveFileView: View {
  @ObservedObject var sharedData: SharedData
  var onDismiss: () -> Void
  var onSave: (String, FileExtensions, FileExtensions) -> Void
  
  init(sharedData: SharedData, onDismiss: @escaping () -> Void, onSave: @escaping (String, FileExtensions, FileExtensions) -> Void) {
    self.sharedData = sharedData
    self.onDismiss = onDismiss
    self.onSave = onSave
    
    // Initialize outputUserFileName with the last path component of inputUserFile, without its file extension.
    sharedData.outputUserFileName = sharedData.inputUserFile?.deletingPathExtension().lastPathComponent ?? ""
  }
  
  var body: some View {
    VStack {
      HStack {
        Text("Save File As...")
          .bold()
      }
      .padding()
      HStack {
        TextField("Filename", text: $sharedData.outputUserFileName)
        Menu {
          ForEach(FileExtensions.all, id: \.self) { ext in
            Button("\(ext)") {
              sharedData.outputUserFileExtension = FileExtensions(rawValue: ext) ?? .csv
            }
          }
        } label: {
          Text("\(sharedData.outputUserFileExtension.stringWithPeriod)")
        }
        .frame(maxWidth: 80)
      }
      .padding()
      
      if sharedData.outputUserFileExtension.canBeExportedWithFormat.count > 1 {
          HStack {
            Text("Select Data Format:")
            Menu {
              ForEach(sharedData.outputUserFileExtension.canBeExportedWithFormat, id: \.self) { format in
                Button(format.fullFormatName) {
                  sharedData.outputUserFileFormat = format
                }
              }
            } label: {
              Text("\(sharedData.outputUserFileFormat.fullFormatName)")
            }
          }
          .padding(.bottom)
          .padding(.horizontal)
      }
      
      
      Divider()
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
      
      SaveFileOptionsView(sharedData: sharedData)
        .padding(.horizontal, 12)
      
      Divider()
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
      
      HStack {
        Button("Cancel") {
          onDismiss()
        }
        .keyboardShortcut(.cancelAction)
        .largeButton()
        
        Spacer()
        
        Button("Save...") {
          onSave(sharedData.outputUserFileName, sharedData.outputUserFileExtension, sharedData.outputUserFileFormat)
        }
        .keyboardShortcut(.defaultAction)
        .largeButton(foregroundColor: .white, backgroundColor: .accentColor, pressedColor: .accentColor.opacity(0.6))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
    }
    .padding()
    .frame(minWidth: 400)
  }
}

struct SaveFileOptionsView: View {
  @ObservedObject var sharedData: SharedData
  @State private var isExpanded: Bool = false
  
  var body: some View {
    VStack {
      Button(action: {
        withAnimation {
          isExpanded.toggle()
        }
      }) {
        HStack {
          Text("Save File Options")
            .bold()
          Spacer()
          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
        }
      }
      .buttonStyle(PlainButtonStyle())
      .frame(maxWidth: .infinity)
      
      if isExpanded {
        VStack {
          HStack {
            Toggle(isOn: $sharedData.saveAllInputDataToOutputFile) {
              Text("Include all hidden column data")
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()  // Push the Toggle and Text to the left
          }
          .padding(.top, 10)
          HStack {
            Toggle(isOn: $sharedData.saveRoundedConversionValuesToOutputFile) {
              Text("Round values for me (not recommended)")
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()  // Push the Toggle and Text to the left
          }
        }
        .transition(.opacity)
      }
    }
  }
}


//struct SaveFileView_Previews: PreviewProvider {
//  static var previews: some View {
//    SaveFileView()
//  }
//}
