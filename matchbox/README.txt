Greg Whip Pan Matchbox

Files:
- greg_whip_pan.glsl
- greg_whip_pan.xml
- greg_whip_pan.mx, if packaged with shader_builder

Install:
Copy the .glsl and .xml, or the packaged .mx, into a Flame Matchbox shader folder.
Suggested folder:
/opt/Autodesk/user/ryan_2026/matchbox/shaders/TRANSITIONS

Use:
As a timeline transition, apply it between two clips. In Batch, connect the
outgoing clip to the first input and the incoming clip to the second input.
Animate Progress from 0.0 to 1.0 over the transition.

Controls:
- Direction: Left To Right, Right To Left, Bottom To Top, Top To Bottom, or Zoom.
- Travel: how far the clips slide during the whip.
- Motion Blur: length of directional or radial blur at the center of the move.
- Blur Samples: smoothness/performance tradeoff.
- Zoom Blur: radial motion blur strength when Direction is set to Zoom.
- Outgoing End Scale: final scale for the outgoing clip in Zoom direction.
- Incoming Start Scale: starting scale for the incoming clip in Zoom direction.
  Values below 1.0 make the second input feel farther back in Z space.
- Blend Width: how long the A/B blend lasts around the midpoint.
- Mirror Edges: mirrors beyond-frame pixels to avoid black/clamped streaks.
- Fill Gaps: uses the opposite moving clip to fill areas exposed by the whip
  before Mirror Edges/clamping is used as a fallback. In Zoom direction, this
  fills exposed scaled edges with the same shot full-frame so the incoming shot
  does not feel like a hard rectangle in front of the frame.
- Easy Ease: remaps Progress so the move starts gently, speeds through the
  middle, and slows into the final frame.
- Mix: blends between a simple transition and the full whip-pan treatment.

Starting values:
- Travel: 1.15
- Motion Blur: 0.65
- Blur Samples: 17
- Zoom Blur: 1.0 when Direction is Zoom
- Outgoing End Scale: 1.20 to 1.50 when Direction is Zoom
- Incoming Start Scale: 0.60 to 0.90 when Direction is Zoom
- Blend Width: 0.18

Notes:
This is built for GLSL 120 compatibility. If the transition feels too smeary,
lower Motion Blur first, then reduce Travel.
