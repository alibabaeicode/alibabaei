# CLAUDE.md — Margin build guide

> Place this file at the **root of the repo** as `CLAUDE.md`. It is the single source of truth for building Margin. When it conflicts with older scattered notes, **this file and the Decision Log win.** Read this fully before writing code.

---

## 0. What Margin is (read first)

Margin is a quiet iOS app for **small moments of self-awareness mid-workday.** Not meditation, not a mood-disorder tracker. Its purpose, in the team's own words:

> **Help a person know, without judgment, what state they're in while absorbed in their role — so they can come to its reasons later.**

A person stops for ~20 seconds, takes one breath, names what's here (pleasant *or* unpleasant), optionally says more, and sees themselves from a small distance. Over time these moments form a gentle **map of their days** — which Margin mirrors back, never diagnoses.

The product's whole differentiation is **coherence**: the feeling, the interaction, and the visuals all flow from this one idea. Protect that. When unsure, choose the calmer, plainer, less clever option.

---

## 1. Non-negotiables (guardrails — never break these)

1. **Mirror, not judge.** Margin *shows* patterns in plain, balanced language ("you tend to pass your afternoons more charged"). It **never** interprets, diagnoses, or pathologizes ("you're anxious/depressed," "this is unhealthy"). The user assigns meaning; we never do.
2. **Never invent a pattern.** An insight is shown **only when it is literally true** of the data and passes a sufficiency gate. No manufactured "insights" to drive engagement. Quiet weeks are correct and fine. Honesty over retention.
3. **Valence-balanced everywhere.** Pleasant, neutral, and hard states are equally native. Vocabulary, prompts, nudges, seed/empty states, and the Field must hold the light as readily as the heavy. No tension/problem bias anywhere.
4. **No streaks, no shame, no gamification.** No points, no "don't break your streak," no nagging. Missing days is part of a rhythm, never a failure.
5. **Anonymous, on-device, no account in v1.** No login required, ever, to use Margin. No server, no upload. Everything is stored and computed on the device.
6. **Not therapy.** No clinical claims. Include calm crisis-language handling and a clear "not a medical/therapy tool" framing.
7. **Warm through restraint.** The voice is a calm, trusted adult — never cute, never infantilizing, never twee. Never assume something is wrong.

If a feature would violate any of these, stop and flag it rather than shipping it.

---

## 2. Tech decisions (locked for v1)

- **Platform:** iOS only. **SwiftUI.** (Android is deferred; do not build for it yet.)
- **Storage:** on-device only. Use SwiftData (or Core Data / Codable-to-disk if simpler) for the Moment records. No network layer, no backend, no analytics SDK that phones home.
- **No account / no auth in v1.** (An *optional backup* login may be added later — see §6.7 — but it is never required and is gated by external logistics.)
- **Insight engine:** **deterministic, on-device, no LLM on the hot path.** Free text (the Note) is **never read by any model** in v1. (A future v2 may have an LLM *rephrase already-verified facts* and read free text only with explicit consent — not now.)
- **No scale/infra work.** On-device means ~zero per-user cost. Don't build servers, sync, or accounts speculatively.
- **Target:** a v1 good enough for **TestFlight** with the team + a few testers. Polished feel, small surface.

*Operational note (not a coding task, but real): publishing to TestFlight/App Store needs an Apple Developer account, which is a known external blocker for this team. It runs as a parallel workstream; don't let the build wait on it, but know it gates release and the optional backup login.*

---

## 3. The data model

A single core record, plus derived rhythm. Keep it minimal.

```
Moment
  id: UUID
  timestamp: Date              // when it was recorded
  band: Band?                  // coarse state; nil allowed (see note)
  word: String                 // the chosen or written-in word ("calm", "on edge", "it feels like…")
  bodyLocation: String?        // optional ("jaw", "chest", … or "not sure")
  note: String?                // optional free text — NEVER fed to any model in v1

enum Band { activated, weighted, settled }
  // activated = high-arousal/charged    (warm clay tone)
  // weighted  = low-energy/heavy        (indigo tone)
  // settled   = at ease / calm / light  (gold tone)
  // band is nil when the user wrote their own word (we can't infer it) — handle nil gracefully:
  //   nil contributes to frequency/granularity but not to band-specific rules; render with a neutral tone.
```

**Derived (computed on the fly, not stored as truth):**
- *Rhythm map* — counts of when moments happen across the day (used for both insight and notification timing: one signal, two uses).
- *Standing insight* — the current honest sentence (see §5).

Privacy: provide **export** and **delete-everything** (local wipe). Deleting removes all moments and any derived state.

---

## 4. The screens to build (and their order)

Build in this order. The canonical interaction reference is the prototype **`Margin-journey-full.html`** — match its flow and feel, not its literal HTML.

