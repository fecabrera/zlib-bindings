// example based on:
// https://blog.jyotiprakash.org/file-compression-and-decompression-in-c-using-zlib

import "libc/stdio";
import "libc/string";
import "zlib";
import "std";

const CHUNK = 16384;

fn compress_file(src: FILE*, dst: FILE*) {
    let flush: z_flush;
    let have: uint64;
    let next_in: byte[CHUNK];
    let next_out: byte[CHUNK];
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
    
    defer deflateEnd(&strm); // cleanup on every exit path

    while (true) {
        strm.avail_in = fread(next_in, 1, CHUNK, src) as uint32;
        println("strm.avail_in: %u", strm.avail_in);

        let err = ferror(src);
        if (err != 0) {
            println("ferror() returned %d", err);
            return;
        }

        flush = feof(src) != 0 ? z_flush::Z_FINISH : z_flush::Z_NO_FLUSH;
        println("flush: %d", flush);

        strm.next_in = next_in;

        while (true) {
            strm.avail_out = CHUNK;
            strm.next_out = next_out;

            ret = deflate(&strm, flush);
            have = CHUNK as uint64 - strm.avail_out;

            let err = ferror(dst);
            if (err != 0) {
                println("ferror() returned %d", err);
                return;
            }
            
            if (fwrite(next_out, 1, have, dst) != have)
                return;

            if (strm.avail_out != 0) break; // write done
        }

        if (flush == z_flush::Z_FINISH) break; // all done
    }
}

fn decompress_file(src: FILE*, dst: FILE*) {
    let have: uint64;
    let next_in: byte[CHUNK];
    let next_out: byte[CHUNK];
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

    defer inflateEnd(&strm); // cleanup on every exit path

    while (true) {
        strm.avail_in = fread(next_in, 1, CHUNK, src) as uint32;
        println("strm.avail_in: %u", strm.avail_in);

        let err = ferror(src);
        if (err != 0) {
            println("ferror() returned %d", err);
            return;
        }

        if (strm.avail_in == 0) break;
        strm.next_in = next_in;

        while (true) {
            strm.avail_out = CHUNK;
            strm.next_out = next_out;

            ret = inflate(&strm, z_flush::Z_NO_FLUSH);

            case (ret) {
            when z_status::Z_NEED_DICT,
                 z_status::Z_DATA_ERROR,
                 z_status::Z_MEM_ERROR:
                 println("inflate() returned %d", ret);
                 return;
            }

            have = CHUNK as uint64 - strm.avail_out;

            let err = ferror(dst);
            if (err != 0) {
                println("ferror() returned %d", err);
                return;
            }
            
            if (fwrite(next_out, 1, have, dst) != have)
                return;

            if (strm.avail_out != 0) break; // write done
        }
        
        if (ret == z_status::Z_STREAM_END) break; // all done
    }
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
