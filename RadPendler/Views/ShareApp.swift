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

/// Das Weitersagen-Zeichen: Sprechblase mit Herz („erzähl’s weiter“), in allen Apps gleich.
/// Kein fertiges SF-Symbol — `bubble.left.fill` mit `heart.fill` darin. Die Blase nimmt die
/// Vordergrundfarbe (App-Farbe), das Herz ist weiß ausgespart.
struct TellFriendIcon: View {
    var size: CGFloat = 20
    var body: some View {
        Image(systemName: "bubble.left.fill")
            .font(.system(size: size))
            .overlay {
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: -size * 0.07)
            }
            .accessibilityHidden(true)
    }
}

/// Auf dem Startbildschirm erscheint das Weitersagen-Zeichen nur bei jedem fünften Start
/// (Wunsch des Nutzers, 24.11.2026) — immer erreichbar bleibt es oben in den Einstellungen.
/// `-tellFriendAlways YES` zeigt es immer (Store-Bilder, Vorführung).
enum TellFriendSchedule {
    static let every = 5
    static let key = "tellFriendLaunches"

    static func onHome(launch n: Int) -> Bool { n > 0 && n % every == 0 }

    /// Zählt diesen Start genau einmal je Prozess (beim ersten Zugriff) und sagt, ob das Zeichen heute kommt.
    static let showOnHome: Bool = {
        let d = UserDefaults.standard
        if d.bool(forKey: "tellFriendAlways") { return true }
        let n = d.integer(forKey: key) + 1
        d.set(n, forKey: key)
        return onHome(launch: n)
    }()
}
