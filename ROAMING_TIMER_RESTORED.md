# ROAMING TIMER FIX - RESTORED 6-SECOND TIMING

## CORRECTION

You were right - the roaming shots should rotate **every 6 seconds on a timer**, not on every timer tick.

## WHAT I RESTORED

### 1. Added Back the 6-Second Roaming Timer
```yaml
timers:
  tzeench_roaming_advance:
    start_value: 6 # seconds
    end_value: 0
    direction: down
    tick_interval: 1s
    restart_on_complete: true
    start_running: true
```

**How it works**:
- Starts at 6 seconds
- Counts down every 1 second
- When it reaches 0, fires `timer_tzeench_roaming_advance_complete` event
- Automatically restarts (loops continuously)

### 2. Updated Shot Group to Use the Roaming Timer
```yaml
shot_groups:
  tzeench_roaming_shots:
    shots: [all 9 shots]
    rotate_events: timer_tzeench_roaming_advance_complete
    enable_events: mode_tzeench_started
    disable_events: timer_tzeench_mode_timer_complete
```

**How it works**:
- Shot group rotates (advances) every time the 6-second timer completes
- Smooth 6-second rotation automatically

### 3. Updated Shot Hit Events to Restart the Timer
```yaml
shot_tzeench_center_ramp_shot_hit:
  - variable_player|tzeench_shots_hit|add:1
  - variable_player|tzeench_shot_value|add:10000
  - scoring|score:current_player.tzeench_shot_value
  - timer_tzeench_roaming_advance_restart  # ← Restart timer
  - delay:15s|event:tzeench_reset_roaming_shots
```

**How it works**:
- When player hits the lit roaming shot, timer restarts
- Gives player another 6 seconds to hit the next position
- Creates urgency without rushing

---

## ROAMING SHOT TIMING FLOW

```
Timer Starts (6 seconds)
    ↓
Player Has 6 Seconds to Hit Lit Shot
    ↓
Timer Completes → Shot Group Rotates to Next Position
    ↓
New Shot Lights Up (roaming state)
    ↓
Timer Counts Down Again (6 seconds)
    
IF Player Hits Shot:
    → Timer Restarts (6 seconds from that moment)
    → Score awarded
    → 15-second reset timer starts
    
IF Player Misses:
    → Timer Completes normally
    → Shot auto-advances to next position
    → Player must hit that shot instead
```

---

## COMPARISON: BEFORE FIX vs AFTER

### ❌ BEFORE (Too Fast)
```yaml
rotate_events: timer_tzeench_mode_timer_tick
# Rotates every 1 second (60 times in 60s mode!)
# Way too fast - unplayable
```

### ✅ AFTER (Correct)
```yaml
rotate_events: timer_tzeench_roaming_advance_complete
# Rotates every 6 seconds (10 rotations total in 60s mode)
# Gives player 6 seconds per shot position
# Balanced difficulty
```

---

## KEY CONCEPT: Timer-Based Shot Rotation

This is the correct pattern for timed roaming shots:

1. **Create a separate timer** with desired duration (6 seconds)
2. **Make it restart automatically** (`restart_on_complete: true`)
3. **Use `rotate_events: timer_name_complete`** to rotate on timer completion
4. **Restart timer on shot hit** with `timer_name_restart`

This gives **player-responsive timing**:
- Shooting early? Timer restarts, giving them more time
- Timing out? Shot auto-rotates to next position
- Balanced difficulty progression

---

## FILES UPDATED

✅ `modes/tzeench/config/tzeench.yaml`
- Added `tzeench_roaming_advance` timer (6 seconds, restarting)
- Updated shot_groups to use `rotate_events: timer_tzeench_roaming_advance_complete`
- Updated all 9 roaming shot hit events to use `timer_tzeench_roaming_advance_restart`

---

## BUILD STATUS

✅ **No errors**
✅ **Timing restored**
✅ **Ready to play**

---

## GAMEPLAY TIMING

**Stage 1: Total Duration = 60 seconds**
- Roaming shot position changes every 6 seconds
- Up to 10 different roaming positions will cycle through
- Player needs to hit 9 shots total to advance
- Hit timing is critical - restarts the 6-second clock

**Example Play Sequence**:
```
0:00 - Center Ramp lights
0:06 - Auto-advance to Left Orbit (player didn't hit ramp)
0:06 - Left Orbit lights
0:08 - Player hits Left Orbit
       → Timer restarts to 6 seconds
       → Score: 100K + 10K progression
       → Shot count: 1/9
0:14 - Right Orbit lights
0:14 - Player hits Right Orbit
       → Timer restarts to 6 seconds
       → Score: 100K + 20K progression
       → Shot count: 2/9
... (continue until 9 shots hit)
```

---

## THANK YOU!

You caught my architectural mistake. The mode now has the correct **6-second timed roaming rotation** as originally designed. 🎯
