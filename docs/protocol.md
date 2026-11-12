# Protocol

Every message between the helper and the Whisper Memos server. The server is at
`https://claude-code-workers.whispermemos.com`. All bodies are JSON.

## Connecting the Mac

The helper makes up a `code`: 32 random bytes, base64url, no padding. It opens a
WebSocket at `GET /api/pairings/{code}/socket?name=<Mac name>` and shows a QR code of
`https://app.whispermemos.com/claude-code/connect?code={code}`. It then gets one text
message and the socket closes:

- `{"type":"approved","key":"…","email":"…"}`: the phone tapped Allow. The key goes in
  the keychain.
- `{"type":"denied"}`.
- Close code `4000` with no message: the 5 minutes ran out. The helper makes a new code.

## The working socket

`GET /api/socket` with `Authorization: Bearer <key>`. HTTP `401` means the key is no
longer valid: the helper forgets it and shows the QR code again.

The helper sends:

- `{"type":"folders","folders":["whisper-memos","growbase"]}` right after connecting and
  whenever the list changes. Names only, never paths.
- `{"type":"ack","jobId":"…"}` as soon as a job arrives, before running anything.
- `{"type":"remove"}` to disconnect this Mac for good.
- The plain text `ping` every 30 seconds. The answer is the plain text `pong`.

The server sends:

- `{"type":"job","id":"…","prompt":"…","folder":"whisper-memos","title":"Login bug fix"}`.
  `prompt` is the memo's text. `title` is `null` when the memo has none.
- Close code `4001`: this Mac was removed. The helper forgets the key and shows the QR
  code again.
