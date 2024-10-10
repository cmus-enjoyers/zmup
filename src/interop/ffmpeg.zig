const c = @import("../root.zig").c;

pub const AVError = error{
    /// AVERROR(ENOMEM)
    NoMem,
    /// AVERROR(EINVAL)
    InVal,
    /// AVERROR(ENOENT)
    NoEnt,
    /// AVERROR(EIO)
    Io,
    /// AVERROR(EPERM)
    Perm,
    /// AVERROR(EAGAIN)
    Again,
    /// AVERROR(ENOSYS)
    NoSys,
    /// AVERROR(ENODATA)
    NoData,
    /// AVERROR(ETIMEDOUT)
    TimedOut,
    /// AVERROR(ENOPROTOOPT)
    NoProToopT,
    /// AVERROR_INVALIDDATA
    InvalidData,
    /// AVERROR_UNKNOWN
    Unknown,
    /// AVERROR_EXIT
    Exit,
};

pub fn convertError(code: c_int) AVError!void {
    return switch (code) {
        -12 => AVError.NoMem,
        -22 => AVError.InVal,
        -2 => AVError.NoEnt,
        -5 => AVError.Io,
        -1 => AVError.Perm,
        -11 => AVError.Again,
        -38 => AVError.NoSys,
        -61 => AVError.NoData,
        -110 => AVError.TimedOut,
        -92 => AVError.NoProToopT,
        -1094995529 => AVError.InvalidData,
        -1313558101 => AVError.Unknown,
        -1414092869 => AVError.Exit,
        else => {},
    };
}

pub fn avFormatOpenInput(context: [*c][*c]c.AVFormatContext, url: [*c]const u8, fmt: [*c]const c.AVInputFormat, options: [*c]?*c.AVDictionary) AVError!void {
    return convertError(c.avformat_open_input(context, url, fmt, options));
}

pub fn avFormatFindStreamInfo(context: [*c]c.AVFormatContext, options: [*c]?*c.AVDictionary) AVError!void {
    return convertError(c.avformat_find_stream_info(context, options));
}
