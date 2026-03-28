# TZEENCH MODE - STAGE 2 & STAGE 3 DESIGN
## Catwoman 2 (Batman 66) Rules Framework

---

## OVERVIEW

**Stage 2** and **Stage 3** implement the Catwoman 2 mode structure from Batman 66, featuring:
- **Stage 2 (Easy)**: All ramps and orbits lit → Any shot lights Super Jackpot
- **Stage 3 (Final)**: All 9 shots lit → 5-shot progression with cycling → Super Jackpot lights

This creates a natural skill progression from Stage 1's dramatic strobe mechanic.

---

## STAGE PROGRESSION FLOW

```
STAGE 1 (60 seconds)
  Strobe + Roaming Shots
  Hit 9 shots → Advance
        ↓
STAGE 2 (Remaining time)
  All Ramps/Orbits Lit
  Any shot → Light Jackpot
  Hit Jackpot → Advance
        ↓
STAGE 3 (Remaining time)
  All 9 Shots Lit
  Hit 5 shots → Light Jackpot
  Hit Jackpot → Mode Complete!
```

---

## STAGE 2: EASY PROGRESSION

### Duration
- Starts when Stage 1 completes (9 shots hit)
- Uses remaining time from 60-second mode timer
- No separate timer

### Lit Shots
**Ramps and Orbits Only:**
1. Center Ramp
2. Left Orbit
3. Right Orbit
4. Inner Loop Left
5. Inner Loop Right

All other shots (Drop Target, Scoop, Snikt Target) are **disabled** in Stage 2.

### Scoring
- **Each shot**: 250,000 points
- **Super Jackpot**: 1,000,000 points (10 times a single shot)

### Progression
1. All 5 ramp/orbit shots are **flashing aqua**
2. Player hits **ANY** of the 5 shots
3. **Super Jackpot lights up** (flashing with aqua)
4. Player hits **Super Jackpot** → Advance to Stage 3

### Why It's Easy
- Only 5 shots instead of 9
- One of the easier/more repeatable shot sequences on a typical pinball layout
- Only needs to hit ONE shot to light Jackpot (no progression required)
- Designed to let players feel successful before final stage

### Visual Design
- All 5 shot arrows: Aqua flashing (generic_flash show)
- Super Jackpot: Aqua flashing until lit (bigger/brighter)
- When lit: Super Jackpot shows as solid aqua (on show)

---

## STAGE 3: FINAL STAGE

### Duration
- Starts immediately after Jackpot hit in Stage 2
- Uses remaining time from 60-second mode timer
- Mode ends when timer expires OR Jackpot is hit (whichever first)

### Lit Shots
**All 9 shots are lit:**
1. Center Ramp
2. Left Orbit
3. Right Orbit
4. Inner Loop Left
5. Inner Loop Right
6. Drop Target
7. Scoop
8. Super Jackpot VUK (s_25 - different from lighting shot)
9. Snikt Target

### Scoring
- **Each shot**: 500,000 points (2× Stage 2 shot value)
- **Super Jackpot**: 5,000,000 points (10× a single shot, same as Stage 2 Super Jackpot)

### Progression: Shot Cycling

**Key Mechanic**: Hitting a lit shot **unlit it** and **re-lights other shots**, allowing endless shot progression.

**Flow:**
1. **Stage starts**: All 9 shots lit (flashing yellow)
2. **Player hits a lit shot**:
   - Shot counts toward 5-shot progression
   - That shot **un-lights**
   - **All other shots re-light** (to be hit next)
   - Score awarded (500K)
3. **Repeat** steps 2-4 until 5 shots are hit
4. **After 5 hits**: Super Jackpot **lights**
5. **Player hits Jackpot**: 5M awarded, mode complete!

**Example Sequence:**
- All 9 shots lit (yellow flash)
- Hit Center Ramp (1/5) → Center Ramp unlit, 8 others relit
- Hit Left Orbit (2/5) → Left Orbit unlit, 8 others relit
- Hit Right Orbit (3/5) → Right Orbit unlit, 8 others relit
- Hit Center Ramp AGAIN (4/5) → Center Ramp unlit (hits same shot twice)
- Hit Snikt Target (5/5) → Super Jackpot now lights!
- Hit Super Jackpot → 5M, Mode Complete!

### Shot Cycling Details

**When Shot is Hit:**
1. Reset all Stage 3 shots (clear shot progress)
2. Re-light all Stage 3 shots (enable them again)
3. Increment stage3_shots_hit counter

**Visual Pattern:**
- **Unlit shot**: Off (no light)
- **Lit shot**: Yellow flash (generic_flash with yellow token)
- **On hit**: Yellow flash continues (tight flash loop) to show activity
- **Super Jackpot unlit**: Off
- **Super Jackpot lit** (after 5 shots): Aqua flash (different color to distinguish)

### Why It's the Final Stage

- **Complexity**: Cycling mechanic requires understanding shot-lit relationships
- **Skill**: Players can use skill shots (e.g., try the hard ramp multiple times)
- **Scoring**: 5M Jackpot is significant but not overwhelming
- **Time Pressure**: Original 60-second timer keeps pace
- **Replayability**: Cycling allows many different shot sequences

---

## SCORING BREAKDOWN

