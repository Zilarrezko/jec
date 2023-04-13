
lengthsq :: (v: v2i) -> f32 {
    return cast(f32)(v.x*v.x + v.y*v.y);
}

length :: (v: v2i) -> f32 {
    return sqrt(lengthsq(v));
}

v2 :: Vector2;
v3 :: Vector3;
v4 :: Vector4;

f32 :: float32;
f64 :: float64;

v2i :: struct {
    x, y: int;
}
make_v2i :: (x: int, y: int) -> v2i #must {
    return v2i.{x, y};
}
make_v2 :: (x: f32, y: f32) -> v2 #must {
    return v2.{x, y};
}
V2 :: make_v2;
make_v2 :: (v: v2i) -> v2 #must {
    return v2.{xx v.x, xx v.y};
}

operator - :: (a: v2i, b: v2i) -> v2i {
    return v2i.{a.x - b.x, a.y - b.y};
}

operator + :: (a: v2i, b: v2i) -> v2i {
    return v2i.{a.x + b.x, a.y + b.y};
}

operator == :: (a: v2i, b: v2i) -> bool {
    return a.x == b.x && a.y == b.y;
}

operator * :: (a: v2i, s: f32) -> v2i #symmetric {
    return v2i.{xx(a.x*s), xx(a.y*s)};
}

operator * :: (a: v2i, s: int) -> v2i #symmetric {
    return v2i.{a.x*s, a.y*s};
}

lengthsq :: (v: v2) -> f32 {
    return v.x*v.x + v.y*v.y;
}

Rect :: struct {
    x0, y0: f32;
    x1, y1: f32;

    #place x0;
    xy: v2;
}

Recti :: struct {
    x0, y0: int;
    x1, y1: int;

    #place x0;
    xy: v2i;
}

operator + :: (r: Rect, x: f32) -> Rect #symmetric {
    return Rect.{r.x0 + x, r.y0 + x, r.x1 + x, r.y1 + x};
}

operator + :: (r: Rect, v: v2) -> Rect #symmetric {
    return Rect.{r.x0 + v.x, r.y0 + v.y, r.x1 + v.x, r.y1 + v.y};
}

operator + :: (r: Rect, v: v2i) -> Rect #symmetric {
    return Rect.{r.x0 + v.x, r.y0 + v.y, r.x1 + v.x, r.y1 + v.y};
}

operator - :: (r: Rect, v: v2) -> Rect {
    return Rect.{r.x0 - v.x, r.y0 - v.y, r.x1 - v.x, r.y1 - v.y};
}

operator - :: (r: Rect, v: v2i) -> Rect {
    return Rect.{r.x0 - v.x, r.y0 - v.y, r.x1 - v.x, r.y1 - v.y};
}

Color :: struct {
    r, g, b, a: f32;
    #place r;
    rgb: [3]f32;
    #place r;
    rgba: [4]f32;
    #place r;
    e: [4]f32;
}

KILO :: (v: $T) -> T {
    return 1024*v;
}

MEGA :: (v: $T) -> T {
    return 1024*KILO(v);
}

GIGA :: (v: $T) -> T {
    return 1024*MEGA(v);
}

decimal_crush :: (x: $T) -> f64, int {
    c: int;
    r: f64 = cast(f64)x;
    while r >= 1024.0 {
        r = r/1024.0;
        c += 1;
    }
    return r, c;
}

decimal_crush_as_string :: (x: $T, allocator := temp) -> string {
    r, c := decimal_crush(x);
    sb: String_Builder;
    sb.allocator = allocator;
    print_to_builder(*sb, "%", r);
    defer free_buffers(*sb);
    if c == {
        case 0; append(*sb, "");
        case 1; append(*sb, "K");
        case 2; append(*sb, "M");
        case 3; append(*sb, "G");
        case 4; append(*sb, "T");
        case 5; append(*sb, "P");
        case 6; append(*sb, "E");
        case 7; append(*sb, "Z");
        case;   append(*sb, "AL"); // A lot
    }
    return builder_to_string(*sb);
}

