# TZEENCH MODE - STAGE 1 DESIGN DOCUMENT

## Overview
Tzeench Stage 1 is a dramatic, theatrical mode featuring:
- **Strobe Effect**: GI lights turned off with white 300ms strobe flashing
- **Roaming Shot Mechanic**: One shot "roams" through 9 playfield positions, auto-advancing every 6 seconds
- **Progressive Scoring**: Shots increase in value, with multiplier bonuses from Xenos target hits

---

## STAGE 1: STROBE & ROAMING SHOTS

### Mode Duration
- **60 seconds** per mode attempt
- Transition to Stage 2 when **9 shots are hit**

### Visual Effects

#### GI Lights (Off Stage)
All GI lights (slings, inlanes) turn **off** at mode start to create dramatic darkness.

#### White Strobe Show
All GI lights **flash white** at **300ms intervals** (0.3s on, 0.3s off) continuously during Stage 1.
- Uses: `shows/strobe_white.yaml`
- Looped throughout Stage 1

#### Shot Hit Effect  
When the roaming shot is successfully hit:
- **Wavy light blue** effect plays on the hit arrow LED
- Pattern: 0.2s on → 0.1s off → 0.2s on → 0.1s off → 0.2s on
- Uses: `shows/tzeench_roaming_hit.yaml`
- Hit arrow **remains lit with aqua color** after completion

---

## ROAMING SHOT SYSTEM

### Shot Rotation Sequence (9 Total)
1. **Center Ramp** → `l_center_ramp_arrow`
2. **Left Orbit** → `l_left_orbit_arrow`
3. **Right Orbit** → `l_right_orbit_arrow`
4. **Inner Loop Left** → `l_left_innerloop_arrow`
5. **Inner Loop Right** → `l_right_innerloop_circle`
6. **Drop Target** → `l_solemnace_arrow`
7. **Scoop** → `l_nurgle1`
8. **Super Jackpot VUK** → `l_jackpot`
9. **Snikt Target** → `l_left_sling_upper`