### Stage 1 (Roaming - 100K baseline)
- Base shot: 100K
- Progressive: 100K → 110K → 120K → ... → 180K
- Range: 100K to 1,350K total
- Xenos bonus: +50K per shot

### Stage 2 (Easy - 250K per shot)
- Each ramp/orbit: 250K
- Max Stage 2 shots: 5 × 250K = 1,250K
- Super Jackpot: 1M
- Range: 250K to 2,250K total

### Stage 3 (Final - 500K per shot)
- Each of 9 shots: 500K
- 5 shots needed: 5 × 500K = 2,500K
- Super Jackpot: 5M
- Range: 2,500K to 7,500K total

### Estimated Mode Total
- Perfect Stage 1 (all 9 hits + xenos): ~1.5M
- Perfect Stage 2 (5 shots + jackpot): ~2.25M
- Perfect Stage 3 (5 shots + jackpot): ~7.5M
- **Grand Total**: ~11.25M for flawless completion

This is reasonable for a 60-second mission.

---

## IMPLEMENTATION DETAILS

### Variables
- `tzeench_stage`: Current stage (1, 2, or 3)
- `tzeench_stage2_shots_hit`: Shots hit in Stage 2 (0-1, just needs 1)
- `tzeench_stage3_shots_hit`: Shots hit in Stage 3 (0-5, needs 5 for Jackpot)

### Event Triggers
- `tzeench_stage_2_start`: Transition from Stage 1 → Stage 2
- `tzeench_stage_3_start`: Transition from Stage 2 → Stage 3
- `tzeench_mode_complete`: Super Jackpot hit in Stage 3

### Shot Groups
- `tzeench_stage2_shots`: Center Ramp, Left Orbit, Right Orbit, Inner Loop Left, Inner Loop Right
- `tzeench_stage3_shots`: All 9 shots (above + Drop Target, Scoop, Jackpot, Snikt Target)

### Shot Profiles
- `tzeench_stage2_profile`: Flashing → On (ramp/orbit shots)
- `tzeench_stage3_profile`: Flashing → Lit → Flashing (on hit, resets to lit)
- `tzeench_jackpot_profile`: Unlit → Lit → On (lights after 5 shots)

### Sound Design
- **Stage 2 transition**: New audio (to distinguish from Stage 1)
- **Each Stage 2 shot**: Positive feedback sound (250K points)
- **Stage 2 Jackpot**: "Holy cat!" or Catwoman-themed callout
- **Stage 3 start**: Dramatic escalation audio
- **Each Stage 3 shot**: Intense feedback (500K points, cycling)
- **Stage 3 Jackpot**: "Ultimate victory" or climactic audio
- **Mode complete**: Triumphant fanfare (5M Jackpot hit)

---

## DESIGN RATIONALE

### Why This Structure?

1. **Stage 1 → Stage 2 is a relief**
   - Intensity drops (strobe off, GI lights on)
   - Mechanical complexity drops (only 5 shots)
   - Players feel they "passed" a challenge
   - Low-barrier entry to final stages

2. **Stage 2 is a "breather"**
   - Quick completion (1 shot to light Jackpot)
   - Moderate scoring (250K)
   - Allows players to rest before final challenge
   - Still requires skill (hitting one of 5 shots)

3. **Stage 3 is the "real" challenge**
   - All shots available (more options, more complexity)
   - 5-shot progression (moderate, achievable goal)
   - Cycling mechanic creates infinite replayability
   - Higher scoring (500K per shot, 5M Jackpot)

4. **Catwoman 2 structure matches Tzeench thematically**
   - Tzeench = Changer of Ways = things constantly shift
   - Cycling shots = constant change
   - Multiple paths to victory = "change of plans"

---

## TESTING CHECKLIST

- [ ] Stage 1 completes at 9 shots → transitions to Stage 2
- [ ] GI lights turn on at Stage 2 start
- [ ] Only 5 ramp/orbit shots enabled in Stage 2
- [ ] Any Stage 2 shot hit lights Super Jackpot
- [ ] Super Jackpot hit in Stage 2 → transitions to Stage 3
- [ ] All 9 shots enabled in Stage 3
- [ ] Stage 3 shots reset/relight after each hit
- [ ] Counter reaches 5 after 5 Stage 3 shots
- [ ] Super Jackpot lights after 5 Stage 3 shots
- [ ] Super Jackpot hit in Stage 3 → mode complete
- [ ] Scoring correct: 250K Stage 2, 500K Stage 3, 1M/5M Jackpots
- [ ] Shot cycling works (same shot can be hit multiple times)
- [ ] 60-second timer works throughout all stages
- [ ] Xenos target bonus still applies if hit in Stage 2/3

---

## FUTURE ENHANCEMENTS

1. **Audio progression**: Unique callouts per stage
2. **Visual effects**: Stage 2 uses one color scheme, Stage 3 another
3. **Difficulty modes**: Hard version (Stage 3 requires 7 shots instead of 5)
4. **Combo shots**: In Stage 3, hitting same shot twice in a row = 1.5M
5. **Mode goal integration**: Mode complete triggers "Catwoman defeated" sequence
6. **Multiball tie-in**: Jackpot could start Tzeench Multiball instead of just ending mode
