# RaveSpin: An XR DJ Controller Prototype with On-Device Track Management, FFmpeg Waveform Generation, Beat Phase Alignment, and Real-Time Mixer Effects

*César Hannin*  
School of Computer Science, Technological University Dublin  
*(Supervisor: Bryan Duggan)*  

**Keywords**: XR, DJ, real-time audio, Android, beat sync

## Abstract

RaveSpin is an experimental XR DJ application that explores how familiar DJ controller workflows can be translated into a portable, headset-first system without requiring physical hardware. The project targets standalone Quest/Android devices and is implemented in Godot 4.6 (OpenXR), with desktop OpenXR planned as a later step. The prototype recreates key parts of a two-deck workflow: track selection and loading, waveform browsing, tempo adjustment, beat-aligned playback, mixer-style gain staging, EQ, and performance effects. Since the project’s early conception, RaveSpin has progressed from basic audio playback and early XR interaction to a functional two-channel audio routing model with per-channel processing, improved hand-based interaction with 2D UI surfaces in 3D, and a local track import pipeline with persistent storage. MP3/OGG/WAV are supported, and waveforms can be generated from audio using FFmpeg. The system currently targets a maximum audio latency of 20 ms to leave headroom for stacked effects on constrained hardware. This paper presents the motivation, system design, implementation details, current limitations, and an outlook on evaluation and future work.

## 1. Introduction

DJing remains strongly tied to physical controllers and mixers. Even “entry-level” setups represent a non-trivial cost, and transporting equipment is inconvenient. At the same time, standalone XR headsets have matured to the point where portable, spatially-present musical interfaces are feasible, especially when interaction can be performed using tracked hands rather than external controllers.

RaveSpin is my attempt to treat an XR headset as a *portable DJ environment* rather than as a novelty visualization. The main goal is not to replace professional hardware, but to recreate enough of the core workflow that a user can practice beatmatching and mixing concepts, experiment with transitions, and develop muscle memory for common controls—while remaining fully self-contained.

Figures referenced in this paper are stored in `Documentation/Assets/` in the project repository.

This work is also motivated by the broader Linux Audio community because it sits at the intersection of:

- **Real-time audio constraints**: latency, buffering, timing drift, and the practical realities of synchronising playback.
- **Interface design for performance**: tactile metaphors, error tolerance, and “fast to operate” controls.
- **Portable, reproducible toolchains**: using open tooling and an engine with OpenXR support, with a Quest/Android-first target and desktop OpenXR planned.

### 1.1. Contributions

The current prototype contributes:

- **Local track import + persistence**: user-added audio can be stored under `user://` and referenced as part of track metadata.
- **Waveform preview workflow**: support for associating waveform textures with tracks (with a path-based convention).
- **Beat phase alignment (“beat sync”)**: a practical phase-match approach that aligns the *within-beat* position of one track to another, with latency-aware correction.
- **Mixer-style processing**: crossfader and per-channel faders, trim, EQ, colour FX (low-pass/high-pass) and a “Beat FX level” control applied through a bus/effect layout.
- **Improved hand interaction with 2D UI in 3D**: “touch” emulation for 2D UI surfaces, with optional scroll gestures and an optional long-press → double-click mode.

### 1.2. Scope and non-goals (current)

RaveSpin is currently focused on core DJ actions rather than a complete “DJ ecosystem”. For example:

- I am not attempting to implement a full Rekordbox/Serato-style library analysis pipeline (key detection, beatgrid editing, cue points, etc.) yet.
- Networked multi-user “WLAN sessions” are considered a longer-term direction rather than a feature that is ready to be evaluated today.
- The prototype is primarily validated through iterative development and device testing rather than controlled user studies so far.

## 2. System overview

At a high level, RaveSpin is composed of:

- **XR scene and interaction layer**: a 3D environment containing controller-like UI and interaction surfaces, targeting Quest/Android (tested on Meta Quest 3S) using Godot 4.6 + OpenXR.
- **2D UI in 3D (LibreBox)**: a 2D interface (lists, dialogs, buttons, sliders) rendered to a viewport and displayed as a 3D surface.
- **Audio engine**: two (and optionally more) deck players routed through an audio bus layout, enabling per-channel processing and crossfading.
- **Track metadata system**: a `Song` resource representing track metadata and storage for the playable audio reference and any precomputed waveform.

### 2.1. Track representation

Each track is represented as a `Song` resource containing typical DJ metadata (title, artist, BPM, key, etc.) and either:

