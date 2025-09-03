import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    @State private var showingStartSession = false
    @State private var showingJoinSession = false
    @State private var showingSettings = false
    @State private var selectedSession: Session?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.themeBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                                            // Welcome section
                    welcomeSection
                    
                    // Open sessions
                        if !viewModel.openSessions.isEmpty {
                            openSessionsSection
                        }
                        
                        // Closed sessions
                        if !viewModel.closedSessions.isEmpty {
                            closedSessionsSection
                        }
                        
                        // Empty state
                        if viewModel.openSessions.isEmpty && viewModel.closedSessions.isEmpty && !viewModel.isLoading {
                            emptyStateSection
                        }
                        
                        if viewModel.isLoading {
                            loadingSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .refreshable {
                await viewModel.fetchSessions()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.themeAccent)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingStartSession = true
                        }) {
                            Label("Start Session", systemImage: "plus.circle.fill")
                        }
                        
                        Button(action: {
                            showingJoinSession = true
                        }) {
                            Label("Join Session", systemImage: "person.badge.plus.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.themeAccent)
                    }
                }
            }
            .sheet(isPresented: $showingStartSession) {
                StartSessionView()
            }
            .onChange(of: showingStartSession) { oldValue, newValue in
                // When sheet is dismissed (changes from true to false), refresh sessions
                if oldValue && !newValue {
                    Task {
                        await viewModel.fetchSessions()
                        
                        // Don't auto-open sessions - let user choose which session to open
                        // The StartSessionView should handle navigation to the created session if needed
                    }
                }
            }
            .sheet(isPresented: $showingJoinSession) {
                JoinSessionView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onChange(of: showingJoinSession) { oldValue, newValue in
                // When sheet is dismissed (changes from true to false), refresh sessions
                if oldValue && !newValue {
                    Task {
                        await viewModel.fetchSessions()
                        
                        // Don't auto-open sessions - let user choose which session to open
                        // The JoinSessionView should handle navigation to the joined session if needed
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                // Detail view for session will go here
                if session.status == "open" {
                    // SwipeDeck view
                    SwipeDeckView(session: session)
                } else if session.status == "matched" {
                    // Results view for matched session
                    if let matchedOptionId = session.matchedOptionId {
                        // Fetch the matched option and show results
                        AsyncResultsView(session: session, matchedOptionId: matchedOptionId)
                    } else {
                        // Fallback if no matched option ID
                        Text("Results for \(session.id)")
                    }
                } else {
                    // Results view for closed session (no match)
                    ClosedSessionView(session: session)
                }
            }
            .onChange(of: selectedSession) { oldValue, newValue in
                // When SwipeDeckView is dismissed (selectedSession becomes nil), refresh sessions
                if oldValue != nil && newValue == nil {
                    Task {
                        await viewModel.fetchSessions()
                    }
                }
            }
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
            .onAppear {
                // Refresh sessions whenever the view appears
                Task {
                    await viewModel.fetchSessions()
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var welcomeSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("Welcome to ")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.themeTextPrimary)
                
                GradientText(
                    text: "Agreet",
                    colors: [Color.themeAccent, Color.themeSecondary]
                )
                .font(.system(size: 28, weight: .bold))
            }
            .multilineTextAlignment(.center)
            
            Text("Build consensus together")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.themeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    

    
    private var openSessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Sessions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.openSessions.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.themeAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.themeAccent.opacity(0.1))
                    .cornerRadius(12)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.openSessions) { session in
                    Button {
                        selectedSession = session
                    } label: {
                        SessionCell(session: session)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var closedSessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Completed Sessions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.themeTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.closedSessions.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.themeTextSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.themeTextSecondary.opacity(0.1))
                    .cornerRadius(12)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.closedSessions) { session in
                    Button {
                        selectedSession = session
                    } label: {
                        SessionCell(session: session)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.themeCardBackground)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "tray.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color.themeTextSecondary.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No Sessions Yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.themeTextPrimary)
                
                Text("Start your first session or join an existing one to begin building consensus")
                    .font(.system(size: 16))
                    .foregroundColor(Color.themeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color.themeCardBackground)
        .cornerRadius(20)
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: Color.themeAccent))
            
            Text("Loading sessions...")
                .font(.system(size: 16))
                .foregroundColor(Color.themeTextSecondary)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Actions
    
    @MainActor
    private func refreshSessions() async {
        await viewModel.fetchSessions()
    }
}

// MARK: - Gradient Text View

struct GradientText: View {
    let text: String
    let colors: [Color]
    
    var body: some View {
        Text(text)
            .foregroundStyle(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}
