# CustomVideoplyer

A fully custom video player framework built on top of `AVPlayer` with:

- Custom controls (no default AVPlayer controls)
- UIKit support
- SwiftUI support
- Live stream handling
- Dynamic quality, audio, subtitle, speed settings
- Full customization APIs for UI

This README is written in very simple English so even a beginner can follow it.

## Table of Contents

1. What This Framework Can Do
2. Add The Framework To Your App
3. UIKit Usage (Start Here)
4. UIKit Customization (All Options)
5. UIKit Callbacks and Delegates
6. SwiftUI Usage
7. Settings Behavior (Important)
8. Live Stream Behavior
9. Full API Cheat Sheet
10. Build `.xcframework` For Another Project
11. Troubleshooting

## 1. What This Framework Can Do

### Player UI Features

- Center controls: `10s back`, `play/pause`, `10s forward`
- Bottom controls:
  - Left: current time
  - Middle: seek slider
  - Right: total time + CC + Settings + Expand
- Video title (max 2 lines)
- Controls auto-hide while playing (after 5 seconds)
- Tap player surface to show/hide controls
- Loader while buffering
- Network error screen with center message + retry button

### Gesture Features

- Left vertical swipe: brightness up/down
- Right vertical swipe: volume up/down
- Pinch in fullscreen: zoom in/out

### Fullscreen and Layout

- Expand button toggles fullscreen landscape mode
- In fullscreen, extra custom buttons can be shown (landscape only)
- In fullscreen, top-right video scale button toggles:
  - `resizeAspect`
  - `resizeAspectFill`

### Settings Features

- Audio track selection (when available in stream)
- Subtitle selection (when available in stream)
- Quality selection
- Playback speed selection

Two settings UI modes:

- `isCustomSettingDesign = false`: iOS context menu mode
- `isCustomSettingDesign = true`: custom settings panel mode

Custom settings panel behavior:

- Opens over the player
- Pauses video when opened
- Resumes video when closed
- Has top-right close `xmark` button
- Scrolls for long option lists

### Live and Recovery Features

- Live mode detection:
  - Live without DVR
  - Live with DVR
- LIVE/GO LIVE button handling
- Retry strategy for stream failure
- Optional callback to fetch a fresh stream URL during retry

---

## 2. Add The Framework To Your App

You can add this framework in two common ways.

### Option A: Use Prebuilt `.xcframework` (recommended for reuse)

1. Build `CustomVideoplyer.xcframework` (commands in section 10).
2. Drag `CustomVideoplyer.xcframework` into your app project.
3. In your app target:
   - `General` -> `Frameworks, Libraries, and Embedded Content`
   - Ensure it is added as `Embed & Sign`
4. Import in code:

```swift
import CustomVideoplyer
```

### Option B: Add project as dependency (source-based)

1. Drag `CustomVideoplyer.xcodeproj` into your app workspace.
2. Link `CustomVideoplyer.framework` to your app target.
3. Import in code:

```swift
import CustomVideoplyer
```

---

## 3. UIKit Usage (Start Here)

UIKit section is first, as requested.

### Minimal UIKit Example

```swift
import UIKit
import AVFoundation
import CustomVideoplyer

final class PlayerViewController: UIViewController {
    private let player = AVPlayer()

    private lazy var playerView: CustomVideoPlayerView = {
        let view = CustomVideoPlayerView(player: player, videoGravity: .resizeAspect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(playerView)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            playerView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            playerView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9.0 / 16.0)
        ])

        let url = URL(string: "https://example.com/stream.m3u8")!
        playerView.setVideoURL(url)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.pause()
    }
}
```

---

## 4. UIKit Customization (All Options)

This section shows all important customization APIs.

### 4.1 Quality Control

Dynamic quality from stream:

```swift
playerView.qualityOptions = [] // empty = fetch from stream (HLS manifest)
```

Manual quality list (overrides dynamic list):

```swift
playerView.qualityOptions = [
    .auto,
    CustomVideoQualityOption(id: "360p", title: "360p", peakBitRate: 800_000),
    CustomVideoQualityOption(id: "480p", title: "480p", peakBitRate: 1_200_000),
    CustomVideoQualityOption(id: "720p", title: "720p", peakBitRate: 2_500_000)
]

playerView.setSelectedQuality(id: "720p")
```

