const std = @import("std");
const lib = @cImport({
    @cInclude("alsa/asoundlib.h");
});

const SAMPLE_RATE = 44_100;
const CHANNELS = 1;
const DEFAULT_LATENCY = 50_000;
const MIN_SAMPLE_RATE = 8_000;
const MAX_SAMPLE_RATE = 5_644_800;

fn checkError(result: c_int) !void {
    if (result < 0) {
        std.log.err("{s}", .{lib.snd_strerror(result)});
        return error.AlsaError;
    }
}

pub fn init() !void {
    var pcm: ?*lib.snd_pcm_t = null;
    const snd_stream = lib.SND_PCM_STREAM_PLAYBACK;
    var params: ?*lib.snd_pcm_hw_params_t = null;

    try checkError(lib.snd_pcm_open(&pcm, "default", snd_stream, 0));
    defer _ = lib.snd_pcm_close(pcm);

    try checkError(lib.snd_pcm_hw_params_malloc(&params));
    defer lib.snd_pcm_hw_params_free(params);
    try checkError(lib.snd_pcm_hw_params_any(pcm, params));

    try checkError(lib.snd_pcm_set_params(
        pcm,
        lib.SND_PCM_FORMAT_U8,
        lib.SND_PCM_ACCESS_RW_INTERLEAVED,
        CHANNELS,
        SAMPLE_RATE,
        1,
        DEFAULT_LATENCY,
    ));
    play(pcm);
    _ = lib.snd_pcm_drain(pcm);
}

pub fn play(pcm: ?*lib.snd_pcm_t) void {
    _ = pcm;
    const rand = std.crypto.random;

    const buffer_length = 1024 * 16;
    var buffer: [buffer_length]c_int = undefined;

    for (0..buffer_length) |i| {
        buffer[i] = rand.int(c_int) & 0xff;
    }

    for (0..16) |i| {
        _ = i;
        _ = lib.snd_pcm_writei(
            pcm,
            &buffer,
            buffer_length,
        );
    }
}

fn decodeFlacStream() void {}
fn writeCallback() void {}
