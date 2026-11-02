# Crowd Call

A dependency-free Twitch chat voting overlay for OBS. The page background is transparent; the 720px card sits 32px from the bottom-left at 1080p.

## OBS setup

1. Serve this folder with a static web server, for example `python3 -m http.server 8000`, or upload `crowd-call.html` to a static host.
2. In OBS, add a **Browser** source. Set width to **1920** and height to **1080**.
3. Enter a URL such as:
   `http://localhost:8000/crowd-call.html?channel=yourchannel&q=Where%20next%3F&a=Forest&b=Castle&c=Caves&t=60`
4. Keep the source visible while voting. Viewers type `!a`, `!b`, or `!c` in the channel's chat.
5. Refresh the browser source to start a new poll. OBS options that refresh or shut down the source when hidden will restart the poll when it loads again.

Use the URL field rather than OBS's Local file checkbox so query parameters can be supplied. No login, OAuth token, installation, or build is needed. Live mode needs internet access to Twitch's WebSocket endpoint.

## URL parameters

| Parameter | Meaning | Default |
| --- | --- | --- |
| `channel` | Required in live mode; Twitch channel name (optional leading `#`, URL-encoded as `%23`) | None |
| `q` | Question | What should we do next? |
| `a` | First option | Option A |
| `b` | Second option | Option B |
| `c` | Optional third option; omitted when empty | None |
| `t` | Positive number of seconds; invalid values fall back to 60 | 60 |
| `demo` | `1` simulates votes offline; no channel required | Off |
| `selftest` | `1` runs inline parser/vote tests offline and displays results | Off |

URL-encode labels and questions, especially `&`, `#`, `+`, and `?`. Content is displayed as text, never interpreted as HTML.

## Preview and test

Open `crowd-call.html?demo=1&t=15` through the local server, or append that query to a `file:///…/crowd-call.html` URL for an offline preview.

Open `http://localhost:8000/crowd-call.html?selftest=1` for nine inline checks covering IRC prefixes, tags, PING, welcome messages, command matching, vote changes, unavailable choices, and closed polls. The result appears on the card and `document.documentElement.dataset.selftest` is `passed` or `failed`. This mode does not connect to Twitch or start the timer. Add `demo=1` to preview alongside the checks.

Each username has one vote. Commands are case-insensitive and must be the first token (`!B extra words` works; `hello !b` does not). A later valid vote moves that viewer's vote. Percentages are rounded independently and may total 99% or 101%.

The poll starts when the page loads, including while connecting. Disconnections retry every three seconds without resetting votes or the deadline. Votes received after the deadline are ignored. At zero, winners are highlighted and the result stays visible for ten seconds, then the card fades away. Ties show all tied options; a poll with no votes says so. Refresh to run another round.

## License

MIT — see [LICENSE](LICENSE).
