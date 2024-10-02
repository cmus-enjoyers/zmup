const c = @import("root.zig").c;

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
    // AVERROR(ENOSYS)
    NoSys,
    //// AVERROR(ENODATA)
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

pub fn avFormatOpenInput(context: **c.AVFormatContext, url: []const u8, fmt: *const c.AVInputFormat, options: *?*c.AVDictionary) AVError!void {
    return switch (c.avformat_open_input(context, url, fmt, options)) {
        -12 => return AVError.NoMem,
        -22 => return AVError.InVal,
        -2 => return AVError.NoEnt,
        -5 => return AVError.Io,
        -1 => return AVError.Perm,
        -11 => return AVError.Again,
        -38 => return AVError.NoSys,
        -61 => return AVError.NoData,
        -110 => return AVError.TimedOut,
        -92 => return AVError.NoProToopT,
        -1094995529 => return AVError.InvalidData,
        -1313558101 => return AVError.Unknown,
        -1414092869 => return AVError.Exit,
        else => {},
    };
}
