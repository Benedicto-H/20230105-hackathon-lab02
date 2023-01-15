import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @EnvironmentObject var vocabularyNetworkManager: VocabularyNetworkManager
    @EnvironmentObject var authManager: AuthManager
    @State private var searchText = ""
    
    var filteredVoca: [Vocabulary] {
        if searchText.isEmpty {
            return vocabularyNetworkManager.vocabularies.filter { $0.isApproved }
        } else {
            return vocabularyNetworkManager.vocabularies.filter {
                $0.word.contains(searchText) && $0.isApproved }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "737DFE"), Color(hex: "FFCAC9")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    Spacer(minLength: 10)
                    
                    LazyVStack(spacing: 15) {
                        ForEach(filteredVoca.shuffled(), id: \.self) { vocabulary in
                            
                            ListCell(vocabulary: vocabulary)
                        }
                    }
                }
                .refreshable {
                    Task {
                        await vocabularyNetworkManager.requestVocabularyList()
                    }
                }
                .modifier(ToolbarModifier(searchText: $searchText))
            }
            .onAppear {
                Task {
                    await vocabularyNetworkManager.requestVocabularyList()

                    await vocabularyNetworkManager.countLikes()
                }
            }
        }
        .tint(.black)
    }
}

struct ToolbarModifier: ViewModifier {
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var vocabularyNetworkManager: VocabularyNetworkManager
    
    @Binding var searchText: String

    
    func body(content: Content) -> some View {
        content
            .toolbar {
                HStack {
                    SearchBar(searchText: $searchText)
                        .frame(width: 240)
                    NavigationLink {
                        QuizView()
                    } label: {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color(hex: "292929"))
                    }
                    NavigationLink {
                        SlangRegistrationView()
                    } label: {
                        Image(systemName: "plus.rectangle.portrait.fill")
                            .foregroundColor(Color(hex: "292929"))
                    }

                    //                    Button {
                    //                        isSignedIn = authManager.state == .signedOut ? false : true
                    //                        showingSignInAlert = !isSignedIn
                    //                    } label: {
                    //                        Image(systemName: "plus.rectangle.portrait.fill")
                    //                    }
                    //                    .navigationDestination(isPresented: $isSignedIn) {
                    //                        SlangRegistrationView()
                    //                    }
                    //                    .alert("로그인이 필요합니다", isPresented: $showingSignInAlert) {
                    //                        Button {
                    //                            print("취소")
                    //                        } label: {
                    //                            Text("취소")
                    //                        }
                    //                        Button {
                    //                            isShowingSheet = true
                    //                        } label: {
                    //                            Text("로그인")
                    //                        }
                    //                    }
                    //                    .sheet(isPresented: $isShowingSheet) {
                    //                        LoginView(isShowingSheet: $isShowingSheet)
                    //                    }

                    NavigationLink {
                        MyPageView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(Color(hex: "292929"))
                            .font(.title3)
                    }
                }
                .foregroundColor(.black)
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthManager())
            .environmentObject(VocabularyNetworkManager())
    }
}
