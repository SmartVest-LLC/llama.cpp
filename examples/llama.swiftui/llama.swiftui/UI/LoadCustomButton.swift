import SwiftUI
import UniformTypeIdentifiers

struct LoadCustomButton: View {
    @ObservedObject private var llamaState: LlamaState
    @State private var showFileImporter = false

    init(llamaState: LlamaState) {
        self.llamaState = llamaState
    }

    var body: some View {
        VStack {
            Button(action: {
                showFileImporter = true
            }) {
                Text("Load Custom Model")
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [UTType(filenameExtension: "gguf", conformingTo: .data)!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(files):
                for file in files {
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { continue }

                    do {
                        try llamaState.loadModel(modelUrl: file.absoluteURL)
                    } catch let err {
                        print("Error: \(err.localizedDescription)")
                    }

                    file.stopAccessingSecurityScopedResource()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}