println :: (fmt: string = "", args: ..Any) -> int {
    sb: String_Builder;
    print_to_builder(*sb, fmt, ..args);
    append(*sb, #char"\n");
    return write_builder(*sb); // Returns bytes printed
}

// Note(jesse): This isn't right... It's not asserting
invalid_path :: inline (loc := #caller_location) {
    Basic.assert(false, "invalid path", loc = loc);
}
invalid_case :: inline (loc := #caller_location) {
    Basic.assert(false, "invalid case", loc = loc);
}
unimplemented :: inline (loc := #caller_location) {
    Basic.assert(false, "not implemented", loc = loc);
}

transmute :: ($T: Type, x: $R) -> T #expand #no_debug {
    return cast,trunc(T)x;
}

// more explicit encasing for casting out variable
as :: ($T: Type, x: $R) -> T #expand #no_debug {
    return cast(T)x;
}

/* Note(Jesse): Might do floats. so okay
next_power_of_two :: inline (x : $T) -> T {
    assert(x != 0);
    p: T = 1;
    while x > p p += p;
    return p;
}
*/

next_power_of_two :: inline (n: u32) -> u32 {
    r: u32 = n - 1;
    r |= r >> 1;
    r |= r >> 2;
    r |= r >> 4;
    r |= r >> 8;
    r |= r >> 16;
    return r + 1;
}

is_power_of_two :: inline (v: u32) -> bool {
    return v && !(v & (v - 1));
}

round :: inline (n: f32) -> f32 {
    return cast(f32)(cast(s64)(n + 0.5));
}

round :: inline (n: f64) -> f64 {
    return cast(f64)(cast(s64)(n + 0.5));
}

sign :: (v: $T) -> T {
    if v < 0 return -1;
    else     return  1;
}

smoothstep :: (a: f32, b: f32, t: f32) -> f32 {
    if t < 0
        return a;
    if t > 1
        return b;
    return (b - a)*(3.0 - 2.0*t)*t*t + a;
}

// byte_range_normalize_multiply
// normalized byte multiplication:
// range [0, 255] maps to [0.0, 1.0]
// examples:
// 0xff * 0xff = 0xff   (255 * 255 = 255)
// 0xff * 0x7f = 0x7f   (255 * 127 = 127)
// 0x7f * 0x7f = 0x3f   (127 * 127 =  63)
// 0x01 * 0xff = 0x01   (  1 * 255 =   1)
// 0x01 * 0x7f = 0x00   (  1 * 127 =   0)
nmul :: (a: u8, b: u8) -> u8 {
    return transmute(u8, ((as(u16, a) + 1)*b) >> 8);
}

align_to :: (v: int, $align: int) -> int #modify {
    return is_power_of_two(xx align);
} {

    return (v + (align - 1)) & ~(align - 1);
}

