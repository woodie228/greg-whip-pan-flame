# Greg Whip Pan Flame

Greg Whip Pan Flame is a simple editor-style whip pan and zoom pan transition
for Autodesk Flame.

I wanted something I could quickly add to the timeline, tune fast, and keep
moving. This Matchbox supports directional whip pans, zoom-style moves, motion
blur, easing, blend width, and edge cleanup controls.

## Download

Use the packaged Matchbox file:

- `matchbox/greg_whip_pan.mx`

Source files are included too:

- `matchbox/greg_whip_pan.glsl`
- `matchbox/greg_whip_pan.xml`

## Install

Copy `greg_whip_pan.mx` into a Flame Matchbox shader folder.

Suggested folder:

```text
/opt/Autodesk/user/ryan_2026/matchbox/shaders/TRANSITIONS
```

Restart Flame or rescan Matchbox shaders if needed.

## Flame Workflow

1. Add `Greg Whip Pan` as a timeline transition between two clips.
2. Animate `Progress` from `0.0` to `1.0`.
3. Pick a `Direction`: left, right, up, down, or zoom.
4. Tune `Travel`, `Motion Blur`, `Blur Samples`, and `Blend Width`.

In Batch, connect the outgoing clip to the first input and the incoming clip to
the second input.

## Controls

- `Direction`: left/right/up/down slide or zoom.
- `Travel`: how far the clips move during the whip.
- `Motion Blur`: directional blur strength at the center of the move.
- `Blur Samples`: smoothness versus performance.
- `Zoom Blur`: radial blur strength for zoom pans.
- `Outgoing End Scale`: outgoing clip scale at the end of a zoom move.
- `Incoming Start Scale`: incoming clip scale at the start of a zoom move.
- `Blend Width`: how long the A/B blend lasts around the midpoint.
- `Mirror Edges`: mirrors beyond-frame pixels to avoid hard edge streaks.
- `Fill Gaps`: uses the opposite moving clip to fill exposed areas.
- `Easy Ease`: eases progress through the transition.
- `Mix`: blends between a simple transition and the full treatment.

## Starting Values

- `Travel`: `1.15`
- `Motion Blur`: `0.65`
- `Blur Samples`: `17`
- `Blend Width`: `0.18`
- `Zoom Blur`: `1.0` when `Direction` is `Zoom`
- `Outgoing End Scale`: `1.20` to `1.50` for zoom moves
- `Incoming Start Scale`: `0.60` to `0.90` for zoom moves

## Notes

This is built for GLSL 120 compatibility. If the transition feels too smeary,
lower `Motion Blur` first, then reduce `Travel`.
