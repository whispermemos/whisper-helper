import SwiftUI

/*
 * The Instructions tab of Settings: one large text box with the instructions the
 * helper adds after every memo (see MemoInstructions), and a button to bring back
 * the default text.
 */
struct InstructionsSettingsView: View {
    @AppStorage(DefaultsKey.memoInstructions) private var memoInstructions = MemoInstructions.defaultText

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Added after every memo before Claude Code starts. Leave empty to send the memo as it is.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            TextEditor(text: $memoInstructions)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(.background, in: .rect(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.separator)
                }

            HStack {
                Spacer()
                Button("Reset to Default") {
                    memoInstructions = MemoInstructions.defaultText
                }
                .disabled(memoInstructions == MemoInstructions.defaultText)
            }
        }
        .padding(20)
    }
}
