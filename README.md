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

Open `http://localhost:8000/crowd-call.html?selftest=1` for 19 inline checks covering IRC prefixes, tags, PING, welcome messages, command matching, vote changes, unavailable choices, closed polls, story validation, winner selection, ties, no-vote defaults, round advancement, and vote resets. The result appears on the card and `document.documentElement.dataset.selftest` is `passed` or `failed`. This mode does not connect to Twitch or start the timer. Add `demo=1` to preview alongside the checks.

Each username has one vote. Commands are case-insensitive and must be the first token (`!B extra words` works; `hello !b` does not). A later valid vote moves that viewer's vote. Percentages are rounded independently and may total 99% or 101%.

The poll starts when the page loads, including while connecting. Disconnections retry every three seconds without resetting votes or the deadline. Votes received after the deadline are ignored. At zero, winners are highlighted and the result stays visible for ten seconds, then the card fades away. Ties show all tied options; a poll with no votes says so. Refresh to run another round.

## Story Mode

Chat steers linked decisions automatically. The built-in heist has three decision rounds and six endings. Each winner stays highlighted for three seconds with “Chat chose”, then its `next` node begins with fresh votes. Ties randomly select one of the tied leaders; no votes picks option a. Endings and the full breadcrumb path stay on screen until refresh.

OBS example (Browser source, 1920 × 1080):

`http://localhost:8000/crowd-call.html?channel=yourchannel&story=heist&t=20`

Offline preview, including directly from a `file:///…/crowd-call.html` URL:

`crowd-call.html?story=heist&demo=1&t=3`

| Parameter | Story behavior |
| --- | --- |
| `story=heist` | Embedded story; no fetch needed, works from file URLs and OBS |
| `story=<url-to-json>` | Loads a custom HTTP(S) JSON story; URL-encode the full URL |
| `t` | Seconds per round; default and invalid-value fallback is 20 in Story Mode |
| `demo=1` | Fast simulated chat votes every 180 ms; no channel needed |
| `channel` | Required for live chat, as in single-poll mode |
| `q`, `a`, `b`, `c` | Ignored in Story Mode; story nodes supply the question and labels |

The embedded story matches [stories/heist.json](stories/heist.json). Custom stories use this format:

```json
{
  "title": "The Getaway",
  "start": "exit",
  "nodes": {
    "exit": {
      "q": "How do we escape?",
      "options": [
        { "label": "Speedboat", "next": "water" },
        { "label": "Rooftops", "next": "sky" }
      ]
    },
    "water": { "end": "Gone with the tide." },
    "sky": { "end": "Above the city. Beyond their reach." }
  }
}
```

Each decision needs a nonempty question and one to three options, mapped in order to `!a`, `!b`, `!c`. Labels and `next` IDs must be nonempty, and every ID must exist. Ending nodes contain nonempty `end` text instead of question/options. Stories must be finite: cycles are rejected. Progress shows the current round and the longest remaining route; for unequal branches, the total can shorten after a choice.

Remote JSON must permit browser CORS access (including the `null` origin when loading the HTML from a file). For example, while serving this directory, use `story=http%3A%2F%2Flocalhost%3A8000%2Fstories%2Fheist.json`. Fetch, JSON, and validation errors appear on the card. Refresh restarts the story. Omitting `story` preserves the original single-poll behavior, including its 60-second default and ten-second result display.

## License

MIT — see [LICENSE](LICENSE).