- a packed `AudioStream` (for bundled/sample tracks), or
- a persisted on-device file path (for user-imported tracks).

In addition, the `Song` resource can store an associated waveform texture, which allows the UI to display waveform previews without requiring live analysis in the audio thread.

**Figure 1:** RaveSpin in use (in-headset view). *(See `Documentation/Assets/Screenshot of Ravespin in use.png`.)*  
**Figure 2:** RaveSpin in use with FX selection visible. *(See `Documentation/Assets/Screenshot of Ravespin in use - FX Select visable.png`.)*  
**Figure 3:** Add Track menu. *(See `Documentation/Assets/Screenshot of RaveSpin Add-Track menu.png`.)*

## 3. Implementation details

### 3.0. Platform target and distribution

RaveSpin is currently built and tested for **Quest/Android**. A desktop OpenXR build is explicitly planned as a later feature; this should be relatively straightforward because Godot already provides an OpenXR plugin and the project is structured around OpenXR-compatible workflows.

The project is intended to be **open source**, and the expectation is that anyone can clone the repository and adapt it for their own experiments and devices.

### 3.1. Local track import and persistence

A key update since the project’s early phase is a working “Add Local Track” path that allows selecting an audio file, copying it into an application-owned directory under `user://`, and storing its path in track metadata. This is important because it turns RaveSpin from a demo with fixed sample content into an application that can hold a personal library on the device. At the time of writing, **MP3, OGG, and WAV** are supported for local import.

From an engineering perspective, persisting tracks under `user://` avoids fragile absolute paths and makes the project’s storage model portable between devices.

### 3.2. Waveform previews

Waveform previews are handled as an explicit asset associated with a track, and can be generated from audio files using **FFmpeg**. The current workflow also supports a convention where a waveform image is expected alongside the audio file (e.g., with a `_WAVEFORM.png` suffix), allowing a lightweight lookup step during track setup.

This decision is a deliberate trade-off: waveform generation is expensive and can hitch on mobile/standalone hardware. By allowing precomputed waveforms (and later caching), the UI can remain responsive while still providing a core DJ affordance.

### 3.3. Audio routing and mixer processing

RaveSpin’s audio design is structured around a bus/effect layout that mirrors the mental model of DJ mixers:

- **Per-channel input buses** for decks (left/right, and optional alternate decks).
- **Crossfade and channel faders** controlling per-bus output levels.
- **Trim (gain) staging**, applied as an amplify stage.
- **EQ** (low/mid/high) controlling per-band gain.
- **Colour FX** implemented as low-pass/high-pass filters that are enabled based on knob position.
- **Beat FX “level”** acting as a global intensity control for whichever beat effect is active (prototype-style).

This design allows “mixer thinking” to remain consistent: each deck is a channel with an ordered chain of processing steps.

#### Latency target

On standalone hardware, I currently target a **maximum audio latency of 20 ms**, raised from the engine default (15 ms), in order to give the device more room to breathe when multiple effects are stacked.

### 3.4. Beat synchronisation by phase alignment

Beat sync in RaveSpin is implemented as a *phase alignment* mechanism rather than a full beatgrid/tempo map system. When syncing one track to another, the system computes:

- the beat duration in *stream seconds* from the track’s metadata BPM (\(60 / \mathrm{BPM}\)),
- the reference track’s position inside its current beat (a \(0..1\) phase ratio),
- a target seek position for the other track that preserves its own “beat index” but matches the reference phase.

To reduce the perceptual mismatch between “playback position” and “what the listener hears”, the code applies a latency correction derived from the audio server’s last-mix timing and reported output latency.

This approach is intentionally constrained: it aligns *within-beat phase* without snapping songs to the same musical bar or attempting to correct long-term drift. In practice, it still produces an audible “tightening” effect that is useful for an educational/prototype tool, while being implementable with the timing information available in-engine.

### 3.5. Hand-based interaction with 2D UI in 3D

A major usability blocker in early iterations was reliable interaction with 2D UI elements rendered into 3D. RaveSpin introduces a dedicated “hand touch” layer that:

- detects hand/finger overlap with a thin collider in front of the UI plane,
- converts finger world-space position into viewport coordinates,
- injects synthetic mouse events into the 2D viewport to drive existing UI logic.

To improve practical usability, the interaction layer also supports:

- **click cooldown** to prevent unintended rapid repeats,
- optional **long-press → double click** for UI elements that expect double-click behaviour,
- **scroll-by-pose** where pinch/fist combined with hand movement drives scroll wheel events.

This is not meant to be the final interaction design, but it has proven effective enough to enable real iteration on the DJ workflow itself rather than fighting input plumbing.

## 4. Current status and limitations

RaveSpin has reached a point where a user can:

- load tracks into two decks,
- see waveforms (when available),
- play/pause, adjust tempo within a limited range, and engage beat phase alignment,
- use a crossfader and per-channel faders,
- apply trim/EQ and colour FX in real time,
- interact with UI reliably using hand tracking.

However, several limitations remain:

- **Timing correctness and drift**: phase alignment is sensitive to metadata BPM accuracy and does not fully solve drift for long mixes.
- **Robust analysis**: BPM/key detection, beatgrids, and cue points are not yet implemented as a complete pipeline.
- **Effect “polish”**: some effects are functional but still “janky” and need tuning to feel musical and predictable.
- **Performance/latency characterisation**: while the system targets a maximum audio latency of 20 ms, it still needs systematic measurement and reporting of end-to-end timing and hitching sources under realistic headset loads.
- **Portability story**: the current implementation is Quest/Android-first; desktop OpenXR is planned but not yet validated for a Linux Audio audience.

## 5. Evaluation plan (towards LAC presentation)

To make the work reviewable beyond “it feels okay”, my next step is to evaluate RaveSpin along two axes:

1. **Interaction performance**: time-to-complete basic tasks (load track, start playback, adjust tempo, engage sync), error rates (misclicks, accidental repeats), and subjective workload.
2. **Audio/timing performance**: timing error when syncing (phase offset before/after sync), stability over time, and end-to-end latency as experienced by the user.

Even a small pilot study (e.g., DJs vs non-DJs) combined with instrumented timing logs would materially strengthen the claims in this paper.

## 6. Conclusions and future work

RaveSpin demonstrates that a standalone XR headset can host a workable, controller-inspired DJ workflow when audio routing, timing, and interaction design are treated as first-class constraints. The prototype has evolved from early “proof of concept” playback into a system with persistent track management, waveform affordances, practical beat phase alignment, and mixer-like processing.

The next major milestones are:

- improving correctness and musicality of beat synchronisation (including drift handling),
- making FFmpeg-based waveform generation and caching robust and device-friendly,
- expanding track analysis and library features,
- validating interaction/audio performance on desktop Linux (PCVR) to better align with the Linux Audio Conference audience.

## Acknowledgements

I would like to thank my supervisor, **Bryan Duggan**, for guidance and for the original inspiration behind the project direction.

## References

[1] M. Conrad, D. Kablitz, and S. Schumann, “Learning effectiveness of immersive virtual reality in education and training: A systematic review of findings,” *Comput. Educ. X Real.*, vol. 4, p. 100053, Jan. 2024, doi: 10.1016/j.cexr.2024.100053.  
[2] Pioneer DJ, “Pioneer DJ DDJ-FLX10: All specifications & features,” accessed Nov. 23, 2025. [Online]. Available: `https://www.pioneerdj.com/en/product/controller/ddj-flx10/black/specifications/`  
[3] MusicRadar, “Pioneer DDJ-FLX4 review,” accessed Nov. 23, 2025. [Online]. Available: `https://www.musicradar.com/reviews/pioneer-ddj-flx4-review`  
[4] Pioneer DJ, “Tribe XR partners with AlphaTheta Corporation…,” accessed Oct. 12, 2025. [Online]. Available: `https://www.pioneerdj.com/en-us/news/2021/tribe-xr-partners-with-alphatheta-corporation/`  
[5] Steam, “Tribe XR | DJ Academy,” accessed Oct. 12, 2025. [Online]. Available: `https://store.steampowered.com/app/877850/Tribe_XR__DJ_Academy/`  
[6] CDM Create Digital Music, “Ableton Live in VR lets you play as a disembodied Daft Punk head,” accessed Oct. 12, 2025. [Online]. Available: `https://cdm.link/newswires/ableton-live-vr-lets-play-disembodied-daft-punk-head/`  
[7] DJ TechTools, “DJ Audio Routing 303: Analogue Mixers, Guitar Pedals, and External Soundcards,” accessed Nov. 23, 2025. [Online]. Available: `https://djtechtools.com/2015/06/28/audio-routing-101-analog-mixers-guitar-pedals-and-external-soundcards/`  

