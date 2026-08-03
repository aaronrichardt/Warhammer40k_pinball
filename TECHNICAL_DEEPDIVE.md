# 🔧 TECHNICAL DEEP DIVE - WARHAMMER 40K PINBALL

## Mode Configuration Patterns

### Basic Mode Template
```yaml
#config_version=6
mode:
  start_events: [trigger_event]
  stop_events: [end_condition]
  priority: [100-300]

timers:
  mode_timer:
    start_value: 60  # seconds
    direction: down
    tick_interval: 1s
    start_running: true/false

shots:
  shot_name:
    switch: s_switch_name
    profile: shot_profile_name
    show_tokens:
      led: led_name
      color: color_name

event_player:
  trigger_event: resulting_events

variable_player:
  event_trigger:
    score: amount
    custom_var: value

sound_player:
  event_trigger:
    sound_name:
      action: play
      ducking:
        bus: voice
        attack: 0.3 sec
        attenuation: 100
        release_point: 2.0 sec
        release: 1.0 sec
```

---

## Chaos God Mode Implementation Comparison

### Khorne Mode (Reference Implementation)

**File:** modes/khorne/config/khorne.yaml (118 lines)

```yaml
Structure:
  ├─ Mode definition (timer, priority)
  ├─ Counters (center_ramp: 3, left_ramp: 3)
  ├─ Accruals (count to 3 for each ramp)
  ├─ Shots (7 shots defined)
  ├─ Shot groups (2 groups)
  ├─ Shot profiles (3 profiles)
  ├─ Variable player (scoring)
  └─ Event player (feature triggers)

Key Features:
  - Timer: 60 seconds
  - Primary mechanic: Ramp hit counters
  - Goal: Hit each ramp 3 times → unlock super jackpot
  - Scoring: 5K (ramp hit) → 25K (ramp complete) → 50K (super)
  - Integration: Posts "major_shots_relit" event
  - Events: Posts ball_lock_qualification_started

Strengths:
  - Clean implementation
  - Well-organized shot structure
  - Clear scoring progression
  - Proper event integration
```

### Tzeench Mode (Creative Pattern)

**File:** modes/tzeench/config/tzeench.yaml (160 lines)

```yaml
Structure:
  ├─ Mode definition
  ├─ Timer (60 sec, NOT auto-start)
  ├─ Counters (countdown: 50, 30, 60)
  ├─ Accruals (3 events → completion)
  ├─ Shots (placeholders: s_tempholder1/2/3)
  ├─ Event player (counter complete → fake switch)
  └─ Sound player (ducked voice at +2s)

Key Pattern:
  1. Spinner hit → counter_active event
  2. Counter decrements (50→49→...→0)
  3. Counter complete → logicblock event
  4. Event player posts s_tempholder_active
  5. Shot system sees as "hit"
  6. Scoring and shows trigger

This Pattern Enables:
  - Countdown mechanics (not standard shots)
  - Creative mode-specific behavior
  - Flexibility for unique mechanics
  - Integration with shot system rewards

Challenges:
  - Uses placeholder switches
  - Non-standard shot flow
  - Harder to debug
```

### Slan'esh Mode (Broken)

**File:** modes/slannesh/config/slannesh.yaml (160 lines)

```yaml
PROBLEM:
  - Contains header comment: "Prince of Pleasure (Number 6)"
  - But lines 28-93 are EXACT DUPLICATE of Tzeench config
  - Results in mixed mode logic
  - Shots hit wrong targets
  - Scoring logic confused

ACTUAL SLANNESH CONFIG:
  Only in lines 1-27 (mode definition)
  
FIX REQUIRED:
  1. Delete lines 28-93 (Tzeench duplicate)
  2. Implement proper Slan'esh mechanics
  3. Define unique shot structure
  4. Create proper scoring progression
```

---

## Multiball System Architecture

### dreadnought Multiball (Complex)

