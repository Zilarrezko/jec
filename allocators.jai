
////////////////////////////////////////////////////
// Mandala Allocator


Mandala :: struct {
    mem: *u8;
    cur: int;
    cap: int;
}

MANDALA_ALIGN :: 8;
make_mandala :: (size: int) -> Mandala {
    m: Mandala = ---;
    m.mem = alloc(size); // Todo: Virtual Alloc
    m.cur = 0;
    m.cap = size;
    return m;
}


push_size :: (m: *Mandala, _size: int, $zero: bool = false) -> *void {
    size := (_size + MANDALA_ALIGN - 1) & ~(MANDALA_ALIGN - 1);
    assert(m.cur + size <= m.cap, "Mandala overtaken"); // Assert is slow
    r: *void = m.mem + m.cur;
    m.cur += size;
    return r;
}


free_all :: (m: *Mandala) {
    m.cur = 0;
}


destroy :: (m: *Mandala) {
    free(m.mem);
    <<m = .{};
}


////////////////////////////////////////////////////
// Ring Allocator


Ring :: struct {
    mem: *u8;
    cap: int;
    write: int;
}


make_ring :: (size: int) -> Ring {
    r: Ring;
    r.mem = alloc(size);
    r.cap = size;
    return r;
}


RING_ALIGN :: 8;
alloc :: (r: *Ring, _size: int) -> *void {
    size := (_size + RING_ALIGN - 1) & ~(RING_ALIGN - 1);
    assert(size <= r.cap, "Requested size is greater than ring size");
    // if size >= r.cap // Not sure if this would be the right call
    //     return null;
    if r.write + size > r.cap
        r.write = 0;
    result: *void = r.mem + r.write;
    r.write += size;
    return r.mem + r.write;
}


free_all :: (r: *Ring) #no_context {
    // LOL LMFAO
}


free :: (r: *Ring, p: *void) #no_context {
    // LOL LMFAO
}


destroy :: (r: *Ring) {
    free(r.mem);
    <<r = .{};
}


////////////////////////////////////////////////////
// Pool Allocator


Pool_Header :: struct {
    next: *Pool_Header;
}
Pool :: struct {
    mem: *void;
    chunk_size: int;
    alloc_size: int;
    free_list: *Pool_Header;
    next: *Pool;
}

POOL_ALIGN :: 8;
POOL_HEADER_SIZE :: #run align_to(size_of(Pool_Header), POOL_ALIGN);
make_pool :: (count: int, $$chunk_size: int) -> Pool {
    r: Pool = ---;
    r.chunk_size = POOL_HEADER_SIZE + align_to(chunk_size, POOL_ALIGN);
    r.alloc_size = count*r.chunk_size;
    r.mem = alloc(r.alloc_size);
    r.next = null;
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
    assert(p.free_list != null, "Out of pool slots");
    if p.free_list {
        assert(size <= (p.chunk_size - POOL_HEADER_SIZE));
        r = cast(*void)(cast(*u8)p.free_list + POOL_HEADER_SIZE);
        t := p.free_list; // Todo(jesse): Get rid of this?
        p.free_list = p.free_list.next;
        t.next = null; // Todo(jesse): Get rid of this?
    }
    return r;
}
pool_new :: (p: *Pool, $T: Type, $zero: bool = false) -> *T {
    r: *T = pool_alloc(p, size_of(T));
    #if zero {
        memset(r, 0, size_of(T));
    }
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
    free(p.mem);
    <<p = .{};
}