### 4.2 Playback Speed

Allowed speed values are:

`0.5, 0.75, 1.0, 1.25, 1.5, 2.0`

```swift
playerView.setSelectedPlaybackSpeed(1.25)
```

### 4.3 Title

```swift
playerView.setPlayerTitle("My Video Title")
playerView.setPlayerTitleTextColor(.white)
playerView.setPlayerTitleFont(.systemFont(ofSize: 16, weight: .semibold))
```

### 4.4 Control Icons

You can replace icons using system images or asset images.

```swift
playerView.setControlImage(UIImage(systemName: "gobackward.10"), for: .backward)
playerView.setControlImage(UIImage(systemName: "play.fill"), for: .play)
playerView.setControlImage(UIImage(systemName: "pause.fill"), for: .pause)
playerView.setControlImage(UIImage(systemName: "goforward.10"), for: .forward)
playerView.setControlImage(UIImage(systemName: "captions.bubble"), for: .cc)
playerView.setControlImage(UIImage(systemName: "slider.horizontal.3"), for: .settings)
playerView.setControlImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .expand)
playerView.setControlImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .collapse)
playerView.setControlImage(UIImage(systemName: "aspectratio"), for: .videoScaleAspect)
playerView.setControlImage(UIImage(systemName: "aspectratio.fill"), for: .videoScaleAspectFill)
```

### 4.5 Control Colors

```swift
playerView.setControlTintColor(.white, for: .backward)
playerView.setControlTintColor(.systemYellow, for: .playPause)
playerView.setControlTintColor(.white, for: .forward)
playerView.setControlTintColor(.white, for: .cc)
playerView.setControlTintColor(.white, for: .settings)
playerView.setControlTintColor(.white, for: .expand)
playerView.setControlTintColor(.white, for: .videoScale)
```

Live text colors:

```swift
playerView.setLiveStatusTitleColors(atLiveEdge: .systemRed, goLive: .systemOrange)
```

### 4.6 Controls Overlay Gradient

```swift
playerView.setControlsGradientColors(
    top: .clear,
    bottom: UIColor.black.withAlphaComponent(0.88)
)
```

### 4.7 Seek Slider Style

```swift
playerView.setSeekSliderTrackColors(
    active: .systemGreen,
    inactive: UIColor.white.withAlphaComponent(0.3)
)

playerView.setSeekSliderThumbColor(.white)
// or use image:
playerView.setSeekSliderThumbImage(UIImage(systemName: "circle.fill"))
```

### 4.8 Settings Mode

Context menu mode:

```swift
playerView.isCustomSettingDesign = false
// or:
playerView.setCustomSettingDesignEnabled(false)
```

Custom panel mode:

```swift
playerView.isCustomSettingDesign = true
// or:
playerView.setCustomSettingDesignEnabled(true)
```

### 4.9 Settings Panel Full Appearance

```swift
let settingsStyle = CustomVideoPlayerSettingsAppearance(
    panelBackgroundColor: UIColor.black.withAlphaComponent(0.9),
    panelBorderColor: UIColor.white.withAlphaComponent(0.2),
    panelBorderWidth: 1,
    panelCornerRadius: 10,
    panelShadowColor: .black,
    panelShadowOpacity: 0.35,
    panelShadowRadius: 10,
    panelShadowOffset: CGSize(width: 0, height: 5),
    rowHeight: 42,
    rowSeparatorColor: UIColor.white.withAlphaComponent(0.12),
    sectionTitleTextColor: .white,
    sectionTitleFont: .systemFont(ofSize: 14, weight: .medium),
    sectionValueTextColor: UIColor.white.withAlphaComponent(0.88),
    sectionValueFont: .systemFont(ofSize: 13, weight: .regular),
    optionTextColor: UIColor.white.withAlphaComponent(0.86),
    optionSelectedTextColor: .white,
    optionFont: .systemFont(ofSize: 14, weight: .regular),
    optionSelectedFont: .systemFont(ofSize: 14, weight: .semibold),
    optionCheckmarkColor: .white,
    disclosureIndicatorColor: UIColor.white.withAlphaComponent(0.65),
    headerTextColor: .white,
    headerFont: .systemFont(ofSize: 14, weight: .semibold),
    backButtonTextColor: UIColor.white.withAlphaComponent(0.9),
    backButtonFont: .systemFont(ofSize: 13, weight: .medium),
    maxHeightRatio: 0.6
)

playerView.setSettingsAppearance(settingsStyle)
```