// Pretty much yoinked this from gingerBill, which might have changes from original yoink
LN10     :: 2.30258509299404568401799145468436421;
SQRT_TWO :: 1.41421356237309504880168872420969808;
log10 :: (x: f64) -> f64 { return ln(x)/LN10; } // Todo: test for accuracy and cycle count between these two
ln :: (x: f64) -> f64 {
    // The original C code, the long comment, and the constants
    // below are from FreeBSD's /usr/src/lib/msun/src/e_log.c
    // and came with this notice.
    //
    // ====================================================
    // Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
    //
    // Developed at SunPro, a Sun Microsystems, Inc. business.
    // Permission to use, copy, modify, and distribute this
    // software is freely granted, provided that this notice
    // is preserved.
    // ====================================================
    //
    // __ieee754_log(x)
    // Return the logarithm of x
    //
    // Method :
    //   1. Argument Reduction: find k and f such that
    //          x = 2**k * (1+f),
    //     where  sqrt(2)/2 < 1+f < sqrt(2) .
    //
    //   2. Approximation of log(1+f).
    //  Let s = f/(2+f) ; based on log(1+f) = log(1+s) - log(1-s)
    //       = 2s + 2/3 s**3 + 2/5 s**5 + .....,
    //           = 2s + s*R
    //      We use a special Reme algorithm on [0,0.1716] to generate
    //  a polynomial of degree 14 to approximate R.  The maximum error
    //  of this polynomial approximation is bounded by 2**-58.45. In
    //  other words,
    //              2      4      6      8      10      12      14
    //      R(z) ~ L1*s +L2*s +L3*s +L4*s +L5*s  +L6*s  +L7*s
    //  (the values of L1 to L7 are listed in the program) and
    //      |      2          14          |     -58.45
    //      | L1*s +...+L7*s    -  R(z) | <= 2
    //      |                             |
    //  Note that 2s = f - s*f = f - hfsq + s*hfsq, where hfsq = f*f/2.
    //  In order to guarantee error in log below 1ulp, we compute log by
    //      log(1+f) = f - s*(f - R)        (if f is not too large)
    //      log(1+f) = f - (hfsq - s*(hfsq+R)). (better accuracy)
    //
    //  3. Finally,  log(x) = k*Ln2 + log(1+f).
    //              = k*Ln2_hi+(f-(hfsq-(s*(hfsq+R)+k*Ln2_lo)))
    //     Here Ln2 is split into two floating point number:
    //          Ln2_hi + Ln2_lo,
    //     where n*Ln2_hi is always exact for |n| < 2000.
    //
    // Special cases:
    //  log(x) is NaN with signal if x < 0 (including -INF) ;
    //  log(+INF) is +INF; log(0) is -INF with signal;
    //  log(NaN) is that NaN with no signal.
    //
    // Accuracy:
    //  according to an error analysis, the error is always less than
    //  1 ulp (unit in the last place).
    //
    // Constants:
    // The hexadecimal values are the intended ones for the following
    // constants. The decimal values may be used, provided that the
    // compiler will convert from decimal to binary accurately enough
    // to produce the hexadecimal values shown.

    LN2_HI :: 0h3fe62e42_fee00000; // 6.93147180369123816490e-01
    LN2_LO :: 0h3dea39ef_35793c76; // 1.90821492927058770002e-10
    L1     :: 0h3fe55555_55555593; // 6.666666666666735130e-01
    L2     :: 0h3fd99999_9997fa04; // 3.999999999940941908e-01
    L3     :: 0h3fd24924_94229359; // 2.857142874366239149e-01
    L4     :: 0h3fcc71c5_1d8e78af; // 2.222219843214978396e-01
    L5     :: 0h3fc74664_96cb03de; // 1.818357216161805012e-01
    L6     :: 0h3fc39a09_d078c69f; // 1.531383769920937332e-01
    L7     :: 0h3fc2f112_df3e5244; // 1.479819860511658591e-01

    if isnan(x) || isinf(x) {
        return x;
    }
    else if x < 0 {
        return FLOAT64_NAN;
    }
    else if x == 0 {
        return -FLOAT64_INFINITY;
    }

    // reduce
    f1, ki := frexp(x);
    if f1 < SQRT_TWO/2 {
        f1 *= 2;
        ki -= 1;
    }
    f := f1 - 1;
    k := cast(f64)ki;

    // compute
    s  := f / (2 + f);
    s2 := s * s;
    s4 := s2 * s2;
    t1 := s2 * (L1 + s4*(L3+s4*(L5+s4*L7)));
    t2 := s4 * (L2 + s4*(L4+s4*L6));
    R  := t1 + t2;
    hfsq := 0.5 * f * f;
    return k*LN2_HI - ((hfsq - (s*(hfsq+R) + k*LN2_LO)) - f);
}

append :: inline (arr: *[..]$T, v: T) {
    array_add(arr, v);
}

join :: (allocator: Allocator, strs: ..string) -> string {
    Basic.push_allocator(allocator);
    return String.join(..strs);
}

character_utf32_to_utf8 :: (ch: u32, allocator: Allocator) -> string {
    Basic.push_allocator(allocator);
    return character_utf32_to_utf8(ch);
}

// Note(jesse): The idea is that basically if it would error, it just returns an empty string
safe_slice :: inline (s: string, start: int, end: int) -> string #must {
    if start < 0 || end < 0 {
        return "";
    }
    if start >= s.count return "";
    if end >= s.count {
         end = s.count - 1;
    }
    r: string = ---;
    r.data = s.data + start;
    r.count = end - start;
    return r;
}

