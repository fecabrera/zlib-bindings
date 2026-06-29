const ZLIB_VERSION = "1.2.12";
const ZLIB_VERNUM = 0x12c0;
const ZLIB_VER_MAJOR = 1;
const ZLIB_VER_MINOR = 2;
const ZLIB_VER_REVISION = 12;
const ZLIB_VER_SUBREVISION = 0;

enum z_flush: int32 {
    Z_NO_FLUSH      = 0,
    Z_PARTIAL_FLUSH = 1,
    Z_SYNC_FLUSH    = 2,
    Z_FULL_FLUSH    = 3,
    Z_FINISH        = 4,
    Z_BLOCK         = 5,
    Z_TREES         = 6,
}

enum z_status: int32 {
    Z_OK            = 0,
    Z_STREAM_END    = 1,
    Z_NEED_DICT     = 2,
    Z_ERRNO         = -1,
    Z_STREAM_ERROR  = -2,
    Z_DATA_ERROR    = -3,
    Z_MEM_ERROR     = -4,
    Z_BUF_ERROR     = -5,
    Z_VERSION_ERROR = -6,
}

enum z_level: int32 {
    Z_NO_COMPRESSION      = 0,
    Z_BEST_SPEED          = 1,
    Z_BEST_COMPRESSION    = 9,
    Z_DEFAULT_COMPRESSION = -1,
}

enum z_strategy {
    Z_FILTERED         = 1,
    Z_HUFFMAN_ONLY     = 2,
    Z_RLE              = 3,
    Z_FIXED            = 4,
    Z_DEFAULT_STRATEGY = 0,
}

enum z_type: int32 {
    Z_BINARY  = 0,
    Z_TEXT    = 1,
    Z_ASCII   = z_type::Z_TEXT,   /* for compatibility with 1.2.2 and earlier */
    Z_UNKNOWN = 2,
}

enum z_deflate {
    Z_DEFLATED = 8,
}

type alloc_func = fn (byte*, uint32, uint32) -> byte*;
type free_func = fn (byte*, byte*);

struct internal_state {}

struct z_stream {
    next_in: byte*;
    avail_in: uint32;
    total_in: uint64;
    next_out: byte*;
    avail_out: uint32;
    total_out: uint64;
    msg: char*;
    state: internal_state*;
    zalloc: alloc_func;
    zfree: free_func;
    opaque: byte*;
    data_type: z_type;
    adler: uint64;
    reserved: uint64;    
}

@extern
fn zlibVersion() -> char*;

@extern
fn deflateInit_(strm: z_stream*, level: z_level, version: char*, stream_size: int32) -> z_status;

@inline
fn deflateInit(strm: z_stream*, level: z_level) -> z_status {
    return deflateInit_(strm, level, ZLIB_VERSION, sizeof(z_stream) as int32);
}

@extern
fn deflate(strm: z_stream*, flush: z_flush) -> z_status;

@extern
fn deflateEnd(strm: z_stream*) -> z_status;

@extern
fn inflateInit_(strm: z_stream*, version: char*, stream_size: int32) -> z_status;

@inline
fn inflateInit(strm: z_stream*) -> z_status {
    return inflateInit_(strm, ZLIB_VERSION, sizeof(z_stream) as int32);
}

@extern
fn inflate(strm: z_stream*, flush: z_flush) -> z_status;

@extern
fn inflateEnd(strm: z_stream*) -> z_status;