### 4.10 Settings Close Button Appearance

```swift
let closeStyle = CustomVideoPlayerSettingsCloseButtonAppearance(
    image: UIImage(systemName: "xmark"),
    tintColor: .white,
    backgroundColor: .clear,
    borderColor: .clear,
    borderWidth: 0,
    cornerRadius: 0,
    contentInsets: .zero,
    size: CGSize(width: 26, height: 26),
    topInset: 8,
    trailingInset: 8,
    contentTopSpacing: 8
)

playerView.setSettingsCloseButtonAppearance(closeStyle)
```

### 4.11 Landscape Custom Buttons

These buttons show only in fullscreen landscape and only in VOD mode.

```swift
let bookmark = UIButton(type: .system)
bookmark.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
bookmark.tintColor = .white
bookmark.addAction(UIAction { _ in
    print("Bookmark tapped")
}, for: .touchUpInside)

let share = UIButton(type: .system)
share.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
share.tintColor = .white
share.addAction(UIAction { _ in
    print("Share tapped")
}, for: .touchUpInside)

playerView.setLandscapeCustomButtons([bookmark, share])
```

---

## 5. UIKit Callbacks and Delegates

You can use closures or delegates.

### 5.1 Closure Callbacks

```swift
playerView.onExpandTapped = {
    print("Expand button tapped")
}

playerView.onControlsVisibilityChanged = { isVisible in
    print("Controls visible:", isVisible)
}

playerView.onPlaybackStatusChanged = { status in
    print("Playback status:", status)
}

playerView.onTimelineChanged = { timeline in
    print("current:", timeline.currentTime)
    print("total:", timeline.totalTime)
    print("isLive:", timeline.isLive)
    print("isAtLiveEdge:", timeline.isAtLiveEdge)
}

playerView.onPlaybackError = { error in
    print("Playback error:", error?.localizedDescription ?? "nil")
}

playerView.onStreamURLRefreshRequested = { completion in
    // Call your API and return a fresh stream URL.
    // If you do not have a new URL, return nil.
    completion(URL(string: "https://example.com/new_live.m3u8"))
}
```

Status handling example:

```swift
playerView.onPlaybackStatusChanged = { status in
    switch status {
    case .idle:
        print("Idle")
    case .playing:
        print("Playing")
    case .paused:
        print("Paused")
    case .buffering:
        print("Buffering")
    case .ended:
        print("Ended")
    case .failed:
        print("Failed")
    }
}
```

Timeline handling example:

```swift
playerView.onTimelineChanged = { timeline in
    let current = timeline.currentTime
    let total = timeline.totalTime
    let live = timeline.isLive
    let edge = timeline.isAtLiveEdge
    print(current, total, live, edge)
}
```

### 5.2 Delegate Callbacks

```swift
final class PlayerViewController: UIViewController,
                                 CustomVideoPlayerControlsVisibilityDelegate,
                                 CustomVideoPlayerPlaybackDelegate {

    // assign delegates
    func configureDelegates() {
        playerView.controlsVisibilityDelegate = self
        playerView.playbackDelegate = self
    }

    func customVideoPlayerView(_ playerView: CustomVideoPlayerView,
                               didChangeControlsVisibility isVisible: Bool) {
        print("Controls visibility:", isVisible)
    }

    func customVideoPlayerView(_ playerView: CustomVideoPlayerView,
                               didChangePlaybackStatus status: CustomVideoPlayerPlaybackStatus) {
        print("Status:", status)
    }

    func customVideoPlayerView(_ playerView: CustomVideoPlayerView,
                               didUpdateTimeline timeline: CustomVideoPlayerTimeline) {
        print("Timeline:", timeline.currentTime, timeline.totalTime)
    }

    func customVideoPlayerView(_ playerView: CustomVideoPlayerView,
                               didReceivePlaybackError error: Error?) {
        print("Error:", error?.localizedDescription ?? "nil")
    }
}
```

---

## 6. SwiftUI Usage

### 6.1 Minimal SwiftUI Example