fast_slice :: (s: string, start: int, end: int) -> string #must {
    r: string = ---;
    r.data = s.data + start;
    r.count = end - start;
    return r;
}

// Todo(jesse): maaaan utf8 sucks, why can't jon just write a cool function that does this functionality
safe_utf8_slice :: (s: string, start: int, end: int) -> string #must {
    if s.count == 0 return "";
    ts := s;
    utf8_start, utf8_end: int = -1;
    col, bytes_in: int;
    cp, bytes, success := character_utf8_to_utf32(ts.data, ts.count);
    while success == .CONVERSION_OK {
        if col == start
            utf8_start = bytes_in;
        if col == end {
            utf8_end = bytes_in + bytes;
            break; // Bad idea? Could start still be -1? Do we care?
        }
        ts.data += bytes;
        ts.count -= bytes;
        Basic.assert(ts.count >= 0);
        cp, bytes, success = character_utf8_to_utf32(ts.data, ts.count);
        col += 1;
        bytes_in += bytes;
    }
    return fast_slice(s, utf8_start, utf8_end);
}

utf8_count :: (s: string) -> int {
    r: int;
    ts := s;
    while ts.count {
        w := trailingBytesForUTF8[<<ts.data] + 1;
        r += 1;
        ts.data += w;
        ts.count -= w;
    }
    return r;
}

// returns: index, utf8 byte length
utf8_index :: (s: string, index: int) -> int, int {
    r, w, col: int;
    ts := s;
    while ts.count {
        w = trailingBytesForUTF8[<<ts.data] + 1;
        if col == index break;
        col += 1;
        r += w;
        ts.data += w;
        ts.count -= w;
    }
    return r, w;
}

// Todo(jesse): Unicode Version?
// Note(jesse): This is the more C-like that isn't an in-place replacement like Jon's stdlib
tolower :: (c: u8) -> u8 {
    return ifx c >= #char "A" && c <= #char "Z" then c | 32 else c;
}
toupper :: (c: u8) -> u8 {
    return ifx c >= #char "a" && c <= #char "z" then c &~ cast(u8)32 else c;
}

file_part :: (filepath: string) -> string {
    // Todo(jesse): More efficient to go backwards and exit at first seperator
    last: int;
    for 0..filepath.count - 1 {
        if filepath[it] == #char "\\" || filepath[it] == #char "/"
            last = it + 1;
    }
    return fast_slice(filepath, last, filepath.count);
}
file_part_no_ext :: (filepath: string) -> string {
    s := file_part(filepath);
    for 0..s.count - 1 {
        if s[it] == #char "."
            return fast_slice(s, 0, it);
    }
    return s;
}
path_part :: (filepath: string) -> string {
    // Todo(jesse): More efficient to go backwards and exit at first seperator
    last: int;
    for 0..filepath.count - 1 {
        if filepath[it] == #char "\\" || filepath[it] == #char "/"
            last = it;
    }
    return fast_slice(filepath, 0, last);
}
unix_seperators :: (filepath: *string) {
    for 0..filepath.count - 1 {
        if filepath.data[it] == #char "\\"
            filepath.data[it] = #char "/";
    }
}

jec_advance :: inline (s: *string, n: int = 1) {
    s.data += n; s.count -= n;
}

is_eol :: inline (c: u8) -> bool {
    return c == #char "\r" || c == #char "\n";
}

is_whitespace :: (cp: u8) -> bool {
    return cp == #char " " || cp == #char "\t" || cp == #char "\r" || cp == #char "\n";
}
is_whitespace :: (cp: u32) -> bool {
    return cp == #char " " || cp == #char "\t" || cp == #char "\r" || cp == #char "\n";
}

repeat :: (s: string, c: int, allocator: Allocator = temp) -> string {
    r: string = ---;
    r.count = c*s.count;
    r.data = alloc(r.count, allocator);
    for i: 0 .. c - 1 {
        for j: 0 .. s.count - 1 {
            r.data[i*s.count + j] = s.data[j];
        }
    }
    return r;
}

normalize :: (v: *Vector2) {
    len := sqrt(dot(<<v, <<v));
    <<v *= 1.0/len;
}

MURMUR_SEED :u32: 0xa3c91521;

