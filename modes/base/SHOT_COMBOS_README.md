# Base Mode Shot Combos System

## Overview

Three dynamic shot combo sequences have been added to the base mode that unlock major game features:
- **Ball Lock Qualifications**
- **Playfield Multipliers** (2x and 3x)
- **Hurry Up Modes**

## Combo Sequences

### 1. 🟢 **Ramp to Orbit Combo** (5 second window)
**Sequence:** Left Ramp → Right Orbit → Left Spinner

**Achievements:**
- ✅ **Ball Lock Qualification Enabled**
- ✅ **Playfield Multiplier +1x** (increases to 2x)
- ✅ **Score:** 50,000 pts
- **Event Posted:** `ramp_to_orbit_combo_complete`, `ramp_combo_qualified`

**Best For:** Starting game flow, hitting ramps early

---

### 2. 🟢 **Loop Combo** (5 second window)
**Sequence:** Left Inner Loop → Right Inner Loop → Right Orbit

**Achievements:**
- ✅ **Hurry Up Mode Activated**
- ✅ **Ball Lock Qualification Enabled**
- ✅ **Score:** 75,000 pts
- **Event Posted:** `loop_combo_complete`, `loop_combo_qualified`

**Best For:** Loop-focused gameplay, starting time-sensitive modes

---

### 3. 💜 **Spinner Rampage Combo** (4 second window)
**Sequence:** Left Spinner → Center Spinner → Right Spinner

**Achievements:**
- ✅ **Playfield Multiplier +2x** (increases to 3x total)
- ✅ **Super Mode Qualification**
- ✅ **Score:** 100,000 pts
- **Event Posted:** `spinner_rampage_combo_complete`, `spinner_combo_qualified`

**Best For:** High-risk, high-reward gameplay with spinners

---

## Shot Definitions

All combos are built from these base shots:

```yaml
Ramps/Orbits:
- left_orbit (s_left_ramp)
- right_orbit (s_right_orbit)
- center_ramp (s_center_ramp)

Spinners:
- left_spinner (s_left_spinner)
- center_spinner (s_center_spinner)
- right_spinner (s_right_spinner)

Loops:
- inner_loop_left (s_innerloop_left)
- innerloop_right (s_innerloop_right)
```

---

## Scoring Impact

| Combo | Base Score | Multiplier Bonus | Total Potential |
|-------|-----------|------------------|-----------------|
| Ramp to Orbit | 50,000 | +1x multiplier | 100,000+ |
| Loop Combo | 75,000 | +1x multiplier | 150,000+ |
| Spinner Rampage | 100,000 | +2x multiplier | 300,000+ |

---

## Player Variables Modified

When combos complete, these player variables are updated:

```yaml
ramp_to_orbit_combo_complete:
  score: +50,000
  playfield_multiplier: +1

loop_combo_complete:
  score: +75,000
  playfield_multiplier: +1

spinner_rampage_combo_complete:
  score: +100,000
  playfield_multiplier: +2

ball_lock_qualification_started:
  ball_lock_qualified_shots: +1
```

---

## Events Fired

### Ramp to Orbit Combo Complete
- `ramp_to_orbit_combo_complete`
- `ball_lock_qualification_started`
- `playfield_multiplier_x2`
- `ramp_combo_qualified`

### Loop Combo Complete
- `loop_combo_complete`
- `hurry_up_mode_start`
- `ball_lock_qualification_started`
- `loop_combo_qualified`

### Spinner Rampage Combo Complete
- `spinner_rampage_combo_complete`
- `playfield_multiplier_x3`
- `spinner_combo_qualified`
- `super_mode_qualified`

---

## Game Strategy

### Early Game (First Ball)
1. **Target:** Ramp to Orbit Combo
2. **Benefit:** Unlocks ball lock features and 2x multiplier
3. **Next:** Now lock balls for multiball

### Mid Game (Multiball Prep)
1. **Target:** Loop Combo
2. **Benefit:** Activates hurry-ups for time pressure
3. **Next:** Complete timely objectives for super mode

### Late Game (High Scores)
1. **Target:** Spinner Rampage Combo
2. **Benefit:** Unlocks 3x multiplier + super mode
3. **Impact:** Max scoring on all playfield shots

---

## Technical Notes

- **Sequence Window:** Each combo has a defined time window (4-5 seconds) between shots
- **Shot Groups:** `base_combo_shots` groups all combo shots for lane rotation features
- **Show Tokens:** Combos use LED tokens for visual feedback
  - `combo_indicator_1`: Green LED for Ramp combo
  - `combo_indicator_2`: Green LED for Loop combo
  - `combo_indicator_3`: Purple LED for Spinner combo

---

## Integration Points

These combos trigger events that should be handled by:

1. **Ball Lock Modes** → Listen for `ball_lock_qualification_started`
2. **Hurry Up Modes** → Listen for `hurry_up_mode_start`
3. **Super Modes** → Listen for `super_mode_qualified`
4. **Multiplier Logic** → Tracks `playfield_multiplier` variable

---

## Future Enhancements

Potential additions:
- Combo multipliers (complete 2+ combos for bonus)
- Combo degradation (timer to reset if not completed)
- Combo qualifying shots (light specific shots for combos)
- Achievement tracking (combo completion statistics)
- Custom combo builder per mode