```swift
import SwiftUI
import AVFoundation
import CustomVideoplyer

struct ContentView: View {
    @State private var player = AVPlayer(
        url: URL(string: "https://example.com/stream.m3u8")!
    )

    var body: some View {
        CustomVideoPlayerSwiftUIView(
            player: player,
            videoGravity: .resizeAspect
        )
        .frame(height: 230)
        .onAppear {
            player.play()
        }
    }
}
```

### 6.2 Fully Customized SwiftUI Example

```swift
import SwiftUI
import AVFoundation
import UIKit
import CustomVideoplyer

final class DemoVM: ObservableObject {
    let player = AVPlayer(url: URL(string: "https://example.com/stream.m3u8")!)

    let qualityOptions: [CustomVideoQualityOption] = []

    let controlIcons: [CustomVideoPlayerIconRole: UIImage] = [
        .play: UIImage(systemName: "play.fill")!,
        .pause: UIImage(systemName: "pause.fill")!,
        .settings: UIImage(systemName: "gearshape.fill")!
    ]

    let controlTintColors: [CustomVideoPlayerControlButton: UIColor] = [
        .playPause: .systemYellow,
        .settings: .white
    ]

    lazy var landscapeButtons: [UIButton] = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        b.tintColor = .white
        return [b]
    }()

    let settingsAppearance = CustomVideoPlayerSettingsAppearance()
    let closeAppearance = CustomVideoPlayerSettingsCloseButtonAppearance()
}

struct ContentView: View {
    @StateObject private var vm = DemoVM()

    var body: some View {
        CustomVideoPlayerSwiftUIView(
            player: vm.player,
            videoGravity: .resizeAspect,
            qualityOptions: vm.qualityOptions,
            landscapeCustomButtons: vm.landscapeButtons,
            controlIcons: vm.controlIcons,
            controlTintColors: vm.controlTintColors,
            liveAtEdgeColor: .systemRed,
            liveGoLiveColor: .systemOrange,
            playerTitle: "My Title",
            playerTitleColor: .white,
            playerTitleFont: .systemFont(ofSize: 15, weight: .semibold),
            controlsGradientTopColor: .clear,
            controlsGradientBottomColor: UIColor.black.withAlphaComponent(0.88),
            isCustomSettingDesign: true,
            settingsAppearance: vm.settingsAppearance,
            settingsCloseButtonAppearance: vm.closeAppearance,
            seekSliderActiveTrackColor: .white,
            seekSliderInactiveTrackColor: UIColor.white.withAlphaComponent(0.35),
            seekSliderThumbColor: .white,
            seekSliderThumbImage: nil,
            onExpandTapped: {
                print("Expand tapped")
            },
            onControlsVisibilityChanged: { visible in
                print("Controls visible:", visible)
            },
            onPlaybackStatusChanged: { status in
                print("Status:", status)
            },
            onTimelineChanged: { timeline in
                print("Timeline:", timeline)
            },
            onPlaybackError: { error in
                print("Error:", error?.localizedDescription ?? "nil")
            },
            onStreamURLRefreshRequested: { completion in
                completion(URL(string: "https://example.com/new_live.m3u8"))
            }
        )
        .frame(height: 230)
        .onAppear { vm.player.play() }
    }
}
```

---

## 7. Settings Behavior (Important)

### Settings mode switch

- `isCustomSettingDesign = false`  
  Uses context menus on settings and subtitle buttons.
  This uses native iOS menu look (not custom font/color API controlled).

- `isCustomSettingDesign = true`  
  Uses custom panel on top of player.

### Custom panel includes

- Sections: Audio, Subtitle, Quality, Speed
- Back navigation
- Selected option checkmark
- Top-right close `xmark`
- Auto-scroll for long lists

### Pause/Resume behavior

- Open panel -> player pauses
- Close panel -> player resumes
- If no setting changed, it still resumes

---

## 8. Live Stream Behavior

### Live mode detection

- VOD: normal timeline
- Live no DVR: no seek/back/forward
- Live DVR: seek and GO LIVE support

### LIVE button text

- At edge: `LIVE`
- Behind edge (DVR): `GO LIVE`

### Recovery behavior

- Buffering loader shown while waiting
- If network becomes unstable, an error overlay appears:
  - Message: `Network is unstable`
  - Retry button in center