```yaml
Configuration:
  mode/dreadnought_multiball/config/dreadnought_multiball.yaml
  
Start Sequence:
  1. Qualify via dreadnought_multiball_qualifier
     └─ Mode must be active
  
  2. Hit 3 dreadnought lock shots
     ├─ s_dreadnought_lock1 → bd_dreadnought ball 1
     ├─ s_dreadnought_lock2 → bd_dreadnought ball 2
     └─ s_dreadnought_lock3 → bd_dreadnought ball 3
  
  3. multiball_lock_dreadnought_full event posts
     └─ bd_dreadnought now has 3 balls
  
  4. dreadnought mode starts
     ├─ Priority: 300 (highest)
     ├─ Activates: multiballs/dreadnought_multiball
     ├─ Starts: 3 balls in play
     └─ Duration: Until balls drain or mode stop

Gameplay:
  - All 3 balls on playfield simultaneously
  - Major shots lit for jackpot
  - Shoot-again: 20 seconds on drain
  - Combo multiplier on repeating hits
  - Ends when: balls_in_play reaches 0

Technical:
  - Ball device: bd_dreadnought
    ├─ Switches: s_dreadnought_lock1/2/3
    ├─ Eject coil: c_dreadnought_lock
    ├─ Enable time: 3s
    └─ Timeout: 3s
  
  - Servo: lock_servo
    ├─ Opens on ball entry
    └─ Closes on ball exit
```

### Waagh Multiball (Simpler)

```yaml
Configuration:
  mode/waagh_multiball/config/waagh_multiball.yaml

Start Sequence:
  1. Waagh mode completes → posts waagh_multiball_mode_start
  2. Multiball mode starts
     ├─ Priority: 300
     ├─ Starts: waagh_multiball
     └─ Ejects from bd_plunger (3 balls)
  
  3. 3 balls in play
     ├─ Orc-themed playfield effects
     ├─ Sound: "flashgitz-waaagh-sound-effect"
     └─ Ducking: Voice bus (attack 0.3s, release 1.0s)

Gameplay:
  - 3 balls simultaneously
  - Progressive jackpots
  - Shoot-again: 20 seconds
  - Ends when: multiball_waagh_multiball_ended posted

Technical:
  - No specific lock device
  - Launches from main plunger
  - Default ball control
```

---

## Counter System Usage

### How Counters Work

```yaml
counters:
  center_tzeench_spinner:
    count_events: s_center_spinner_active    # What triggers count
    starting_count: 50                       # Initial value
    count_interval: 1                        # Decrement amount
    direction: down                          # Toward 0
    count_complete_value: 0                  # When complete

Event Flow:
  1. s_center_spinner_active posted
  2. Counter increments: 50 → 49 → 48...
  3. When reaches 0
  4. Posts: logicblock_center_tzeench_spinner_complete
  5. Event player converts to: s_tempholder1_active
  6. Shot system sees as hit
  7. Show plays, score awarded
```

### Alternative Pattern (Khorne)

```yaml
counters:
  center_ramp:
    count_events: center_ramp_shot_hit      # Direct shot event
    starting_count: 0                       # Start at 0
    count_interval: 1                       # Count UP
    direction: up                           # Toward target
    count_complete_value: 3                 # Need 3 hits

Event Flow:
  1. center_ramp_shot_hit posted
  2. Counter increments: 0 → 1 → 2 → 3
  3. When reaches 3
  4. Posts: logicblock_center_ramp_complete
  5. Event triggers: "center_ramp_complete"
  6. Mode rewards completion
  7. Can reactivate or persist state
```

---

## Show Token Pattern

### Generic Flash Show

**File:** shows/generic_flash.yaml

```yaml
#show_version=6
- time: 0
  lights:
    (led): (color)        # Token: LED name, color

- time: "+1"
  lights:
    (led): off

[repeat pattern]

- time: "+1"
  lights:
    (led): stop           # End show
```

### Usage in Shots

```yaml
shots:
  center_ramp_shot:
    switch: s_center_ramp
    profile: generic_flash
    show_tokens:
      led: l_center_ramp_arrow    # Specific LED
      color: red                   # Specific color

When show plays:
  (led) → l_center_ramp_arrow
  (color) → red
  
Result:
  - Red LED flashes at center ramp arrow
  - Reusable for any LED/color combo
```

### Benefits