murmur32 :: (key: []u8, seed: u32 = MURMUR_SEED) -> u32 {
    scrambler :: (k: u32) -> u32 {
        c1: u32 : 0xcc9e2d51;
        c2: u32 : 0x1b873593;
        r1: int : 15;
        k = k*c1;
        k = k <<< r1;
        k = k*c2;
        return k;
    }

    h: u32 = seed;

    bytes: *u32 = cast(*u32)key.data;
    for 0..key.count/4 - 1 {
        k: u32 = bytes[it];
        k = scrambler(k);
        h = h^k;
        h = h <<< 13;
        h = h*5 + 0xe6546b64;
    }

    used_size := (key.count/4)*4;
    rem := key;
    rem.data += used_size;
    rem.count -= used_size;
    k1: u32;
    if rem.count == {
        case 3;
            k1 ^= cast(u32)(rem[2]) << 16;
            #through;
        case 2;
            k1 ^= cast(u32)(rem[1]) << 8;
            #through;
        case 1;
            k1 ^= cast(u32)(rem[0]);
            k1 = scrambler(k1);
            h = h^k1;
    }
    h = h^cast(u32)key.count;
    h = h^(h >> 16);
    h = h*0x85ebca6b;
    h = h^(h >> 13);
    h = h*0xc2b2ae35;
    h = h^(h >> 16);
    return h;
}

itoa :: (i: int) -> string {
    // Making this function because I don't think jon has one
    ascii_string: string = "                                 !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ";
    return fast_slice(ascii_string, i, 1);
}

////////////////////////////////////////////////////
// Linked list things?
// Doubly linked because why not

// I'll probably make it so you can rename prev and next at a later time
ll_append :: (f: **$T, l: **T, i: *T) {
    if !<<f {
        <<f = i;
        <<l = i;
        (<<f).prev = null;
        (<<f).next = null;
    }
    else {
        (<<l).next = i;
        i.prev = <<l;
        i.next = null;
        <<l = i;
    }
}

ll_remove :: (f: **$T, l: **T, i: *T) {
    if <<f == i {
        <<f = (<<f).next;
        (<<f).prev = null;
    }
    else if <<l == i {
        (<<l) = (<<l).prev;
        (<<l).next = null;
    }
    else {
        i.prev.next = i.next;
        i.next.prev = i.prev;
    }
}

////////////////////////////////////////////////////
// Random/Entropy

Entropy :: u64;
g_entropy: Entropy = 0xB0A710ADBADC0DE;

PCG_DEFAULT_MULTIPLIER_64 :u64: 6_364_136_223_846_793_005;
PCG_DEFAULT_INCREMENT_64 :u64: 1_442_695_040_888_963_407;
pcg_xsh_rr :: () -> u32 {
    os: u32 = (cast,trunc(u32)(g_entropy^(g_entropy >> 18) >> 27)) >>> (cast(u32)(g_entropy >> 59));
    g_entropy = g_entropy*PCG_DEFAULT_MULTIPLIER_64 + PCG_DEFAULT_INCREMENT_64;
    return os;
}

// If you literally need all speed
xorsh :: inline () -> u32 {
    return xorsh(*g_entropy);
}
xorsh :: (e: *Entropy) -> u32 {
    <<e ^= (<<e<<13)^(<<e>>7)^(<<e<<17);
    return cast,trunc(u32)e;
}

random_proc :: pcg_xsh_rr;
random_unilateral :: () -> f32 {
    return (cast(f32)random_proc()/cast(f32)U32_MAX);
}
random_bilateral :: () -> f32 {
    return cast(f32)((cast(f64)random_proc()/cast(f64)U32_MAX)*2.0 - 1.0);
}
random_int :: (low: int, high: int) -> int {
    return low + random_proc()%(high - low + 1);
}
random_u32 :: () -> u32 {
    return random_proc();
}
random_f32 :: (low: f32, high: f32) -> f32 {
    return (low + random_unilateral()*(high - low));
}
random_bool :: () -> bool {
    return transmute(bool, random_proc()&1);
}

///////////////////////////////////////////////
// Algorithms

