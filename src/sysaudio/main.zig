// const std = @import("std");

// const c = @import("c");

// const MAX_CHANNELS = 2;

// var pcm_handle: *c.snd_pcm_t = undefined;
// var sample_rate: u32 = 0;
// var channels: u8 = 0;

// // -------- ALSA --------

// fn alsaInit() !void {
//     const err = c.snd_pcm_open(
//         &pcm_handle,
//         "default",
//         c.SND_PCM_STREAM_PLAYBACK,
//         0,
//     );
//     if (err < 0) return error.AlsaOpenFailed;

//     var hw: *c.snd_pcm_hw_params_t = undefined;
//     _ = c.snd_pcm_hw_params_malloc(&hw);
//     defer c.snd_pcm_hw_params_free(hw);

//     _ = c.snd_pcm_hw_params_any(pcm_handle, hw);
//     _ = c.snd_pcm_hw_params_set_access(
//         pcm_handle,
//         hw,
//         c.SND_PCM_ACCESS_RW_INTERLEAVED,
//     );

//     _ = c.snd_pcm_hw_params_set_format(
//         pcm_handle,
//         hw,
//         c.SND_PCM_FORMAT_FLOAT_LE,
//     );

//     var rate = sample_rate;
//     _ = c.snd_pcm_hw_params_set_rate_near(
//         pcm_handle,
//         hw,
//         &rate,
//         null,
//     );

//     _ = c.snd_pcm_hw_params_set_channels(
//         pcm_handle,
//         hw,
//         channels,
//     );

//     _ = c.snd_pcm_hw_params(pcm_handle, hw);
//     _ = c.snd_pcm_prepare(pcm_handle);
// }

// fn alsaWrite(frames: usize, data: []const f32) void {
//     const written = c.snd_pcm_writei(
//         pcm_handle,
//         data.ptr,
//         frames,
//     );

//     if (written < 0) {
//         _ = c.snd_pcm_prepare(pcm_handle);
//     }
// }

// // -------- FLAC --------

// fn writeCallback(
//     // decoder: ?*const c.FLAC__StreamDecoder,
//     frame: ?*const c.FLAC__Frame,
//     buffer: ?[*]const [*]const i32,
//     _: ?*anyopaque,
// ) callconv(.C) c.FLAC__StreamDecoderWriteStatus {
//     const f = frame.?;
//     const blocksize = f.header.blocksize;
//     const ch = f.header.channels;

//     var pcm: [4096 * MAX_CHANNELS]f32 = undefined;

//     var i: usize = 0;
//     while (i < blocksize) : (i += 1) {
//         var cidx: usize = 0;
//         while (cidx < ch) : (cidx += 1) {
//             const sample = buffer.?[cidx][i];
//             pcm[i * ch + cidx] =
//                 @as(f32, @floatFromInt(sample)) / 2147483648.0;
//         }
//     }

//     alsaWrite(blocksize, pcm[0 .. blocksize * ch]);
//     return c.FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
// }

// fn metadataCallback(
//     _: ?*const c.FLAC__StreamDecoder,
//     metadata: ?*const c.FLAC__StreamMetadata,
//     _: ?*anyopaque,
// ) callconv(.C) void {
//     if (metadata.?.type == c.FLAC__METADATA_TYPE_STREAMINFO) {
//         const info = metadata.?.data.stream_info;
//         sample_rate = info.sample_rate;
//         channels = info.channels;
//     }
// }

// fn errorCallback(
//     _: ?*const c.FLAC__StreamDecoder,
//     _: c.FLAC__StreamDecoderErrorStatus,
//     _: ?*anyopaque,
// ) callconv(.C) void {}

// // -------- main --------

// pub fn main() !void {
//     var gpa = std.heap.DebugAllocator(.{}){};
//     defer _ = gpa.deinit();

//     const args = try std.process.argsAlloc(gpa.allocator());
//     if (args.len < 2) {
//         std.debug.print("usage: play_flac <file.flac>\n", .{});
//         return;
//     }

//     const decoder = c.FLAC__stream_decoder_new() orelse return error.FLACInitFailed;
//     defer c.FLAC__stream_decoder_delete(decoder);

//     _ = c.FLAC__stream_decoder_inkt_file(
//         decoder,
//         args[1],
//         writeCallback,
//         metadataCallback,
//         errorCallback,
//         null,
//     );

//     _ = c.FLAC__stream_decoder_process_until_end_of_metadata(decoder);
//     try alsaInit();

//     _ = c.FLAC__stream_decoder_process_until_end_of_stream(decoder);
//     _ = c.snd_pcm_drain(pcm_handle);
//     _ = c.snd_pcm_close(pcm_handle);
// }