- Retry can:
  - Reload same URL
  - Use `onStreamURLRefreshRequested` to get fresh URL

---

## 9. Full API Cheat Sheet

### Main class

- `CustomVideoPlayerView(player:videoGravity:)`
- `setVideoURL(_:)`
- `play()`
- `pause()`
- `stop()`

### Selection APIs

- `qualityOptions`
- `setSelectedQuality(id:)`
- `setSelectedPlaybackSpeed(_:)`

### Visual customization APIs

- `setControlImage(_:for:)`
- `setControlTintColor(_:for:)`
- `setLiveStatusTitleColors(atLiveEdge:goLive:)`
- `setPlayerTitle(_:)`
- `setPlayerTitleTextColor(_:)`
- `setPlayerTitleFont(_:)`
- `setControlsGradientColors(top:bottom:)`
- `setSeekSliderTrackColors(active:inactive:)`
- `setSeekSliderThumbColor(_:)`
- `setSeekSliderThumbImage(_:)`
- `setLandscapeCustomButtons(_:)`

### Settings customization APIs

- `isCustomSettingDesign`
- `setCustomSettingDesignEnabled(_:)`
- `setSettingsAppearance(_:)`
- `setSettingsCloseButtonAppearance(_:)`

### Callbacks

- `onExpandTapped`
- `onStreamURLRefreshRequested`
- `onControlsVisibilityChanged`
- `onPlaybackStatusChanged`
- `onTimelineChanged`
- `onPlaybackError`

### Delegates

- `CustomVideoPlayerControlsVisibilityDelegate`
- `CustomVideoPlayerPlaybackDelegate`

### Data models

- `CustomVideoQualityOption`
- `CustomVideoPlayerSettingsAppearance`
- `CustomVideoPlayerSettingsCloseButtonAppearance`
- `CustomVideoPlayerTimeline`
- `CustomVideoPlayerPlaybackStatus`

### Enums for customization

- `CustomVideoPlayerControlButton`
- `CustomVideoPlayerIconRole`

All control button keys:

```swift
let controlButtons: [CustomVideoPlayerControlButton] = [
    .backward,
    .playPause,
    .forward,
    .cc,
    .settings,
    .expand,
    .videoScale,
    .liveStatus
]
```

All icon roles:

```swift
let iconRoles: [CustomVideoPlayerIconRole] = [
    .backward,
    .play,
    .pause,
    .forward,
    .cc,
    .settings,
    .expand,
    .collapse,
    .videoScaleAspect,
    .videoScaleAspectFill
]
```

---

## 10. Build `.xcframework` For Another Project

Run from project root:

```bash
cd /Users/ishpreetsingh/Desktop/CustomVideoplyer
mkdir -p build .derivedData/archive_build

xcodebuild archive \
  -project CustomVideoplyer.xcodeproj \
  -scheme CustomVideoplyer \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/CustomVideoplyer-iOS \
  -derivedDataPath .derivedData/archive_build \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
  -project CustomVideoplyer.xcodeproj \
  -scheme CustomVideoplyer \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath build/CustomVideoplyer-Simulator \
  -derivedDataPath .derivedData/archive_build \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework build/CustomVideoplyer-iOS.xcarchive/Products/Library/Frameworks/CustomVideoplyer.framework \
  -framework build/CustomVideoplyer-Simulator.xcarchive/Products/Library/Frameworks/CustomVideoplyer.framework \
  -output build/CustomVideoplyer.xcframework
```

After this, share/use:

- `build/CustomVideoplyer.xcframework`

---

## 11. Troubleshooting

### Settings icon tap shows nothing

- If `isCustomSettingDesign = false`, settings open as context menu, not custom panel.
- If you want custom panel, set:

```swift
playerView.isCustomSettingDesign = true
```

### Audio or Subtitle shows unavailable

- Your media stream may not include alternate audio/subtitle tracks.

### Quality list is short

- Dynamic quality needs HLS variant info.
- For absolute control, pass manual `qualityOptions`.

### Expand button does not rotate

- Your app/screen must allow landscape orientation.

### SwiftUI build signing errors

- That is app target signing setup, not framework code issue.

---

If you want, I can also add:

- a `README_QuickStart.md` with only 2-minute setup
- animated GIF section for controls and settings behavior
- a reusable `PlayerViewModel` template for production apps
