import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    @State private var showingStartSession = false
    @State private var showingJoinSession = false
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Navigate to settings
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.themeAccent)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                bottomButtons
            }
            .sheet(isPresented: $showingStartSession) {
                StartSessionView()
            }
            .onChange(of: showingStartSession) { oldValue, newValue in
                // When sheet is dismissed (changes from true to false), refresh sessions
                if oldValue && !newValue {
                    Task {
                        await viewModel.fetchSessions()
                    }
                }
            }
            .sheet(isPresented: $showingJoinSession) {
                JoinSessionView()
            }
            .onChange(of: showingJoinSession) { oldValue, newValue in
                // When sheet is dismissed (changes from true to false), refresh sessions
                if oldValue && !newValue {
                    Task {
                        await viewModel.fetchSessions()
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                // Detail view for session will go here
                if session.status == "open" {
                    // SwipeDeck view
                    Text("Swipe Deck for \(session.id)")
                } else {
                    // Results view
                    Text("Results for \(session.id)")
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
    
    private var bottomButtons: some View {
        HStack(spacing: 16) {
            Button {
                showingStartSession = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Start Session")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeAccent)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button {
                showingJoinSession = true
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus.fill")
                    Text("Join Session")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeSecondary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(Color.themeBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: -4)
        )
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
