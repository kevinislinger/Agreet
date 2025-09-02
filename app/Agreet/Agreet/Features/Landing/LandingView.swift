import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    @State private var showingStartSession = false
    @State private var showingJoinSession = false
    @State private var showingSettings = false
    @State private var selectedSession: Session?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    openSessionsSection
                    
                    closedSessionsSection
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.horizontal)
            }
            .refreshable {
                await viewModel.fetchSessions()
            }
            .navigationTitle("Agreet")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
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
                            .font(.title2)
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
    
    private var openSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Open Sessions")
                .font(Font.system(size: 20, weight: .bold))
                .foregroundColor(Color.themeTextPrimary)
                .padding(.horizontal, 4)
            
            if viewModel.openSessions.isEmpty {
                emptyStateView(message: "No open sessions", icon: "tray.fill")
            } else {
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Completed Sessions")
                .font(Font.system(size: 20, weight: .bold))
                .foregroundColor(Color.themeTextPrimary)
                .padding(.horizontal, 4)
            
            if viewModel.closedSessions.isEmpty {
                emptyStateView(message: "No completed sessions", icon: "tray.fill")
            } else {
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
    

    
    private func emptyStateView(message: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(Font.system(size: 40))
                .foregroundColor(Color.themeTextSecondary.opacity(0.5))
            
            Text(message)
                .font(Font.system(size: 16))
                .foregroundColor(Color.themeTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(Color.themeCardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    
    @MainActor
    private func refreshSessions() async {
        await viewModel.fetchSessions()
    }
}
