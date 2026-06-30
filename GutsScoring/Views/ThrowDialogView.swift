import SwiftUI

/// Full throw entry — port of Android `ThrowDialogFragment` + `throw_dialog.xml`.
struct ThrowDialogView: View {
    let state: GameUiState
    let onSubmit: (ThrowDialogForm) -> Void
    let onCancel: () -> Void

    @State private var form: ThrowDialogForm
    @State private var validationMessage: String?

    init(state: GameUiState, onSubmit: @escaping (ThrowDialogForm) -> Void, onCancel: @escaping () -> Void) {
        self.state = state
        self.onSubmit = onSubmit
        self.onCancel = onCancel
        _form = State(initialValue: Self.initialForm(for: state))
    }

    private var throwingTeam: String { state.activeThrowTeam }
    private var catchTeam: String {
        throwingTeam == state.teamLeft ? state.teamRight : state.teamLeft
    }
    private var throwingPlayers: [String] { state.teamPlayers[throwingTeam] ?? [] }
    private var catchPlayers: [String] { state.teamPlayers[catchTeam] ?? [] }

    var body: some View {
        NavigationStack {
            Form {
                if state.trackPlayerNames {
                    Section("Thrower (\(throwingTeam))") {
                        Picker("Who threw", selection: $form.throwerFullName) {
                            Text("Select player").tag("")
                            ForEach(throwingPlayers, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                    }
                }

                Section("Shot type") {
                    tagRow(options: ThrowConstants.shotTypes.map(\.label), selection: $form.shotTypeLabel)
                }

                Section("Result") {
                    Picker("Hand", selection: $form.rightHanded) {
                        Text("Right hand").tag(true)
                        Text("Left hand").tag(false)
                    }
                    .pickerStyle(.segmented)

                    tagRow(
                        options: ThrowConstants.results.map(\.label),
                        selection: Binding(
                            get: { labelForResultTag(form.resultTag) },
                            set: { newLabel in
                                if let tag = ThrowConstants.results.first(where: { $0.label == newLabel })?.tag {
                                    applyResultChange(tag)
                                }
                            }
                        )
                    )

                    if form.resultTag == "1" {
                        Toggle("Ace", isOn: $form.isAce)
                            .onChange(of: form.isAce) { _, _ in
                                if !form.isAce { form.hitIsThrowingTeamChoice = false }
                            }
                    }
                    if form.resultTag == "2" {
                        Toggle("Soak", isOn: $form.isSoak)
                            .onChange(of: form.isSoak) { _, soaked in
                                if soaked { form.hitPlayerFullName = form.catchPlayerFullName }
                            }
                    }
                    if form.resultTag == "3" {
                        Toggle("Vertical dump", isOn: $form.isVerticalDump)
                            .onChange(of: form.isVerticalDump) { _, vertical in
                                if vertical { form.dumpLocationTag = nil }
                            }
                    }
                    if ["1", "2", "3", "5"].contains(form.resultTag) {
                        Toggle("Observer", isOn: $form.isObserver)
                    }
                }

                if state.trackPlayerNames {
                    playerSections
                }

                if showsLineLocations {
                    Section("Line location") {
                        tagRow(
                            options: ThrowConstants.lineLocations.map(\.label),
                            selection: Binding(
                                get: { labelForLineTag(form.lineLocationTag) },
                                set: { label in
                                    form.lineLocationTag = ThrowConstants.lineLocations.first { $0.label == label }?.tag
                                }
                            )
                        )
                    }
                }

                if showsDumpLocations {
                    Section("Dump location") {
                        tagRow(
                            options: ThrowConstants.dumpLocations.map(\.label),
                            selection: Binding(
                                get: { labelForDumpTag(form.dumpLocationTag) },
                                set: { label in
                                    form.dumpLocationTag = ThrowConstants.dumpLocations.first { $0.label == label }?.tag
                                }
                            )
                        )
                    }
                }

                if showsSpots {
                    Section("Spot on disc") {
                        tagRow(
                            options: ThrowConstants.spots.map(\.label),
                            selection: Binding(
                                get: { labelForSpotTag(form.spotTag) },
                                set: { label in
                                    form.spotTag = ThrowConstants.spots.first { $0.label == label }?.tag
                                }
                            )
                        )
                    }
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("Throw — \(throwingTeam)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { submit() }
                }
            }
        }
    }

    @ViewBuilder
    private var playerSections: some View {
        switch form.resultTag {
        case "1":
            Section(form.isAce ? "Who aced" : "Who was hit first") {
                if form.isAce {
                    Picker("Hit player", selection: $form.hitPlayerFullName) {
                        Text("Select").tag("")
                        ForEach(catchPlayers, id: \.self) { Text($0).tag($0) }
                        Text(ThrowConstants.throwingTeamChoiceLabel).tag(ThrowConstants.throwingTeamChoiceLabel)
                    }
                    .onChange(of: form.hitPlayerFullName) { _, value in
                        form.hitIsThrowingTeamChoice = value == ThrowConstants.throwingTeamChoiceLabel
                    }
                } else {
                    Picker("Hit player", selection: $form.hitPlayerFullName) {
                        Text("Select").tag("")
                        ForEach(catchPlayers, id: \.self) { Text($0).tag($0) }
                    }
                }
            }
            if form.isAce && form.hitIsThrowingTeamChoice {
                Section("Who throws back") {
                    Picker("Throw back", selection: $form.catchPlayerFullName) {
                        Text("Select").tag("")
                        ForEach(catchPlayers, id: \.self) { Text($0).tag($0) }
                    }
                }
            }
        case "2":
            Section("Catcher (\(catchTeam))") {
                Picker("Who caught", selection: $form.catchPlayerFullName) {
                    Text("Select").tag("")
                    ForEach(catchPlayers, id: \.self) { Text($0).tag($0) }
                }
                .onChange(of: form.catchPlayerFullName) { _, value in
                    if form.isSoak { form.hitPlayerFullName = value }
                }
            }
            Section("Who was hit first") {
                Picker("Hit player", selection: $form.hitPlayerFullName) {
                    Text("Select").tag("")
                    ForEach(catchPlayers, id: \.self) { Text($0).tag($0) }
                }
                .disabled(form.isSoak)
            }
        default:
            EmptyView()
        }
    }

    private var showsLineLocations: Bool { ["1", "2"].contains(form.resultTag) }
    private var showsDumpLocations: Bool { form.resultTag == "3" && !form.isVerticalDump }
    private var showsSpots: Bool { ["1", "2"].contains(form.resultTag) }

    private func applyResultChange(_ tag: String) {
        form.resultTag = tag
        if tag != "2" { form.isSoak = false }
        if tag != "1" { form.isAce = false; form.hitIsThrowingTeamChoice = false }
        if tag != "3" { form.isVerticalDump = false }
        if !["1", "2"].contains(tag) {
            form.lineLocationTag = nil
            form.spotTag = nil
        }
        if tag != "3" { form.dumpLocationTag = nil }
        if !["1", "2"].contains(tag) {
            form.hitPlayerFullName = ""
            form.catchPlayerFullName = ""
        }
    }

    private func submit() {
        do {
            _ = try ThrowEventBuilder.buildEvent(form: form, state: state)
            validationMessage = nil
            onSubmit(form)
        } catch {
            validationMessage = error.localizedDescription
        }
    }

    private func tagRow(options: [String], selection: Binding<String>) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button(option) { selection.wrappedValue = option }
                    .buttonStyle(.bordered)
                    .tint(selection.wrappedValue == option ? .accentColor : .secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func labelForResultTag(_ tag: String) -> String {
        ThrowConstants.results.first { $0.tag == tag }?.label ?? ""
    }

    private func labelForLineTag(_ tag: String?) -> String {
        guard let tag else { return "" }
        return ThrowConstants.lineLocations.first { $0.tag == tag }?.label ?? ""
    }

    private func labelForDumpTag(_ tag: String?) -> String {
        guard let tag else { return "" }
        return ThrowConstants.dumpLocations.first { $0.tag == tag }?.label ?? ""
    }

    private func labelForSpotTag(_ tag: String?) -> String {
        guard let tag else { return "" }
        return ThrowConstants.spots.first { $0.tag == tag }?.label ?? ""
    }

    private static func initialForm(for state: GameUiState) -> ThrowDialogForm {
        var form = ThrowDialogForm()
        if let preferred = state.preferredNextThrowerLastName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !preferred.isEmpty,
           let players = state.teamPlayers[state.activeThrowTeam] {
            form.throwerFullName = players.first { PlayerNameFormat.compactNameMatches(fullName: $0, compact: preferred) } ?? ""
        }
        return form
    }
}

/// Simple wrapping row for tag buttons.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}
