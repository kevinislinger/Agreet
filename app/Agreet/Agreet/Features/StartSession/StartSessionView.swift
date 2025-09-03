import SwiftUI

struct StartSessionView: View {
    @StateObject private var viewModel = StartSessionViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @State private var showingShareSheet = false
    let onStartSwiping: (Session) -> Void

    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.themeBackground.edgesIgnoringSafeArea(.all)
                
                // Main content
                if viewModel.createdSession != nil {
                    successView
                } else {
                    formView
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeAccent))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationTitle("Start Session")
            .navigationBarTitleDisplayMode(.inline)

            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .task {
                await viewModel.loadCategories()
            }
        }
    }
    
    // Form for creating a new session
    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Category selection
                categorySelectionView
                
                // Quorum selection
                quorumSelectionView
                
                // Create button
                Button {
                    Task {
                        await viewModel.createSession()
                    }
                } label: {
                    Text("Create Session")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeAccent)
                        .cornerRadius(12)
                }
                .disabled(viewModel.selectedCategoryId == nil || viewModel.isLoading)
                .opacity(viewModel.selectedCategoryId == nil ? 0.6 : 1.0)
            }
            .padding()
        }
    }
    
    // Category selection grid
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Category")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.themeTextPrimary)
            
            if viewModel.categories.isEmpty && !viewModel.isLoading {
                Text("No categories available")
                    .foregroundColor(Color.themeTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 160))], spacing: 16) {
                    ForEach(viewModel.categories) { category in
                        CategoryCell(
                            category: category,
                            isSelected: viewModel.selectedCategoryId == category.id
                        ) {
                            viewModel.selectedCategoryId = category.id
                        }
                    }
                }
            }
        }
    }
    
    // Quorum selection slider
    private var quorumSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Participants Needed for Match")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.themeTextPrimary)
            
            Text("How many people need to agree on the same option?")
                .font(.system(size: 14))
                .foregroundColor(Color.themeTextSecondary)
            
            HStack {
                Text("\(viewModel.minQuorum)")
                    .foregroundColor(Color.themeTextSecondary)
                
                Slider(value: Binding(
                    get: { Double(viewModel.quorum) },
                    set: { viewModel.quorum = Int($0) }
                ), in: Double(viewModel.minQuorum)...Double(viewModel.maxQuorum), step: 1)
                .accentColor(Color.themeAccent)
                
                Text("\(viewModel.maxQuorum)")
                    .foregroundColor(Color.themeTextSecondary)
            }
            
            Text("\(viewModel.quorum) participants")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.themeAccent)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // Success view after session creation
    private var successView: some View {
        VStack(spacing: 24) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.themeAccent)
            
            Text("Session Created!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.themeTextPrimary)
            
            VStack(spacing: 12) {
                Text("Your invite code:")
                    .font(.system(size: 16))
                    .foregroundColor(Color.themeTextSecondary)
                
                Text(viewModel.inviteCode)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.themeAccent)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.themeAccent.opacity(0.1))
                    )
                    .onTapGesture {
                        UIPasteboard.general.string = viewModel.inviteCode
                    }
                
                Text("Tap code to copy")
                    .font(.system(size: 12))
                    .foregroundColor(Color.themeTextSecondary)
            }
            .padding(.vertical)
            
            VStack(spacing: 16) {
                Button {
                    showingShareSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Invite Code")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.themeAccent)
                    .cornerRadius(12)
                }
                
                Button {
                    if let session = viewModel.createdSession {
                        // Set the session as current in SessionService
                        SessionService.shared.setCurrentSession(session)
                        // Call the callback to open the session in the parent view
                        onStartSwiping(session)
                        // Dismiss this view
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Start Swiping")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.themeAccent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themeAccent, lineWidth: 2)
                        )
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [viewModel.inviteMessage])
        }

    }
}

// Helper component for category selection
struct CategoryCell: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.themeAccent : Color.themeCardBackground)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                Text(String(category.name.prefix(1)))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(isSelected ? Color.white : Color.themeAccent)
            }
            
            Text(category.name)
                .font(.system(size: 14))
                .foregroundColor(Color.themeTextPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(minWidth: 100)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// Helper for sharing content
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    StartSessionView { session in
        // Preview callback
    }
}