str :: (s_: *string, body: Code, flags: For_Flags) #expand {
    if !<<s_ then return;
    s := <<s_;
    i := 0;
    while true {
        cp, ok := utf8_next_character(*s);
        if ok != .CONVERSION_OK then break;
        `it := cp;
        `it_index := i;
        #insert body;
        i += 1;
    }
}

/////////////////////////////////////////////////
// Timing/Profiling

// Profiling for more indepth timing
Profiler_Element :: struct {
    name: string;
    cycles: u64;
    hits: u32;
}

Profiler :: struct {
    elements: [..]Profiler_Element;
}

profiler: Profiler;

profile_scope :: ($scope_name: string = "") #expand {
    `_elem: Profiler_Element = ---;

    #if scope_name == "" {
        `_elem.name = context.stack_trace.info.name;
    }
    else {
        `_elem.name = scope_name;
    }

    _elem.hits = 0;
    start_cycles := rdtsc();

    `profile_hit :: () #expand {
        _elem.hits += 1;
    }

    `defer {
        end_cycles := rdtsc();
        _elem.cycles = end_cycles - start_cycles;
        if _elem.hits == 0
            _elem.hits = 1;
        array_add(*profiler.elements, _elem);
    }
}

profile_end_frame :: () {
    elem := profiler.elements;
    // Condense
    i := 0;
    while i < elem.count - 1 {
        j := i + 1;
        while j < elem.count {
            if elem[i].name.data == elem[j].name.data {
                elem[i].cycles += elem[j].cycles;
                elem[i].hits += elem[j].hits;
                Basic.array_unordered_remove_by_index(*profiler.elements, j);
                elem = profiler.elements;
                j -= 1;
            }
            j += 1;
        }
        i += 1;
    }

    // Naive sort
    for i: 0..elem.count - 2 {
        for j: i + 1..elem.count - 1 {
            if elem[i].cycles < elem[j].cycles {
                elem[i], elem[j] = Basic.swap(elem[i], elem[j]);
            }
        }
    }
}

reset_profiler :: () {
    profiler.elements.count = 0;
}

dump_profiler :: () {
    dots := "....................................................";
    max_dot_count := dots.count;
    for profiler.elements {
        cycles_str := Basic.tprint("%cyc", Basic.formatInt(it.cycles, digits_per_comma=3, comma_string=","));
        dots.count = max_dot_count - it.name.count - cycles_str.count;
        Basic.print("%0%0%\n", it.name, dots, cycles_str);
    }
}

/////////////////////////////////////
// Logging

////////////////////////////////
// More basic stuff

time_scope :: (scope_name: string = "unknown") #expand #no_debug {
    start := current_time_monotonic();
    `defer {
        duration := current_time_monotonic() - start;
        log(Basic.tprint("% %us\n", scope_name, to_microseconds(duration)));
    }
}

