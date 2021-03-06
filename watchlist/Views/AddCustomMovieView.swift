//
//  AddCustomMovieView.swift
//  watchlist
//
//  Created by Reed Metzler-Gilbertz on 9/5/20.
//  Copyright © 2020 Reed Metzler-Gilbertz. All rights reserved.
//

import SwiftUI

extension Date {
  var year: Int { Calendar.current.component(.year, from: self) }
}

struct TextView: UIViewRepresentable {
  
  typealias UIViewType = UITextView
  var configuration = { (view: UIViewType) in }
  
  func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
    UIViewType()
  }
  
  func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
    configuration(uiView)
  }
}

class TextBindingManager: ObservableObject {
  @Published var text = "" {
    didSet {
      if text.count > characterLimit && oldValue.count <= characterLimit {
        text = oldValue
      }
    }
  }
  let characterLimit: Int
  
  init(limit: Int = 5){
    characterLimit = limit
  }
}

struct AddCustomMovieView: View {
  @Environment(\.managedObjectContext) var context
  @Binding var showView: Bool
  let years = Array(Array(Date().year-200...Date().year+1).reversed())
  @State var releaseYearIndex: Int = 0
  @ObservedObject var titleTextManager = TextBindingManager(limit: 40)
  @ObservedObject var runtimeTextManager = TextBindingManager(limit: 15)
  @ObservedObject var ratedTextManager = TextBindingManager(limit: 5)
  @ObservedObject var descriptionTextManager = TextBindingManager(limit: 200)
  
  var body: some View {
    Form {
      TextField("Title", text: $titleTextManager.text)
      TextField("Runtime (minutes)", text: $runtimeTextManager.text).keyboardType(.numberPad)
      TextField("Age Rating", text: $ratedTextManager.text)
      Picker(selection: self.$releaseYearIndex, label: Text("Release Year")) {
        ForEach(0..<self.years.count, id: \.self) { index in
          Text(String(self.years[index]))
        }
      }
      TextField("Description", text: $descriptionTextManager.text)
    }
    .navigationBarTitle("Custom Movie")
    .navigationBarItems(trailing: Button("Save") {
      _ = SavedMovie(context: self.context,
          movie: MovieDetailed(
            title: self.titleTextManager.text,
            year: String(self.years[self.releaseYearIndex]),
            rated: (self.ratedTextManager.text == "" ? nil : self.ratedTextManager.text),
            runtime: (self.runtimeTextManager.text == "" ? nil : self.runtimeTextManager.text + " min"),
            plot: (self.descriptionTextManager.text == "" ? nil : self.descriptionTextManager.text)
          )
        )
      
      (UIApplication.shared.delegate as! AppDelegate).saveContext()
      
      self.showView.toggle()
    }.disabled(self.titleTextManager.text.count == 0))
  }
  
}

//struct AddCustomMovieView_Previews: PreviewProvider {
//  static var previews: some View {
//    AddCustomMovieView()
//  }
//}
