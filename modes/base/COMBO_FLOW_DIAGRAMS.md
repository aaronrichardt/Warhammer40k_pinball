# Base Mode Shot Combo Flow Diagram

## Combo 1: Ramp to Orbit Combo 🟢
```
┌─────────────────────────────────────────────────────────┐
│                 RAMP TO ORBIT COMBO                     │
│                   (5 second window)                     │
└─────────────────────────────────────────────────────────┘

    Left Ramp
       │
       │ ─5s─→
       ▼
    Right Orbit
       │
       │ ─5s─→
       ▼
    Left Spinner
       │
       │ COMPLETE!
       ▼
  ┌────────────────────────────────────────┐
  │ REWARDS:                               │
  │ ✓ Ball Lock Qualification Enabled      │
  │ ✓ Playfield Multiplier: x2            │
  │ ✓ Score: +50,000                      │
  │ ✓ Event: ramp_combo_qualified         │
  └────────────────────────────────────────┘
```

---

## Combo 2: Loop Combo 🟢
```
┌─────────────────────────────────────────────────────────┐
│                    LOOP COMBO                           │
│                   (5 second window)                     │
└─────────────────────────────────────────────────────────┘

    Left Inner Loop
       │
       │ ─5s─→
       ▼
    Right Inner Loop
       │
       │ ─5s─→
       ▼
    Right Orbit
       │
       │ COMPLETE!
       ▼
  ┌────────────────────────────────────────┐
  │ REWARDS:                               │
  │ ✓ Hurry Up Mode Started                │
  │ ✓ Ball Lock Qualification Enabled      │
  │ ✓ Score: +75,000                      │
  │ ✓ Event: loop_combo_qualified         │
  └────────────────────────────────────────┘
```

---

## Combo 3: Spinner Rampage Combo 💜
```
┌─────────────────────────────────────────────────────────┐
│              SPINNER RAMPAGE COMBO                      │
│                   (4 second window)                     │
└─────────────────────────────────────────────────────────┘

    Left Spinner
       │
       │ ─4s─→
       ▼
    Center Spinner
       │
       │ ─4s─→
       ▼
    Right Spinner
       │
       │ COMPLETE!
       ▼
  ┌────────────────────────────────────────┐
  │ REWARDS:                               │
  │ ✓ Playfield Multiplier: x3            │
  │ ✓ Super Mode Qualified                 │
  │ ✓ Score: +100,000                     │
  │ ✓ Event: spinner_combo_qualified      │
  └────────────────────────────────────────┘
```

---

## Playfield Multiplier Progression

```
START GAME
    │
    ├─→ Hit Ramp to Orbit Combo
    │       ▼
    │   Multiplier: x1 → x2 (+50,000 pts)
    │
    ├─→ Hit Loop Combo
    │       ▼
    │   Multiplier: x2 → x3 (+75,000 pts)
    │
    └─→ Hit Spinner Rampage Combo
            ▼
        Multiplier: x3 → x5 (+100,000 pts)
            ▼
        ALL SHOTS NOW WORTH 5x NORMAL!
```

---

## Ball Lock Qualification Timeline

```
GAME START (No Ball Lock Qualifying)
    │
    ├─→ Complete Ramp Combo
    │   OR
    │   Complete Loop Combo
    │       ▼
    │   ball_lock_qualified_shots: +1
    │   (Can now lock 1 ball)
    │       ▼
    │   Hit s_dreadnought_lock1/2/3 to lock balls
    │
    └─→ When 3 balls locked
        → MULTIBALL STARTS!
```

---

## Hurry Up Mode Trigger

```
Standard Gameplay
    │
    └─→ Complete Loop Combo
            ▼
        hurry_up_mode_start event
            ▼
        ┌────────────────────────────┐
        │ HURRY UP MODE ACTIVATED    │
        │ ⏱️  Time Pressure!          │
        │ 🎯 Time-Sensitive Goals     │
        │ 💰 Increased Scoring       │
        └────────────────────────────┘
```

---

## Super Mode Qualification

```
Standard Gameplay
    │
    └─→ Complete Spinner Rampage Combo
            ▼
        super_mode_qualified event
            ▼
        ┌────────────────────────────┐
        │ SUPER MODE QUALIFIED       │
        │ 👑 Premium Game Mode       │
        │ 📈 Maximum Scoring         │
        │ 🔥 Chaos Mode Potential    │
        └────────────────────────────┘
```

---

## Shot Group: base_combo_shots

```
Shots in Group:
├── left_orbit (s_left_orbit)
├── right_orbit (s_right_orbit)
├── left_spinner (s_left_spinner)
├── center_spinner (s_center_spinner)
├── right_spinner (s_right_spinner)
├── inner_loop_left (s_innerloop_left)
└── innerloop_right (s_innerloop_right)

Can be used for:
- Lane rotation on flipper hits
- Group-level lighting effects
- Combined mode logic
```

---

## Integration Checklist

Before using these combos, ensure:

```
☐ Player variables file includes:
  ☐ playfield_multiplier (initial: 1)
  ☐ ball_lock_qualified_shots (initial: 0)
  ☐ score (initial: 0)

☐ Modes listening for combo events:
  ☐ Ball Lock Mode → ball_lock_qualification_started
  ☐ Hurry Up Mode → hurry_up_mode_start
  ☐ Super Mode → super_mode_qualified

☐ Show files created:
  ☐ Shows for combo_indicator_1 (green)
  ☐ Shows for combo_indicator_2 (green)
  ☐ Shows for combo_indicator_3 (purple)

☐ LED definitions:
  ☐ l_left_ramp_arrow (or similar)
  ☐ l_right_orbit_arrow
  ☐ l_left_spinner_arrow
  ☐ l_center_spinner_arrow
  ☐ l_right_spinner_arrow
```

---

## Testing Combos

### Manual Test Script

```
# Start game
start_game

# Test Ramp to Orbit Combo
hit_and_release_switch s_left_orbit
advance_time_and_run 1
hit_and_release_switch s_right_orbit
advance_time_and_run 1
hit_and_release_switch s_left_spinner
advance_time_and_run 0.1

# Should see:
# Event: ramp_to_orbit_combo_complete
# Score: +50,000
# playfield_multiplier: 2

# Test Loop Combo
hit_and_release_switch s_innerloop_left
advance_time_and_run 1
hit_and_release_switch s_innerloop_right
advance_time_and_run 1
hit_and_release_switch s_right_orbit
advance_time_and_run 0.1

# Should see:
# Event: loop_combo_complete
# Event: hurry_up_mode_start
# Score: +75,000
```

---

## Event Dependency Graph

```
ramp_to_orbit_combo_complete
    ├─ ball_lock_qualification_started
    │   └─ Enable s_dreadnought_lock1/2/3
    │
    ├─ playfield_multiplier_x2
    │   └─ Increase multiplier: x1 → x2
    │
    └─ ramp_combo_qualified
        └─ Trigger ramp-specific logic


loop_combo_complete
    ├─ hurry_up_mode_start
    │   └─ Start time-limited mode
    │
    ├─ ball_lock_qualification_started
    │   └─ Enable s_dreadnought_lock1/2/3
    │
    └─ loop_combo_qualified
        └─ Trigger loop-specific logic


spinner_rampage_combo_complete
    ├─ playfield_multiplier_x3
    │   └─ Increase multiplier: x2 → x3 (or x1 → x3)
    │
    ├─ spinner_combo_qualified
    │   └─ Trigger spinner-specific logic
    │
    └─ super_mode_qualified
        └─ Enable premium game mode
```