tick_scope :: (scope_name: string = "unknown") #expand #no_debug {
    start := rdtsc();
    `defer {
        end := rdtsc();
        log(Basic.tprint("% % cycles\n", scope_name, end - start));
    }
}

Tick_Profile_Result :: struct {
    name: string;
    start: u64;
    hits: int;
}
tick_start :: (name: string) -> Tick_Profile_Result #expand #no_debug {
    r: Tick_Profile_Result;
    r.name = name;
    r.start = rdtsc();
    r.hits = 1;
    return r;
}

tick_end :: (r: Tick_Profile_Result) {
    cycles := rdtsc() - r.start;
    hits := max(r.hits - 1, 1);
    log(Basic.tprint("% % cycles, % cyc/hit\n", r.name, cycles, cast(f64)cycles/cast(f64)hits));
}

time_start :: () -> Basic.Apollo_Time {
    return Basic.current_time_monotonic();
}

time_elapsed :: (at: Basic.Apollo_Time) -> Basic.Apollo_Time {
    return Basic.current_time_monotonic() - at;
}

#if OS == .WINDOWS {
    perf_freq: s64;

    init_wall_clock :: () {
        W.QueryPerformanceFrequency(*perf_freq);
    }
    // :Zak
    get_wall_clock :: inline () -> s64 {
        result: s64;
        W.QueryPerformanceCounter(*result);
        return result;
    }
    get_seconds_elapsed :: inline (start: s64, end: s64) -> f64 {
        return (cast(f64)(end - start))/cast(f64)perf_freq;
    }
}


//////////////////////////////////
//  Static Array

Static_Array :: struct($T: Type, n: int) {
    arr: [n]T;
    cur: int;
}

append :: inline (sa: *Static_Array($T, $n), v: T) {
    array_add(sa, v);
}
array_add :: (sa: *Static_Array($T, $n), v: T) {
    assert(sa.cur < n, "overblown static array");
    sa.arr[sa.cur] = v;
    sa.cur += 1;
}

peek :: (arr: Static_Array($T, $n)) -> T {
    r: T = ---;
    if arr.cur > 0
        r = arr.arr[arr.cur - 1];
    else
        r = T.{};
    return r;
}

unordered_remove :: inline (arr: *Static_Array($T, $n), i: int) {
    array_unordered_remove_by_index(arr, i);
}
array_unordered_remove_by_index :: (arr: *Static_Array($T, $n), i: int) {
    arr.arr[i] = arr.arr[arr.cur - 1];
    arr.cur -= 1;
}

ordered_remove :: inline (arr: *Static_Array($T, $n), i: int) {
    array_ordered_remove_by_index(arr, i);
}
array_ordered_remove_by_index :: (arr: *Static_Array($T, $n), i: int) {
    for k : i + 1..arr.cur - 1 {
        arr.arr[k - 1] = arr.arr[k];
    }
    arr.cur -= 1;
}

////////////////////////////////////
// NOISE


perlin_unilateral :: inline (v: v2) -> f32 {
    return (perlin_bilateral(v) + 1.0)/2.0;
}
perlin_unilateral :: inline (x: f32, y: f32) -> f32 {
    return (perlin_bilateral(x, y) + 1.0)/2.0;
}
perlin_bilateral :: perlin;
perlin :: inline (v: v2) -> f32 {
    return perlin(v.x, v.y);
}
perlin :: (x: f32, y: f32) -> f32 {
    interpolate :: lerp; // For some reason lerp is the only thing giving good values
    spall_scope("perlin");
    x0: int = cast(int)x;
    y0: int = cast(int)y;
    x1 := x0 + 1;
    y1 := y0 + 1;
    dx: f32 = x - cast(f32)x0;
    dy: f32 = y - cast(f32)y0;
    g0 := dot_gradient(x0, y0, x, y);
    g1 := dot_gradient(x1, y0, x, y);
    v0 := interpolate(g0, g1, dx);
    g0  = dot_gradient(x0, y1, x, y);
    g1  = dot_gradient(x1, y1, x, y);
    v1 := interpolate(g0, g1, dx);
    val := interpolate(v0, v1, dy);
    return val;
}
dot_gradient :: (ix: int, iy: int, x: f32, y: f32) -> f32 {
    grad: v2 = ---;
    a: u32 = cast,trunc(u32)ix;
    b: u32 = cast,trunc(u32)iy;
    w := 8*size_of(u32);
    s := w/2;
    a *= 3284157443;
    b ^= a <<< s;
    b *= 1911520717;
    a ^= b <<< s;
    a *= 2048419325;
    r: f32 = cast(f32)(a*(PI32/S32_MIN));
    grad.x = cos(r);
    grad.y = sin(r);
    d: v2 = ---;
    d.x = x - cast(f32)ix;
    d.y = y - cast(f32)iy;
    return dot(d, grad);
}

curl :: (v: v2) -> v2 {
    spall_scope("curl");
    eps := 0.0001;
    n1 := perlin(v.x + eps, v.y);
    n2 := perlin(v.x - eps, v.y);
    a := (n1 - n2)/(2*eps);
    n1 = perlin(v.x, v.y + eps);
    n2 = perlin(v.x, v.y - eps);
    b := (n1 - n2)/(2*eps);
    return v2.{b, -a};
}

#load "allocators.jai";
#load "sorting.jai";

#scope_file

Basic :: #import "Basic";

W :: #import "Windows";
#import "Machine_X64";

#import "Math";
#import "Unicode";
String :: #import "String";
