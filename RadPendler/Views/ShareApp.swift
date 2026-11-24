import SwiftUI
import UIKit

/// „Weitersagen“: Store-Link mit eigenem Text über das Teilen-Menü von iOS —
/// Nachrichten (SMS/iMessage), WhatsApp, Mail, Kopieren, was installiert ist.
/// Eigenständig, damit dieselbe Datei in jede App passt; nur `ShareInvite.app` anpassen.
struct ShareInvite: Equatable {
    let appName: String
    let appStoreID: String?
    /// Ersatz, solange die App keine Store-Id hat (Supportseite).
    let fallbackURL: URL
    let defaultText: String

    static var app: ShareInvite {
        ShareInvite(
            appName: "RadPendler",
            appStoreID: "6813997635",
            fallbackURL: URL(string: "https://deepskyplan.github.io/radpendler-app/")!,
            defaultText: L("Schau dir RadPendler an: plant deinen Weg zur Arbeit mit Rad, Bahn oder beidem — mit Ampeln, Regen und echter Abfahrtszeit.")
        )
    }

    static let textKey = "shareInviteText"

    var url: URL {
        appStoreID.flatMap { URL(string: "https://apps.apple.com/app/id\($0)") } ?? fallbackURL
    }

    /// Was geteilt wird: der Text, darunter der Link. Ein einziger String, weil
    /// WhatsApp und manche Mail-Apps von mehreren Teilen nur einen übernehmen.
    func message(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? url.absoluteString : "\(t)\n\(url.absoluteString)"
    }
}

struct ShareAppView: View {
    var invite = ShareInvite.app
    @Environment(\.dismiss) private var dismiss
    @AppStorage(ShareInvite.textKey) private var text = ""
    @State private var copied = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $text).frame(minHeight: 110)
                    if text != invite.defaultText {
                        Button(L("Vorschlag wiederherstellen")) { text = invite.defaultText }
                    }
                } header: { Text(L("Dein Text")) } footer: {
                    Text(L("Der Link zum App Store kommt automatisch darunter."))
                }
                Section(L("Link")) {
                    Text(invite.url.absoluteString).font(.footnote).foregroundStyle(.secondary).textSelection(.enabled)
                    Button {
                        UIPasteboard.general.url = invite.url
                        copied = true
                    } label: { Label(copied ? L("Kopiert") : L("Nur Link kopieren"), systemImage: copied ? "checkmark" : "link") }
                }
                Section {
                    ShareLink(item: invite.message(text), preview: SharePreview(invite.appName)) {
                        Label(L("Senden über Nachrichten, WhatsApp, Mail …"), systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(L("%@ weitersagen", invite.appName))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(L("Fertig")) { dismiss() } } }
            .onAppear { if text.isEmpty { text = invite.defaultText } }
        }
    }
}