1. **Onboarding** (experiential, ~2 short panels, **no questionnaire** — see §6.1)
2. **The Moment loop:** Settle → Name → Note → staged Return-into-Home (§6.2–6.5) — *the heart; build first after skeleton*
3. **Home — "You, lately"** with empty→filled states and the staged reveal (§6.5–6.6)
4. **Insight engine** (deterministic) feeding Home (§5)
5. **Archive** — the time view (§6.6)
6. **Settings / rhythm** + **notifications v1** (§6.7–6.8)
7. **Optional backup login** (accrual-triggered, skippable) (§6.7)

---

## 5. The Insight Engine (most important system)

Margin is, formally, an experience-sampling instrument. The engine turns recorded Moments into **honest, balanced, kind** observations.

**Shape:** a small **rule library**. Each rule has: a trigger that must be *literally true* of the data, a **sufficiency gate** (minimum data before it can fire), a strength, a cooldown, and a copy template. The engine evaluates rules and surfaces at most one standing line, choosing the most honest/strong one. If none qualifies, it stays quiet or states the plain truth ("no strong pattern yet — just your days, as they are").

**Cadence (layered):**
- *Per-Moment:* presence only — acknowledge the mark; **no pattern claim.**
- *Standing line (~7-day horizon):* recomputed each entry but **pattern-gated** (don't churn the wording on every entry; only change when the underlying pattern changes).
- *Weekly reflection:* a gentle periodic look back.
- *Cold-start:* reflect the **act**, not a trend ("the first mark is yours — the map starts here").

**Pattern-as-notification (new type):** a genuinely-true pattern may also be delivered as a nudge ("a pattern we noticed"). Same two guardrails apply hard: **mirror not judge**, and **never invent**. A kind observation, never a diagnosis.

**Balanced examples (tone to match):**
- "Mornings have been the lighter part of your days."
- "Your charged moments tend to gather in the afternoon. The mornings sit lighter."
- "More ease than weight, these last few days."
- (cold-start) "Noted. The first mark is yours — the map starts here."

**Forbidden tone:** anything teacherly ("that's the practice"), congratulatory, clinical, or that implies something is wrong.

---

## 6. Screen specs

### 6.1 Onboarding (experiential, no questionnaire)
- ~2 calm panels that **frame, don't lecture.** Panel 1: what Margin is (one line). Panel 2: names the three small things — **settle · name what's here · see it from a step back** — plus the privacy line (no streaks, no judgment, no account; stays on device). The final button leads **straight into the first breath** — philosophy is learned by *doing*, not reading.
- **Take no information at the start.** No "when are you stressed?" survey. Reasons: it contradicts mirror-not-judge (don't ask users to self-diagnose), it feels like a form, and an empty home is an *invitation*, not a defect.

### 6.2 Settle (required, minimal)
- **One slow exhale.** Nothing is tappable until the breath completes; the "continue" affordance appears only after.
- Visual: ink blooms/settles on the exhale and **becomes the first mark** of this Moment in the Field. A strong, distinctive animation is wanted (designed in context, §7).
- *Hypothesis, build as a config value:* breath **count = 1** for now. Make it a single constant so it can be tested, not hard-scattered.

### 6.3 Name (progressive disclosure)
- Question framed as **"What's here right now?"** (never "what's wrong?").
- **(a) Body — optional, first.** A small set of body locations + "not sure". Selecting one (or a "where doesn't matter →" skip) **softly reveals** the word field — one continuing motion, not a multi-field form.
- **(b) Word — the minimum tap.** A flat, curated, **valence-balanced** palette (light *and* heavy equally present). Plus a **"can't name it"** chip that opens a **write-your-own** free-text field — writing your own is *stronger* labeling than picking, so this is a real door, not a dead end (its band is nil; handle gracefully).
- Never show the word "label" to users. Stage is called **Name**.
- *Hypothesis:* body-first vs word-first order — keep the order easy to flip for testing.

### 6.4 Note (optional)
- One optional free-text line. A **"let it be — just save"** action sits right there so a Moment records **without** writing. This optionality is what keeps the Moment from feeling like a form.
- The Note is **never** read by any model in v1.

### 6.5 Return → Home (merged, staged reveal)
- There is **no separate Return screen.** After saving, the user lands on Home with a **staged reveal:**
  1. First, **only the one insight/return sentence**, alone and centered — a brief beat (protects the "see yourself from a distance" moment).
  2. Then it gently completes: the **Field**, then **recent moments**, settle in beneath.
- **Skippable** (a tap shows everything at once) and **only after a Moment** — normal Home entries are instant, not animated. Keep timings calm but quick (don't make it feel like waiting).

### 6.6 Home "You, lately" + Archive
- **Home:** the Field (generative map of marks, balanced tones), the standing insight line, a quiet thread of **recent moments** (word + time + optional body tag). **No name, no avatar, no account.** This *is* the profile — don't build a separate "Profile" screen. (Home is expected to grow more dynamic/visual later; the structure is locked, the final visual form is open.)
- **Empty state (day one):** "Your first moment settles here." The empty Field is an invitation; the first Moment fills it.
- **Return-from-absence** is a *different* empty-ish state — kind, no scolding ("an unmarked stretch is part of a rhythm too"), never "12 days away!".
- **Archive ("Where you've been"):** moments grouped by day, newest first, with band-colored dots; tappable to a moment's detail (word, time, body, note). **No scores, no streaks.**

### 6.7 Settings / rhythm + optional backup login
- **Settings = the controls** (no separate settings universe): nudge frequency, quiet hours, "what to notice" (framed balanced, e.g. "whatever's here"), account status, delete-everything.
- **Optional backup login** (later; gated by Apple-account logistics): never required. Offered **based on accrual** — when the user has built history worth protecting (e.g. the Field has several marks / a real insight has appeared), not on a fixed timer. Copy: "A rhythm is forming here — keep it safe?" Apple/Google for **backup only, not sign-in**; user stays anonymous inside Margin; **always skippable** ("not now — keep it on this device").

### 6.8 Notifications (learn-your-rhythm, v1)
- **Timing model (step one — simple, on-device):** count when the user pauses → smooth into a soft day-curve (kernel smoothing — "around 9am", not "9:00 sharp") → offer nudges near the **peaks**, chosen **probabilistically** (not always the top peak — avoid robotic predictability) → **constrain** by quiet hours, max-per-day, and minimum spacing → **cold-start** with a sensible default (late-morning + afternoon) or watch-only for the first days.
- **Nudge voice:** balanced, "what's here?" not "what's wrong?". e.g. "A small pause. What's here right now — light or heavy?"
- *Hypotheses, flagged:* (a) whether learned timing beats a fixed time is **unproven** — keep a manual override; (b) **lock-in risk** — don't only mirror existing times; occasionally invite *outside* the current pattern.
- Same data powers insight (§3) — one signal, two uses.

---

## 7. Visual style (decide in context, during the core-loop build)

Do **not** lock a full design system up front, and don't build everything ugly to "theme later." Define a **lightweight token set** while building the core loop, applied to real screens; the system matures with the code.

**Direction (locked):** wabi-sabi / *ma* (negative space) / sumi ink on washi paper · warm, matte, calm · **never glossy or attention-seeking** (liquid-glass was considered and rejected as off-brand). The interface should be nearly invisible so the user sees *themselves*, not the app.

**Starting tokens (from the prototypes — refine in context):**
- Palette: ink `#1b1a16`, indigo `#233650`, paper `#efece4` / `#e9e5dc`, stone borders `#ded9ce`/`#c5c0b4`, accent clay `#b06040`, gold `#a89668`.
- Band tones: activated = clay, weighted = indigo, settled = gold.
- Type: serif **Newsreader** (headings/insight lines), sans **Hanken Grotesk** (UI), mono **Spline Sans Mono** (small labels/eyebrows).
- Texture: subtle washi grain; soft, blurred radial "ink" marks for the Field.

**Two signature elements** to design as real code here: the **breath/ink** animation and the **Field** generative art. If Home later needs more life, get it from the *ink and paper* (breathing ink, depth, soft layering) — never from gloss.

---

## 8. Locked vs hypothesis (so you don't treat guesses as gospel)

**Locked:** purpose framing · the four Moment stages · Name=Word + progressive disclosure + permission-to-not-know · anonymous/on-device/no-account · deterministic on-device engine · mirror-not-judge · never-invent · valence-balance · no streaks/shame · staged Return-into-Home · Home-is-the-profile ("You, lately") · learn-your-rhythm notifications v1 (with guardrails).

**Hypotheses (build them configurable/testable, don't hard-bake):** breath count (=1) · body-first vs word-first order · whether insight cadence drives return · choosing a word vs writing one · learned rhythm vs fixed time · whether insight is truly the main install/return driver.

---

## 9. Reference docs (source-of-truth order)

When these disagree, the **Decision Log wins**, then this file, then the specs.
- `Margin-Decision-Log` — the single source of truth (locked decisions, open items, hypotheses).
- `Margin-Moment-Journey-v0.2` — the locked Moment journey.
- `Margin-Insight-Engine` — the engine spec *(note: being updated to add mirror-not-judge, the notification timing model, the pattern-notification type, the never-invent guardrail, and to drop the old `emotionFamily` field — apply those updates as you build)*.
- `Margin-Layer-Map-v0.2` — how the project is organized (Philosophy → Product → Journey → Feeling → Technical, plus Brand across all).
- `Margin-Launch-Checklist-v0.2` — the road to launch.
- Prototypes (interaction/visual reference, not literal code): `Margin-journey-full.html` (canonical full journey), `Margin-prototype-flow.html`, `Margin-profile-notif-explore.html`, `Margin-Name-compare.html`.

---

## 10. How to work

- Build in the order of §4: skeleton + storage → Moment loop → Home + engine → archive/settings/notifications.
- Keep it **token-driven** (UI) and **data/config-driven** (the rules engine, the hypothesis constants) so changes are cheap.
- Keep clean boundaries: deterministic-engine vs any-future-LLM; on-device vs any-future-sync.
- When something is ambiguous, choose the calmer, plainer option and **flag the decision** rather than guessing on a guardrail.
- This is v1: small, on-device, TestFlight-ready. Resist scope creep and speculative infrastructure.
