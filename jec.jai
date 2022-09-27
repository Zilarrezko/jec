
v2i :: struct {
    x, y: int;
}
make_v2i :: (x: int, y: int) -> v2i {
    v: v2i = ---;
    v.x = x;
    v.y = y;
    return v;
}

v2 :: Vector2;
v3 :: Vector3;
v4 :: Vector4;

f32 :: float32;
f64 :: float64;

Rectangle :: struct {
    x0, y0: float32;
    x1, y1: float32;
}

// Specify RGB?
Color :: struct {
    e: [4]float;
    #place e;
    r, g, b, a: float;
    #place e;
    rgb: [3]float;
}

PI32 :: 3.14159265358927;

KILO :: (v: $T) -> T {
    return 1024*v;
}

MEGA :: (v: $T) -> T {
    return 1024*KILO(v);
}

GIGA :: (v: $T) -> T {
    return 1024*MEGA(v);
}

// Note(jesse): This isn't right... It's not asserting
invalid_path :: (loc := #caller_location) #expand {
    `assert(false, "invalid path", loc = loc);
}
invalid_case :: (loc := #caller_location) #expand {
    `assert(false, "invalid case", loc = loc);
}
unimplemented :: (loc := #caller_location) #expand {
    `assert(false, "not implemented", loc = loc);
}

transmute :: inline ($T: Type, var: $R) -> T {
    return cast,trunc(T)var;
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

round :: inline (n: float32) -> float32 {
    return cast(float32)(cast(s64)(n + 0.5));
}

round :: inline (n: float64) -> float64 {
    return cast(float64)(cast(s64)(n + 0.5));
}

sign :: (v: $T) -> T {
    if v < 0 return -1;
    else     return  1;
}

align_to :: (v: int, $align: int) -> int {
    #run {
        assert(is_power_of_two(align), "alignment isn't power of two");
    }

    return (v + (align - 1)) & ~(align - 1);
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
        assert(ts.count >= 0);
        cp, bytes, success = character_utf8_to_utf32(ts.data, ts.count);
        col += 1;
        bytes_in += bytes;
    }
    return fast_slice(s, utf8_start, utf8_end);
}

utf8_count :: (s: string) -> int {
    r: int;
    ts := s;
    while ts.count
    {
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
    while ts.count
    {
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
    for 0..filepath.count - 1
    {
        if filepath[it] == #char "\\" || filepath[it] == #char "/"
        {
            last = it + 1;
        }
    }
    return fast_slice(filepath, last, filepath.count);
}
file_part_no_ext :: (filepath: string) -> string {
    s := file_part(filepath);
    for 0..s.count - 1
    {
        if s[it] == #char "." return fast_slice(s, 0, it);
    }
    return s;
}
path_part :: (filepath: string) -> string {
    // Todo(jesse): More efficient to go backwards and exit at first seperator
    last: int;
    for 0..filepath.count - 1
    {
        if filepath[it] == #char "\\" || filepath[it] == #char "/"
        {
            last = it;
        }
    }
    return fast_slice(filepath, 0, last);
}
unix_seperators :: (filepath: *string) {
    for 0..filepath.count if filepath.data[it] == #char "\\"
    {
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
// Pool allocator

Pool_Flags :: enum_flags {
    none :: 0;
    expands :: 1;
}
Pool_Header :: struct {
    next: *Pool_Header;
}
Pool :: struct {
    mem: *void;
    chunk_size: int;
    alloc_size: int;
    free_list: *Pool_Header;
    next: *Pool;
    flags: Pool_Flags;
}

POOL_ALIGN :: 32;
POOL_HEADER_SIZE :: #run align_to(size_of(Pool_Header), POOL_ALIGN);
make_pool :: (count: int, $$chunk_size: int, flags: Pool_Flags = .none) -> Pool {
    r: Pool = ---;
    r.chunk_size = POOL_HEADER_SIZE + align_to(chunk_size, POOL_ALIGN);
    r.alloc_size = count*r.chunk_size;
    r.mem = alloc(r.alloc_size);
    r.next = null;
    r.flags = flags;
    free_all(*r);
    return r;
}

free_all :: (p: *Pool) {
    header: *Pool_Header = cast(*Pool_Header)align_to(cast(int)p.mem, POOL_ALIGN);
    p.free_list = header;
    count: int = p.alloc_size/p.chunk_size;
    for 0..count - 2 {
        header.next = cast(*Pool_Header)(cast(*u8)header + p.chunk_size);
        header = header.next;
    }
    header.next = null;
}

pool_alloc :: (p: *Pool, size: int) -> *void {
    r: *void;
    // assert(p.free_list != null);
    if p.free_list {
        assert(size <= (p.chunk_size - POOL_HEADER_SIZE));
        r = cast(*void)(cast(*u8)p.free_list + POOL_HEADER_SIZE);
        t := p.free_list; // Todo(jesse): Get rid of this?
        p.free_list = p.free_list.next;
        t.next = null; // Todo(jesse): Get rid of this?
    }
    else {
        if p.flags & .expands {
            if !p.next {
                pool_count := p.alloc_size/p.chunk_size;
                chunk_size := p.chunk_size - POOL_HEADER_SIZE;
                np := New(Pool);
                <<np = make_pool(pool_count, chunk_size);
                p.next = np;
            }
            return pool_alloc(p.next, size);
        }
        else {
            return null;
        }
    }
    return r;
}
pool_new :: (p: *Pool, $T: Type, $zero: bool = false) -> *T {
    r: *T = pool_alloc(p, size_of(T));
    #if zero
        memset(r, 0, size_of(T));
    return r;
}

pool_free :: (p: *Pool, a: *$T) {
    header := cast(*Pool_Header)((cast(*u8)a) - POOL_HEADER_SIZE);
    assert(header.next == null);
    tmp := p.free_list;
    p.free_list = header;
    p.free_list.next = tmp;
}

destroy_pool :: (p: *Pool) {
    n := p;
    while n {
        i := p.next;
        free(n.mem);
        n.chunk_size = 0; // Should cause an assert if someone allocates with the pool again
        n = i;
    }
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

ll_remove :: (f: **$T, l: **T, i: *T)
{
    if <<f == i
    {
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

Entropy :: struct {
    s: u64 = 0xB0A710ADBADC0DE;
}
g_entropy: Entropy;
seed_entropy :: (seed: u64) {
    g_entropy.s = seed;
}
seed_entropy :: (entropy: *Entropy, seed: u64) {
    entropy.s = seed;
}

PCG_DEFAULT_MULTIPLIER_64 :u64: 6_364_136_223_846_793_005;
PCG_DEFAULT_INCREMENT_64 :u64: 1_442_695_040_888_963_407;
pcg_xsh_rr :: () -> u32 {
    using g_entropy;
    os: u32 = (cast,trunc(u32)(s^(s >> 18) >> 27)) >>> (cast(u32)(s >> 59));
    g_entropy.s = s*PCG_DEFAULT_MULTIPLIER_64 + PCG_DEFAULT_INCREMENT_64;
    return os;
}

// If you literally need all speed
xorsh :: () -> u32 {
    using g_entropy;
    g_entropy.s ^= (s<<13)^(s>>7)^(s<<17);
    return cast,trunc(u32)g_entropy.s;
}
xorsh :: (entropy: *Entropy) -> u32 {
    using entropy;
    entropy.s ^= (s<<13)^(s>>7)^(s<<17);
    return cast,trunc(u32)entropy.s;
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
                array_unordered_remove_by_index(*profiler.elements, j);
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
                elem[i], elem[j] = swap(elem[i], elem[j]);
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
        cycles_str := tprint("%cyc", formatInt(it.cycles, digits_per_comma=3, comma_string=","));
        dots.count = max_dot_count - it.name.count - cycles_str.count;
        print("%0%0%\n", it.name, dots, cycles_str);
    }
}

/////////////////////////////////////
// Logging

////////////////////////////////
// More basic stuff

time_scope :: (scope_name: string = "unknown") #expand {
    start := current_time_monotonic();
    `defer {
        duration := current_time_monotonic() - start;
        log(tprint("% %us\n", scope_name, to_microseconds(duration)));
    }
}

tick_scope :: (scope_name: string = "unknown") #expand {
    start := rdtsc();
    `defer {
        end := rdtsc();
        log(tprint("% % cycles\n", scope_name, end - start));
    }
}

time_start :: () -> Apollo_Time {
    return current_time_monotonic();
}

time_elapsed :: (at: Apollo_Time) -> Apollo_Time {
    return current_time_monotonic() - at;
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
    get_seconds_elapsed :: inline (start: s64, end: s64) -> float64 {
        return (cast(float64)(end - start))/cast(float64)perf_freq;
    }
}

#scope_file

W :: #import "Windows";
#import "Machine_X64";

#import "Math";
#import "Unicode";
