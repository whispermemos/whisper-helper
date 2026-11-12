# Whisper Memos Helper

A small Mac app for [Whisper Memos](https://whispermemos.com). Record a voice memo on
your iPhone, and a Claude Code session starts on your Mac in the folder you named.

### [⬇️ Download Whisper Memos Helper for Mac](https://github.com/whispermemos/whisper-helper/releases/latest/download/WhisperMemosHelper.dmg)

Requires macOS 15 or later. Open the DMG and drag Whisper Memos Helper into Applications.
The app keeps itself up to date.

The source is public so you can see exactly what the app does on your Mac.

## How it works

1. You connect the Mac once. The helper shows a QR code, you scan it with your iPhone
   and tap Allow in Whisper Memos.
2. You add the folders Claude Code may work in. Only the folder names are sent to
   Whisper Memos, never the paths or your files.
3. You record a memo, for example "In Foodmark, add a dark mode toggle to settings."
   Whisper Memos picks the folder from its name and sends the memo to your Mac.
4. The helper starts a Claude Code session in that folder and opens it in the Claude
   desktop app.

If the Mac is off, the memo waits for up to a day.

## What to know before you use it

- **Sessions run with permissions bypassed.** Claude Code can run commands in the folder
  you named without asking. Only connect an account you trust: whoever can record memos
  on that account can run prompts on this Mac.
- **Scanning the QR code does nothing by itself.** Only tapping Allow in the iPhone app
  connects the Mac. The helper shows the email of the connected account.
- **You can disconnect any time**, in Settings > Account, or from the iPhone app.
- **Instructions.** The helper adds a short text after every memo. By default it asks
  Claude to work in a new git worktree and open a pull request when the folder is a git
  repository, and to change the files directly when it is not. What the memo itself
  says always wins. You can rewrite the text in Settings > Instructions.

## Requirements

- macOS 15 or later.
- The [Claude Code](https://claude.com/claude-code) command line tool (`claude`) and the
  Claude desktop app, both signed in.
- Whisper Memos on your iPhone.

## Build and run

```bash
swift test
scripts/build-app.sh      # makes "build/Whisper Memos Helper.app"
open "build/Whisper Memos Helper.app"
```

The only dependency is [Sparkle](https://sparkle-project.org/), for updates. Swift fetches
it by itself. To sign with your own Developer ID:

```bash
SIGN_IDENTITY="Developer ID Application" scripts/build-app.sh
```

To point the helper at a local copy of the server, start it with
`WHISPER_MEMOS_WORKER_URL=http://localhost:8787`.

## Releases

Updates use [Sparkle 2](https://sparkle-project.org/). The app reads a signed feed from
[GitHub Pages](https://whispermemos.github.io/whisper-helper/appcast.xml) (the `gh-pages`
branch) and downloads the DMG from GitHub Releases. Development builds (`swift run`)
never start the updater.

To release, bump `CFBundleShortVersionString` and `CFBundleVersion` in `Info.plist`,
commit and push, then:

```bash
scripts/release.sh            # optional: build the notarized DMG and the feed locally
```

```bash
scripts/release.sh --publish  # build, create the GitHub release, push the feed
```

`--publish` must run from a clean `main` that matches `origin/main`, and refuses a
version that is already released. The feed keeps the three most recent versions.

No secrets are in this repository. The release Mac needs a Developer ID certificate,
notarization credentials in the Keychain (see `scripts/release.sh`), a signed-in `gh`
CLI, and the Sparkle private key in the login Keychain under the account
`whisper-helper`. Its public half is `SUPublicEDKey` in `Info.plist`. To move the key to
another Mac, export it with Sparkle's `generate_keys --account whisper-helper -x <file>`
and import it with `-f <file>`. Keep that file out of the repository. Sparkle's tools are
in `.build/artifacts/sparkle/Sparkle/bin/` after the first build.

## Where things are

- `Sources/WhisperMemosHelper/Pairing/` connecting the Mac with the QR code.
- `Sources/WhisperMemosHelper/Worker/` the one WebSocket to the Whisper Memos server.
- `Sources/WhisperMemosHelper/Jobs/` the folders, and starting a Claude Code session.
- `Sources/WhisperMemosHelper/Views/` the main window, onboarding and Settings.
- `Sources/WhisperMemosHelper/Updates/` checking for updates with Sparkle.
- `docs/protocol.md` every message the helper sends and receives.

## Notes for developers

- **Starting a session takes two commands.** `claude --desktop` cannot take a prompt. So
  the helper first runs `claude -p "<memo>" --session-id <id> --permission-mode
  bypassPermissions --name "<memo title>"` with no window, then opens that session with
  `script -q /dev/null claude --desktop --resume <id>`. `--desktop` refuses to run
  without a terminal, so `script` fakes one. The session shows up in the desktop app
  after the first turn ends.
- **`claude` wants a lowercase session id.** Swift's `UUID().uuidString` is uppercase.
- **PATH.** A Mac app started from Finder cannot find `claude` or `git`. Every command
  goes through `$SHELL -lic`, with values passed as `"$1"`, `"$2"`, so memo text is
  never pasted into shell code. Fish is not supported.
- **A job runs at most once.** The helper confirms a job before it runs anything, and the
  server forgets it then. A helper that quits mid-run loses that job.
- **Liquid Glass.** `swift build` stamps the binary as built with the macOS 15 SDK, and
  macOS then draws the app in the old look. `scripts/build-app.sh` fixes the stamp with
  `vtool`. A plain `swift run` still shows the old look, and has no Settings tab pictures.
- **"Start at login"** only works from the built app, not from `swift run`.

## License

MIT. See [LICENSE](LICENSE).
