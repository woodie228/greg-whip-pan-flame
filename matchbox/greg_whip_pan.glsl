#version 120

uniform sampler2D front1;
uniform sampler2D front2;

uniform float adsk_result_w;
uniform float adsk_result_h;

uniform float progress;
uniform int direction;
uniform float travel;
uniform float motion_blur;
uniform float blur_samples;
uniform float zoom_amount;
uniform float outgoing_zoom_scale;
uniform float incoming_zoom_scale;
uniform float blend_width;
uniform float mix_amount;
uniform bool mirror_edges;
uniform bool fill_gaps;
uniform bool easy_ease;
uniform bool show_motion_only;

vec2 mirror_uv(vec2 uv)
{
    vec2 wrapped = mod(abs(uv), 2.0);
    return mix(wrapped, 2.0 - wrapped, step(1.0, wrapped));
}

vec2 edge_uv(vec2 uv)
{
    if (mirror_edges) {
        return mirror_uv(uv);
    }
    return clamp(uv, vec2(0.0), vec2(1.0));
}

vec4 sample_clip(sampler2D tex, vec2 uv)
{
    return texture2D(tex, edge_uv(uv));
}

bool uv_inside(vec2 uv)
{
    return uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0;
}

vec4 sample_with_fill(sampler2D primary, sampler2D filler, vec2 primary_uv, vec2 filler_uv, vec2 unscaled_uv, bool zoom_fill_self)
{
    if (fill_gaps && !uv_inside(primary_uv)) {
        if (zoom_fill_self) {
            return sample_clip(primary, unscaled_uv);
        }
        return sample_clip(filler, filler_uv);
    }
    return sample_clip(primary, primary_uv);
}

vec2 zoom_uv(vec2 uv, float zoom)
{
    vec2 center = vec2(0.5);
    return center + (uv - center) / max(zoom, 0.0001);
}

vec2 direction_vector()
{
    if (direction == 4) {
        return vec2(0.0);
    }
    if (direction == 1) {
        return vec2(-1.0, 0.0);
    } else if (direction == 2) {
        return vec2(0.0, 1.0);
    } else if (direction == 3) {
        return vec2(0.0, -1.0);
    }
    return vec2(1.0, 0.0);
}

float smootherstep(float value)
{
    float x = clamp(value, 0.0, 1.0);
    return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

vec4 blurred_clip(sampler2D tex, sampler2D filler, vec2 uv, vec2 slide_offset, vec2 filler_offset, vec2 blur_vector, float primary_zoom, float filler_zoom, float primary_zoom_blur, float filler_zoom_blur, float samples, bool zoom_fill_self)
{
    vec4 accum = vec4(0.0);
    float total = 0.0;

    for (int i = 0; i < 33; ++i) {
        float fi = float(i);
        if (fi >= samples) {
            break;
        }

        float denom = max(samples - 1.0, 1.0);
        float centered = (fi / denom) - 0.5;
        float weight = 1.0 - abs(centered) * 1.35;
        weight = max(weight, 0.05);

        vec2 blur_offset = blur_vector * centered;
        float primary_sample_zoom = primary_zoom + primary_zoom_blur * centered;
        float filler_sample_zoom = filler_zoom + filler_zoom_blur * centered;
        vec2 unscaled_uv = uv - slide_offset - blur_offset;
        vec2 primary_uv = zoom_uv(unscaled_uv, primary_sample_zoom);
        vec2 filler_uv = zoom_uv(uv - filler_offset - blur_offset, filler_sample_zoom);
        accum += sample_with_fill(tex, filler, primary_uv, filler_uv, unscaled_uv, zoom_fill_self) * weight;
        total += weight;
    }

    return accum / max(total, 0.0001);
}

void main()
{
    vec2 resolution = vec2(max(adsk_result_w, 1.0), max(adsk_result_h, 1.0));
    vec2 uv = gl_FragCoord.xy / resolution;
    vec2 dir = direction_vector();
    bool zoom_direction = direction == 4;

    float linear_p = clamp(progress, 0.0, 1.0);
    float p = linear_p;
    if (easy_ease) {
        p = smootherstep(linear_p);
    }

    float frame_aspect = resolution.x / resolution.y;
    vec2 aspect_scale = vec2(1.0, frame_aspect);
    vec2 travel_uv = dir * aspect_scale * max(travel, 0.0);

    vec2 offset_a = travel_uv * p;
    vec2 offset_b = travel_uv * (p - 1.0);

    float outgoing_end_scale = 1.0;
    float incoming_start_scale = 1.0;
    float zoom_blur_amount = 0.0;
    if (zoom_direction) {
        outgoing_end_scale = max(outgoing_zoom_scale, 0.05);
        incoming_start_scale = max(incoming_zoom_scale, 0.05);
        zoom_blur_amount = max(zoom_amount, 0.0);
    }
    float zoom_a = mix(1.0, outgoing_end_scale, p);
    float zoom_b = mix(incoming_start_scale, 1.0, p);

    float velocity_shape = sin(p * 3.14159265);
    vec2 blur_vector = travel_uv * max(motion_blur, 0.0) * velocity_shape;
    float zoom_blur_scale = zoom_blur_amount * max(motion_blur, 0.0) * velocity_shape;
    float zoom_blur_a = (outgoing_end_scale - 1.0) * zoom_blur_scale;
    float zoom_blur_b = (1.0 - incoming_start_scale) * zoom_blur_scale;
    float samples = clamp(floor(blur_samples + 0.5), 1.0, 33.0);

    vec4 clip_a = blurred_clip(front1, front2, uv, offset_a, offset_b, blur_vector, zoom_a, zoom_b, zoom_blur_a, zoom_blur_b, samples, zoom_direction);
    vec4 clip_b = blurred_clip(front2, front1, uv, offset_b, offset_a, blur_vector, zoom_b, zoom_a, zoom_blur_b, zoom_blur_a, samples, zoom_direction);

    float width = max(blend_width, 0.001);
    float blend_b = smoothstep(0.5 - width, 0.5 + width, p);
    vec4 whipped = mix(clip_a, clip_b, blend_b);

    vec4 original_mix = mix(sample_clip(front1, zoom_uv(uv, zoom_a)), sample_clip(front2, zoom_uv(uv, zoom_b)), p);
    vec4 result = mix(original_mix, whipped, clamp(mix_amount, 0.0, 1.0));

    if (show_motion_only) {
        result = whipped;
    }

    gl_FragColor = result;
}
