# 🎮 WARHAMMER 40K PINBALL - QUICK CODEBASE SNAPSHOT

## Game Stats

- **Modes:** 28 active modes
- **Priority Levels:** 5 different (100-300)
- **Playfields:** 1 main playfield
- **Flippers:** 3 (left, right, upper-left)
- **Servos:** 2 (Ork animation, lock mechanism)
- **Ball Locks:** 3 systems (Titan 3x, Necron 1x, Secondary locks)
- **Multiballs:** 3 types (Titan 3-ball, Waagh 3-ball, Necron 2-ball)
- **Coils:** 13 solenoids
- **Switches:** 165+ configured
- **LEDs:** 50+ configured
- **Shows:** 15+ light shows
- **Lines of Config:** 5,000+ YAML lines

---

## Core Features Implemented ✅

```
SHOT COMBOS (NEW):
  ✅ Ramp→Orbit→Spinner combo (unlock ball lock + 2x multiplier)
  ✅ Loop→Loop→Orbit combo (unlock hurry-up + 2x multiplier)
  ✅ Spinner×3 combo (unlock super mode + 3x multiplier)

CHAOS GOD MISSIONS:
  ✅ Khorne - Ramp progression (fully working)
  ✅ Tzeench - Spinner countdown (working, creative pattern)
  ✅ Slan'esh - Shot rotation (config contaminated - needs fix)
  ✅ Nurgle - Bell ringing (partial implementation)
  ⚠️  Necrons - Drop target trigger (WIP)

MULTIBALL SYSTEMS:
  ✅ Titan Multiball (3-ball, 3 locks, fully working)
  ✅ Waagh Multiball (3-ball, fully working)
  ✅ Necron Multiball (2-ball, working)

SCORING:
  ✅ Playfield multiplier (1x → 3x)
  ✅ Mode-based progression (M-level scoring)
  ✅ Bonus system (multiplied)
  ✅ Drainside scoring (outlane bonuses)

MECHANICAL:
  ✅ 3 flippers (main left, main right, upper-left)
  ✅ Ball save grace period
  ✅ Tilt detection
  ✅ Ball search

AUDIO:
  ✅ Sophisticated ducking (voice/music separation)
  ✅ Mode-specific sound effects
  ✅ Audio ducking on major events
```

---

## Critical Issues Found 🚨

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| Config copy-paste | `slannesh.yaml` lines 28-93 | HIGH | Delete Tzeench data |
| Placeholder switches | Tzeench/Slan'esh shots | HIGH | Map to real targets |
| Incomplete modes | Horus, Necrons, Inquisition | MEDIUM | Implement modes |
| Missing priorities | 8+ modes | MEDIUM | Define mode priority values |

---

## File Structure

```
config/                    [Core hardware definitions]
  ├─ config.yaml          [Ball devices, servos, hardware]
  ├─ coils.yaml           [13 coil definitions]
  ├─ flippers.yaml        [3 flipper configs]
  ├─ switches.yaml        [165+ switches]
  ├─ lights.yaml          [50+ LEDs]
  ├─ modes.yaml           [28 mode load order]
  └─ player_variables.yaml [14 player vars]

modes/
  ├─ base/               [Main playfield, shot combos]
  ├─ [5 Chaos Modes]     [Khorne, Tzeench, Slan'esh, Nurgle, Necrons]
  ├─ [3 Multiball Modes] [Titan, Waagh, Necron]
  └─ [20 Utility Modes]  [Skillshot, bonus, ball save, etc.]

shows/                   [15+ light show definitions]
code/                    [Custom Python: dead flipper handling]
```

---

## Mode Priority Architecture

```
Priority 300:
  ├─ titan_multiball         [Most important when active]
  └─ waagh_multiball

Priority 200:
  ├─ khorne, tzeench, slannesh, nurgle, necrons  [Chaos Gods]
  └─ [Other special modes]

Priority 100:
  ├─ base                    [Always active foundation]
  ├─ necron_multiball
  └─ [Support modes]

Priority ?: [Undefined]
  ├─ attract
  ├─ skillshot
  ├─ bonus
  └─ [Other modes]
```

---

## Hardware Highlights

### Ball Devices (6)
```
bd_trough          [6 balls - main collection]
bd_plunger         [Ball launcher]
bd_scoop           [Mid-playfield VUK]
bd_titan           [3 locks - Titan multiball]
bd_right_vuk       [Right side VUK]
bd_necron_lock     [Secondary lock]
```

### Flippers (3)
```
left_flipper       [Main left]
right_flipper      [Main right]
upperLeft_flipper  [Ramp exit, upper table]
```

### Servos (2)
```
ork_servo         [Playfield animation]
lock_servo        [Lock mechanism]
```

### Autofire Coils (4)
```
Left & Right slingshots
Top & bottom pop bumpers
```

---

## Light Show System

**Parameterized Shows** (Use tokens):
- `generic_flash.yaml` - Main flash effect
- `standard_flash.yaml` - Alternative flash
- `pop_flash.yaml` - Pop bumper effect

**Spinner Shows** (Speed: 20):
- `CenterSpinnerExpanding`
- `LeftSpinnerExpanding`
- `RightSpinnerExpanding`

**Sweep Shows** (Visual effects):
- `PlayfieldTriangleSweep`
- `Playfield360rainbowsSweep`
- `LeftLightBarSweep`
- `RightLightBarSweep`

---

## Event Patterns Used

1. **Counter→Shot Pattern** (Tzeench)
   - Counter decrements on switch hit
   - Counter complete posts fake switch event
   - Shot system registers as hit

2. **Accrual Pattern** (Mode completion)
   - Multiple events trigger accrual
   - All events required → completion
   - Posts composite event

3. **Variable Scaling** (Scoring)
   - All scores multiplied by playfield_multiplier
   - Base score × multiplier × mode bonus

4. **Sound Ducking** (Professional audio)
   - Voice bus ducks music
   - Configurable attack/release
   - Release point delays fade-out

---

## Scoring Summary

**Playfield** (1x → 3x multiplier):
- Spinners: 100 pts
- Slingshots: 500 pts
- Ramps: 2,000 pts
- Orbits: 2,000 pts
- Outlanes: 10,000 pts

**Modes** (M-level):
- Khorne: 50M final
- Tzeench: 25M final
- Slan'esh: 25M final

**Bonus** (×2 multiplier):
- Pop bumper hits
- Relic collection
- Purity seals

---

## What's Working Well ✅

1. **Modular mode system** - Clean, organized
2. **Professional hardware setup** - FAST platform
3. **Creative mechanics** - Counter-to-shot pattern
4. **Sound integration** - Sophisticated ducking
5. **Multiball system** - Multiple lock types
6. **Theme integration** - Strong Warhammer 40K
7. **Show token system** - Reusable parameterized shows
8. **Godot GMC** - Modern media controller

---

## What Needs Attention ⚠️

1. **Fix Slan'esh config** (Delete Tzeench copy-paste)
2. **Map placeholder switches** (s_tempholder1/2/3)
3. **Complete WIP modes** (Necrons, Tyranids, etc.)
4. **Define missing priorities** (8+ modes)
5. **Expand sound coverage** (Add to all modes)
6. **Complete Tyranids** (Complex 3-phase)

---

## Documentation Created

✅ **CODEBASE_REVIEW.md** - This file (comprehensive overview)
✅ **Shot Combo System** - 6 detailed guides (already provided)

---

**Status:** Comprehensive review complete. Ready for improvements and fixes.