1. **Reusability** - One show for all flashing needs
2. **Flexibility** - Change LED/color per shot
3. **Maintainability** - Update show once, affects all
4. **Performance** - Fewer show files needed

---

## Event Hierarchy & Priority

### Mode-Based Events

```
Machine Level (Always):
  ├─ ball_started
  ├─ ball_ending
  ├─ ball_ended
  └─ switch_* (all switches)

Base Mode (Priority 100):
  ├─ Handles s_*_active scoring
  ├─ Manages playfield_multiplier
  ├─ Tracks bonus
  └─ Posts generic events

Chaos God Mode (Priority 200):
  ├─ Starts on mission selection
  ├─ Runs for 60 seconds
  ├─ Posts mode-specific events
  └─ Can post ball lock/hurry up

Multiball Mode (Priority 300):
  ├─ Takes over when active
  ├─ Manages ball tracking
  ├─ Controls jackpot logic
  └─ Posts multiball events
  
Utility Modes (Varies):
  ├─ Bonus (end of ball)
  ├─ Tilt (on tilt)
  ├─ Ball save (on drain)
  └─ Others (situational)
```

### Event Processing Order

```
When switch s_center_ramp hits:

1. base mode variable_player
   ├─ Scores: 2,000 × playfield_multiplier
   └─ Posts: s_center_ramp_active

2. Other modes listen to s_center_ramp_active
   ├─ Khorne: Increments ramp counter
   ├─ Tzeench: No effect (different switches)
   └─ Slan'esh: (Depends on implementation)

3. Additional modes in priority order
   └─ Higher priority modes override lower

4. Show player responds
   └─ Plays shot hit animation
```

---

## Variable Player Scoring Logic

### Basic Pattern

```yaml
variable_player:
  s_center_ramp_active:
    score: 2000 * current_player.playfield_multiplier
```

**Evaluation:**
1. Event posted: s_center_ramp_active
2. Variable player calculates: 2000 × playfield_multiplier
3. If multiplier is 1: Score += 2,000
4. If multiplier is 2: Score += 4,000
5. If multiplier is 3: Score += 6,000

### Mode-Based Scoring

```yaml
variable_player:
  spinners_shot_1stcomplete:
    score: 5000000 * current_player.playfield_multiplier
  spinners_shot_2ndcomplete:
    score: 10000000 * current_player.playfield_multiplier
  spinners_shot_3rdcomplete:
    score: 15000000 * current_player.playfield_multiplier
```

**Effect:**
- First shot hit: 5M points
- Second hit: Additional 10M points
- Third hit: Additional 15M points
- Total: 30M + mode completion bonus

---

## Sound Player with Ducking

### Pattern

```yaml
sound_player:
  event_trigger:
    sound_name:
      action: play
      volume: 1.0
      ducking:
        bus: voice
        attack: 0.3 sec       # Fade in time
        attenuation: 100      # Volume reduction (%)
        release_point: 2.0    # When to start fade out
        release: 1.0 sec      # Fade out duration
```

### Ducking Timeline

```
Music/Effects Level:

100% ─────────────────────────┐
      ↑ Attack                 │ Release
      │ (0.3s)                 │ (1.0s)
 80%  │                    ┌───┤───┐
      │                    │   │   │
  0% (Sound plays) ────────┴───┘   └──→ (Back to 100%)
      
Sound: ┌─────────────────────────────┐
       │ Voice/Voiceover playing     │
       └─────────────────────────────┘
```

### Example: Tzeench Mode

```yaml
sound_player:
  mission_select_tzeench_selected|2s:
    BlueSpinnerThenScoop_01:
      action: play
      volume: 1
      ducking:
        bus: voice
        attack: 0.3 sec
        attenuation: 0          # 0% attenuation = no ducking
        release_point: 2.0 sec
        release: 1.0 sec
```

**Effect:**
- At +2 seconds into mode
- Play Tzeench voiceover
- Music doesn't duck (attenuation: 0)
- Voice plays full volume

---

## Shot Profile State Machine

### Generic Flash Profile