### Auto-Advancement
- **Every 6 seconds**, roaming position advances to next shot automatically
- Timer: `tzeench_roaming_advance` (6-second countdown, restarts after completion)
- Players do NOT need to hit the shot to advance (it's automatic)
- **BUT**: Hitting the lit shot advances it immediately + resets timer

### Lighting Pattern
- Active roaming shot: **Aqua color, flashing with white strobe**
- Other shots: Off/dark
- On hit: Wavy light blue pattern, then arrow stays aqua

---

## SCORING SYSTEM (STAGE 1)

### Base Shot Value
- **100,000 points** per roaming shot hit

### Progressive Increase
Each shot hit increases the base value by **10,000 points**:
- Shot 1: 100K
- Shot 2: 110K
- Shot 3: 120K
- ...
- Shot 9: 180K

### Xenos Target Bank Bonus
When the **left xenos target bank** is hit during Tzeench:
- Adds **50,000 points** to base shot value
- This bonus persists for remaining shots in Stage 1
- Multiple hits stack the bonus

### Calculation Example
- Player hits left xenos bank (+50K)
- Next roaming shot hit: 100K + 50K = 150K (then +10K for next shot)
- After hitting first roaming shot: 160K for next shot (100K base + 50K xenos + 10K progression)

---

## SHOT RESET MECHANIC

### Reset Timing
After hitting a roaming shot:
- All shots remain **enabled** for **15 seconds**
- After 15 seconds: All roaming shots **reset to unlit state**

### Reset Behavior
- Reset does **NOT** reset the progression value
- Reset does **NOT** reset the Xenos bonus
- Reset allows previously-hit shots to **count again** towards the 9-shot completion

### Example Flow
1. Player hits Center Ramp (Shot 1 of 9)
2. 15-second timer starts
3. After 15 seconds: Center Ramp resets to unlit
4. If player hits Center Ramp again: Counts as Shot 2 of 9 (not reset)
5. Both hits scored with their respective values

---

## STAGE TRANSITION

### Completion Condition
Mode transitions to **Stage 2** when:
- **9 or more roaming shots are hit** (in any combination, with repeats counting)

### Transition Actions
When Stage 1 completes:
1. GI lights turn **back on** (normal operation)
2. White strobe show **stops**
3. Stage 2 begins: Batman 66-style progressive ruleset

---

## STAGE 2 FRAMEWORK (TODO)

Stage 2 will feature:
- GI lights in normal operation (on)
- Batman 66-style progressive shot mechanics
- Higher scoring values
- New shot/rule progression system

### Notes for Stage 2 Design
- [ ] Implement progressive difficulty (more shots required each stage)
- [ ] Create "rogues gallery" or "villain encounter" progression
- [ ] Design Batman 66-style scoring multipliers
- [ ] Plan mode completion/jackpot mechanics
- [ ] Design visual distinction from Stage 1 (different colors, effects)
- [ ] Plan audio progression (different voice lines per stage)

---

## IMPLEMENTATION DETAILS

### New Files Created
1. **shows/strobe_white.yaml** - White strobe effect (300ms timing)
2. **shows/gi_lights_off.yaml** - Disable all GI lights
3. **shows/tzeench_roaming_hit.yaml** - Wavy light blue effect for hits
4. **modes/tzeench/config/tzeench.yaml** - Complete Stage 1 & Stage 2 framework

### Mode Variables Used
- `tzeench_shot_index`: Current roaming position (0-8)
- `tzeench_shots_hit`: Total shots completed (0-9+)
- `tzeench_stage`: Current stage (1 or 2)
- `tzeench_shot_value`: Current shot point value

### Timers
- `tzeench_mode_timer`: 60-second overall mode timer
- `tzeench_roaming_advance`: 6-second auto-advance timer

### Event Flow
```
Mode Start
  ↓
Turn off GI, start strobe
  ↓
Start 6-second roaming timer
  ↓
Roaming Shot Auto-Advances Every 6s
  ↓
Player Hits Roaming Shot (at any point)
  ├─ Score points (increasing value)
  ├─ Play wavy light blue effect
  ├─ Restart 6-second timer
  ├─ Start 15-second reset timer
  └─ Increment shot count
      ↓
      Shot Count = 9?
      ├─ YES → Transition to Stage 2
      └─ NO → Continue roaming
      
15 Seconds After Shot Hit
  ↓
All shots reset (can be hit again)
```

---

## GAME DESIGN NOTES

### Difficulty Progression
- **Stage 1** is relatively forgiving: 9 hits to complete, auto-advancing reduces skill requirement
- Players can use roaming auto-advance if they miss shots
- Xenos target bonus rewards playfield awareness
- 15-second reset allows skill shots to contribute more

### Theatrical Experience
- Strobe effect creates urgency and drama
- Darkness (GI off) makes white strobe more striking
- 6-second auto-advance keeps pace fast
- Wavy light blue on hit provides satisfying visual feedback

### Scoring Balance
- 100K base keeps Stage 1 "manageable" scoring
- Progressive increase (100K→180K range) rewards consistent play
- Xenos bonus (50K) makes it worthwhile to hunt
- Full stage completion (180K × 9) = ~1.35M, reasonable for 60-second mode

---

## NEXT STEPS

### For Stage 2 Design
1. Clarify Batman 66 mechanics (gadgets? villain progression? dynamic difficulty?)
2. Define Stage 2 shot progression
3. Design Stage 2 scoring structure
4. Plan visual/audio distinction from Stage 1
5. Design completion/jackpot mechanics

### For Testing
1. Verify roaming advancement timing (6 seconds auto-advance)
2. Test shot hit scoring progression
3. Verify Xenos target integration
4. Test 15-second reset mechanic
5. Test Stage 1→2 transition at 9 shots
6. Verify GI light on/off during transition
7. Test strobe timing (300ms looks right)

---

## SWITCH MAPPING REFERENCE

| Shot Name | Switch | LED |
|-----------|--------|-----|
| Center Ramp | s_18 | l_center_ramp_arrow |
| Left Orbit | s_snikt_target | l_left_orbit_arrow |
| Right Orbit | s_27 | l_right_orbit_arrow |
| Inner Loop Left | s_scoop_nurgle_target | l_left_innerloop_arrow |
| Inner Loop Right | s_24 | l_right_innerloop_circle |
| Drop Target | s_26 | l_solemnace_arrow |
| Scoop | s_scoop_nurgle_target | l_nurgle1 |
| Super Jackpot VUK | s_25 | l_jackpot |
| Snikt Target | s_snikt_target | l_left_sling_upper |

---

## COLOR REFERENCE
- **Aqua**: `color: aqua` (roaming shot arrow when active)
- **Light Blue**: `light_blue` (wavy effect on hit)
- **White**: `white` (strobe effect)
