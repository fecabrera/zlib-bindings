// example based on:
// https://blog.jyotiprakash.org/file-compression-and-decompression-in-c-using-zlib

import "libc/stdio";
import "libc/string";
import "zlib";
import "std";

const CHUNK = 16384;

fn compress_file(src: FILE*, dst: FILE*) {
    let input: byte[CHUNK];
    let output: byte[CHUNK];
    let strm = struct z_stream {
        zalloc = null,
        zfree = null,
        opaque = null,
    };
        
    let ret = deflateInit(&strm, z_level::Z_DEFAULT_COMPRESSION);
    if (ret != z_status::Z_OK) {
        println("deflateInit() returned %d: %s", ret, strm.msg);
        return;
    }

    deflateEnd(&strm);
}

fn decompress_file(src: FILE*, dst: FILE*) {
    let input: byte[CHUNK];
    let output: byte[CHUNK];
    let strm = struct z_stream {
        zalloc = null,
        zfree = null,
        opaque = null,
    };

    let ret = inflateInit(&strm);
    if (ret != z_status::Z_OK) {
        println("deflateInit() returned %d: %s", ret, strm.msg);
        return;
    }

    inflateEnd(&strm);
}

fn main(argc: int32, argv: char**) -> int32 {
    if (argc != 4) {
        println("usage: %s <compress|decompress> <input> <output>", argv[0]);
        return 1;
    }
    
    let fnc: fn (FILE*, FILE*);
    if (strcmp(argv[1], "compress") == 0) {
        fnc = compress_file;
    } else if (strcmp(argv[1], "decompress") == 0) {
        fnc = decompress_file;
    } else {
        println("invalid operation: \"%s\"", argv[1]);
        return 1;
    }

    let input = fopen(argv[2], "rb");
    if (input == null) {
        println("could not open %s", argv[2]);
        return 1;
    }

    defer fclose(input);
    
    let output = fopen(argv[3], "wb");
    if (output == null) {
        println("could not open %s", argv[3]);
        return 1;
    }

    defer fclose(output);

    fnc(input, output);

    return 0;
}