```yaml
shot_profiles:
  generic_flash:
    states:
      - name: flashing
        show: "generic_flash"
      - name: hit
        show: "on"
    loop: true  # Returns to "flashing" after "hit"

State Transitions:
  Start: flashing
    │
    ├─ Shot hit → advance to: hit
    │             show: "on"
    │
    ├─ Hit show plays
    │
    └─ State loops → back to: flashing
                      show: "generic_flash"
```

### Final Shot Profile

```yaml
shot_profiles:
  final_shot_profile:
    states:
      - name: flashing
        show: "generic_flash"
      - name: hit
        show: "on"
    loop: false  # Does NOT loop, stays in "hit"

State Transitions:
  Start: flashing
    │
    ├─ Shot hit → advance to: hit
    │             show: "on"
    │
    └─ State stays in: hit
       (No more progression)
```

---

## Ball Device Flow

### Trough to Playfield

```
bd_trough (Home device)
  ├─ Holds 6 balls
  ├─ Monitors: s_trough1-6
  └─ On ball_starting:
      │
      ├─ Eject via: c_trough_eject
      │             (14ms pulse)
      │
      └─ Target: bd_plunger
          │
          ├─ Waits for: s_autoplunger activation
          │
          └─ Eject via: c_autoplunger
                        (12ms pulse)
                        
                └─ Target: playfield
                    │
                    └─ Ball now in play
```

### VUK Capture

```
bd_scoop (Mid-playfield)
  ├─ Monitors: s_scoop
  ├─ Auto-fire: false (manual control)
  └─ On manual eject:
      │
      ├─ Activates: c_scoop
      │
      └─ Ball returns to playfield

bd_right_vuk (Right side jackpot)
  ├─ Monitors: s_jackpot_vuk
  ├─ Eject via: c_jackpot_vuk (8ms pulse)
  └─ On ball enter:
      │
      ├─ Jackpot available?
      │  └─ Apply bonus scoring
      │
      └─ Eject back to playfield
```

### Multiball Lock

```
bd_dreadnought (dreadnought lock - 3 positions)
  ├─ Monitors: s_dreadnought_lock1, s_dreadnought_lock2, s_dreadnought_lock3
  ├─ Eject via: c_dreadnought_lock (16ms pulse)
  ├─ Eject time: 3s
  └─ On ball 3 locked:
      │
      ├─ Event: multiball_lock_dreadnought_full
      │
      └─ Prepare for multiball
          └─ All 3 balls ready to eject for MB
```

---

## Servo Control

### Ork Servo (Animation)

```yaml
ork_servo:
  platform_settings:
    min_us: 0          # Minimum pulse (0ms)
    home_us: 2400      # Home position
    max_us: 2500       # Maximum pulse
    max_runtime: 5s    # Safety timeout

  positions:
    0.4: ork_left      # 40% position = left
    0.6: ork_home      # 60% position = home (default)
    0.7: ork_right     # 70% position = right

  reset_events:
    - ball_starting    # Reset to home at ball start
    - ball_ending      # Reset to home at ball end

Usage:
  servo_ork_left:     # Move to position 0.4
  servo_ork_home:     # Move to position 0.6
  servo_ork_right:    # Move to position 0.7
```

### Lock Servo (Mechanical)

```yaml
lock_servo:
  platform_settings:
    home_us: 2400
    max_us: 2500
    max_runtime: 5s

  positions:
    0.2: lock_open     # 20% = open (ball can enter)
    1.0: lock_home     # 100% = closed (locked)

  reset_events:
    - ball_starting
    - ball_ending

Usage:
  servo_lock_open:    # Release ball
  servo_lock_home:    # Catch ball
```

---

## CPU Performance Considerations

**Light Config:**
- 50+ LEDs = ~50 light objects
- 15+ shows = ~15 show instances
- Minimal CPU impact

**Mode Complexity:**
- 28 modes, only 1-3 active = good performance
- Counter logic: Minimal overhead
- Event-driven system: Efficient

**Audio:**
- Ducking requires DSP = ~5% CPU
- Multiple sound instances ok
- Godot GMC handles rendering

**Recommendation:**
- Current system is performant
- Can handle more complex modes
- Monitor if adding 50+ more lights

---

**Generated:** Current Session
**Status:** Technical specifications documented ✅
