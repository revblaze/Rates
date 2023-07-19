//
//  SaveFileView.swift
//  Rates
//
//  Created by Justin Bush on 7/19/23.
//

import SwiftUI

struct SaveFileView: View {
  @ObservedObject var sharedData: SharedData
  @State private var outputUserFileName: String
  @State private var outputUserFileExtension: FileExtensions?
  @State private var outputUserFileFormat: FileExtensions?
  var onDismiss: () -> Void
  var onSave: (String, FileExtensions, FileExtensions) -> Void
  
  init(sharedData: SharedData, onDismiss: @escaping () -> Void, onSave: @escaping (String, FileExtensions, FileExtensions) -> Void) {
    self.sharedData = sharedData
    self.onDismiss = onDismiss
    self.onSave = onSave
    
    _outputUserFileName = State(initialValue: sharedData.inputUserFile?.deletingPathExtension().lastPathComponent ?? "")
    _outputUserFileExtension = State(initialValue: sharedData.inputUserFileExtension)
    _outputUserFileFormat = State(initialValue: sharedData.inputUserFileExtension?.canBeExportedWithFormat.first)
  }
  
  var body: some View {
    VStack {
      HStack {
        Text("Save File As...")
        TextField("Filename", text: $outputUserFileName)
        Menu {
          ForEach(FileExtensions.all, id: \.self) { ext in
            Button("\(ext)") {
              outputUserFileExtension = FileExtensions(rawValue: ext)
            }
          }
        } label: {
          Text("\(outputUserFileExtension?.stringWithPeriod ?? ".csv")")
        }
      }
      
      if outputUserFileExtension?.canBeExportedWithFormat.count ?? 0 > 1 {
        HStack {
          Text("Select Data Format:")
          Menu {
            ForEach(outputUserFileExtension?.canBeExportedWithFormat ?? [], id: \.self) { format in
              Button(format.fullFormatName) {
                outputUserFileFormat = format
              }
            }
          } label: {
            Text("\(outputUserFileFormat?.fullFormatName ?? "")")
          }
        }
      }
      
      HStack {
        Button("Cancel") {
          onDismiss()
        }
        
        Button("Save...") {
          onSave(outputUserFileName, outputUserFileExtension, outputUserFileFormat)
        }
      }
    }
    .padding()
  }
}

//struct SaveFileView_Previews: PreviewProvider {
//  static var previews: some View {
//    SaveFileView()
//  }
//}
