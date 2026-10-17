# DeepSeek Balance — KDE Plasma 6 Widget

A Plasma 6 panel widget that shows your DeepSeek API account balance. It sends a
`GET https://api.deepseek.com/user/balance` request with the API key from the
widget settings and refreshes the value on a timer.

## Features

- Balance shown in the panel (compact) and in an expanded popup.
- Prefers the CNY balance; falls back to the first currency in `balance_infos`.
- Loading indicator, error states (`No API key set`, `Error <code>`, `Bad response`).
- Tooltip with the current balance or the error text.
- DeepSeek branding from the package itself — works right after installation.
- Configurable API key and refresh interval, no compilation required.

## Requirements

- KDE Plasma 6 (Qt 6).
- Network access to `api.deepseek.com`.
- An API key from [platform.deepseek.com](https://platform.deepseek.com).

## Installation

From the repository root:

```bash
kpackagetool6 -t Plasma/Applet -i .
```

> If your clone has a different directory name, use it instead of `.`:
> `kpackagetool6 -t Plasma/Applet -i your-clone-dir`

Install the icon for the widget list (optional — otherwise a generic icon is shown there):

```bash
install -Dm644 contents/icons/deepseek.svg \
    ~/.local/share/icons/hicolor/scalable/apps/deepseek.svg
```

Restart Plasma:

```bash
systemctl --user restart plasma-plasmashell.service
```

Then right-click the panel → **Add Widgets** → **DeepSeek Balance**.

If the package is already installed, `-i` will fail — use the update command below.

### Manual installation

Without `kpackagetool6`, copy the package contents without nesting:

```bash
DEST=~/.local/share/plasma/plasmoids/org.kde.plasma.deepseekbalance
mkdir -p "$DEST"
rsync -a --delete --exclude=.git ./ "$DEST"/
```

Note: `cp -r your-clone "$DEST"` with an existing `$DEST` creates
`$DEST/your-clone/` — don't do that.

## Updating after changes

```bash
kpackagetool6 -t Plasma/Applet -u .
systemctl --user restart plasma-plasmashell.service
```

Widget configuration survives a package update. If the icon changed, repeat the
`install -Dm644 ...` step above.

## Configuration

Right-click the widget → **Configure…** → **General**:

- **API key** — your `sk-...` key from platform.deepseek.com.
- **Refresh interval** — update period in minutes (default: 15).

The key is stored in plain text in
`~/.config/plasma-org.kde.plasma.desktop-appletsrc`; do not publish that file.

## How it works

`contents/ui/main.qml`:

- `refresh()` performs an `XMLHttpRequest` against the API and parses `balance_infos`.
- A `Timer` starts when `apiKey` is non-empty, fires the first request immediately
  (`triggeredOnStart`) and repeats every `refreshInterval` minutes.
- `Component.onCompleted` shows "No API key set" when no key is configured.
- The DeepSeek icon is referenced as a package file:
  `Qt.resolvedUrl("../icons/deepseek.svg")`.
- `metadata.json` → `"Icon": "deepseek"` is looked up in the icon theme; the
  widget list needs a copy of the SVG in `~/.local/share/icons/hicolor/scalable/apps/`.

## Package structure

- `metadata.json` — Plasma 6 package manifest (id, name, icon).
- `contents/ui/main.qml` — request logic and both representations (`PlasmoidItem`).
- `contents/ui/configGeneral.qml` — the General settings page.
- `contents/icons/deepseek.svg` — DeepSeek logo (Simple Icons, CC0; the logo is a
  trademark of DeepSeek).
- `contents/config/config.qml` — settings dialog page model.
- `contents/config/main.xml` — settings schema (KConfigXT).

## Development and debugging

There is no build step: Plasma loads the QML directly.

- After editing QML or `metadata.json`:
  `kpackagetool6 -t Plasma/Applet -u .` and restart plasmashell.
- Watch QML/request errors with:
  `journalctl --user -u plasma-plasmashell -f`
- Validate the manifest: `python3 -m json.tool metadata.json`.
- When adding a setting, update both `contents/config/main.xml`
  (`<entry name="..." .../>`) and the matching `cfg_...` alias in
  `configGeneral.qml`.
- The API key is never stored in the code — only in Plasma's configuration.

Quick checklist after changes:

| Changed | Do |
|---|---|
| `contents/ui/*.qml` | `kpackagetool6 -t Plasma/Applet -u .` + restart plasmashell |
| `metadata.json` | same |
| settings | keep `main.xml` and `configGeneral.qml` in sync, then update the package |
| `contents/icons/deepseek.svg` | copy the SVG to hicolor (see Installation), restart plasmashell |

## License

The widget code is free to use and modify. The DeepSeek logo is a trademark of
DeepSeek; the SVG comes from [Simple Icons](https://simpleicons.org) (CC0).
