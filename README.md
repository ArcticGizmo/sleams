<h1 align="center">Otter</h1>
<p align="center">
 <img src="./src/icon.png" width="150" />
</p>

## Hands-off Slack status for your calls

You hop on a Teams call. Someone messages you on Slack expecting a quick reply, not realising you're heads-down in a meeting. You forget to set your status — every time.

Otter fixes that. It quietly watches for when you're on a Microsoft Teams call and sets your Slack status for you, then clears it the moment the call ends. No buttons to press, no habit to build. It just works in the background from your system tray.

<br>

## Why you'll like it

- **Completely hands-off** — your Slack status updates itself when a call starts and clears when it ends.
- **Make it yours** — pick the status text and emoji you want, with a live preview so you see exactly how it'll look in Slack.
- **Out of your way** — Otter lives in the system tray. Left-click the icon to open settings; right-click for a quick menu showing your current status.
- **Snooze when you need to** — heading into back-to-back calls you'd rather not broadcast? Pause Otter for a while from the tray.
- **Quiet if you want it** — keep the "call detected" notification on, or turn it off.
- **Starts with Windows** — flip one toggle and Otter is ready every time you log in.
- **Stays current** — check for updates from the tray menu or the About page; Otter downloads the latest release and restarts itself.
- **Your data stays yours** — Otter connects to Slack with a secure sign-in and stores everything locally on your machine. It only watches _whether_ Teams is using your microphone, never what's said on the call.

## Installing

```powershell
irm https://raw.githubusercontent.com/ArcticGizmo/otter/main/install.ps1 | iex
```

That's the whole install. No admin rights (it lands in `%LocalAppData%\Otter\`), a Start Menu shortcut and a normal uninstaller in Settings → Apps, and Otter starts in the tray when it's done.

What the script does, in order: resolves the latest release, fetches `SHA256SUMS.txt` and `Otter-win-Setup.exe`, **checks the installer against the manifest and deletes it rather than run it on any mismatch**, then hands off to the installer. It's [`install.ps1`](install.ps1) in this repo — read it before piping it into your shell, the same as you should with any installer.

Because PowerShell rather than a browser does the downloading, nothing is tagged with the mark-of-the-web — so this route never hits the **"Windows protected your PC"** SmartScreen wall.

Pin a version instead of taking the latest:

```powershell
$env:OTTER_VERSION = '0.3.1'; irm https://raw.githubusercontent.com/ArcticGizmo/otter/main/install.ps1 | iex
```

### Installer by hand

Prefer to click things: download `Otter-win-Setup.exe` from the [latest release](https://github.com/ArcticGizmo/otter/releases/latest) and run it. Identical install, identical self-updates.

A browser download _is_ tagged with the mark-of-the-web, so SmartScreen shows the blue **"Windows protected your PC"** dialog — click **More info → Run anyway**, or use the one-liner above and skip it. To check the download against the release's `SHA256SUMS.txt` yourself:

```powershell
$want = (Select-String -Path SHA256SUMS.txt -Pattern 'Otter-win-Setup.exe').Line.Split()[0]
(Get-FileHash Otter-win-Setup.exe -Algorithm SHA256).Hash -eq $want   # True
```

## Getting started

1. Install Otter with the one-liner above — it appears in your system tray.
2. Left-click the tray icon to open settings.
3. On **Getting started**, click **Connect** to sign in to your Slack workspace.
4. Set the status text and emoji you'd like under **Status** (or keep the defaults).
5. That's it. Next time you join a Teams call, your Slack status updates itself.

> **Note:** Otter is a Windows app and currently detects Microsoft Teams calls. Support for more apps and signals is on the way.

## Updating

Right-click the system tray icon and select **Check for updates…** — or open **Settings → About** and click **Check for updates**.

If a newer release is available, Otter downloads it and restarts automatically. Otherwise it lets you know you're already on the latest version.

---

## Development

Otter is a .NET Windows tray application (C# / WinForms).

Run it locally:

```
dotnet run --project src\Otter.csproj
```

See [CHANGELOG.md](CHANGELOG.md) for release history.
