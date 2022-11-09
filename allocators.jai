
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
    m.mem = Basic.alloc(size); // Todo: Virtual Alloc
    m.cur = 0;
    m.cap = size;
    return m;
}


push_size :: (m: *Mandala, _size: int, $zero: bool = false) -> *void {
    size := (_size + MANDALA_ALIGN - 1) & ~(MANDALA_ALIGN - 1);
    Basic.assert(m.cur + size <= m.cap, "Mandala overtaken"); // Assert is slow
    r: *void = m.mem + m.cur;
    m.cur += size;
    return r;
}


free_all :: (m: *Mandala) {
    m.cur = 0;
}


destroy :: (m: *Mandala) {
    Basic.free(m.mem);
    <<m = .{};
}



mandala_allocator_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory_pointer: *void, proc_data: *void) -> *void {
    r: *void;
    if #complete mode == {
        case .ALLOCATE; r = push_size(cast(*Mandala)proc_data, size);
        case .RESIZE;   invalid_case();
        case .FREE;
    }
    return r;
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
    r.mem = Basic.alloc(size);
    r.cap = size;
    return r;
}


RING_ALIGN :: 8;
alloc :: (r: *Ring, _size: int) -> *void {
    size := (_size + RING_ALIGN - 1) & ~(RING_ALIGN - 1);
    Basic.assert(size <= r.cap, "Requested size is greater than ring size");
    // if size >= r.cap // Not sure if this would be the right call
    //     return null;
    if r.write + size > r.cap
        r.write = 0;
    result: *void = r.mem + r.write;
    r.write += size;
    return result;
}


free_all :: (r: *Ring) #no_context {
    // LOL LMFAO
}


free :: (r: *Ring, p: *void) #no_context {
    // LOL LMFAO
}


destroy :: (r: *Ring) {
    Basic.free(r.mem);
    <<r = .{};
}


ring_allocator_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory_pointer: *void, proc_data: *void) -> *void {
    r: *void;
    if #complete mode == {
        case .ALLOCATE; r = alloc(cast(*Ring)proc_data, size);
        case .RESIZE;   r = alloc(cast(*Ring)proc_data, size);
        case .FREE;
    }
    return r;
}



////////////////////////////////////////////////////
// Pool Allocator

Pool :: struct {
    mem: *u8;
    cur: int;
    cap: int;
    chunk_size: int;
    block_size: int;
    first_free: *Pool_Header; // Free List
}
Pool_Header :: struct {
    next: *Pool_Header; // Free list
}


make_pool :: (size: int, chunk_size: int) -> Pool {
    p: Pool;
    p.cap = size;
    p.chunk_size = chunk_size;
    p.block_size = p.chunk_size + size_of(Pool_Header);
    p.mem = Basic.alloc(size);
    p.first_free = cast(*Pool_Header)p.mem;
    p.cur = p.block_size;
    return p;
}


alloc :: (p: *Pool, size: int) -> *void {
    r: *void;
    if p.first_free {
        r = cast(*void)(p.first_free + 1);
        p.first_free = p.first_free.next;
        if p.first_free == null && p.cur + p.block_size <= p.cap {
            p.first_free = cast(*Pool_Header)(p.mem + p.cur);
            p.cur += p.block_size;
        }
    }
    return r;
}


free :: (p: *Pool, mem: *void) {
    h: *Pool_Header = (cast(*Pool_Header)mem) - 1;
    h.next = p.first_free;
    p.first_free = h;
}


free_all :: (p: *Pool) {
    at: *u8 = p.mem + size_of(Pool_Header);
    while at < p.mem + p.cur {
        free(p, at);
        at += p.chunk_size + size_of(Pool_Header);
    }
    p.first_free = cast(*Pool_Header)p.mem;
    p.cur = size_of(Pool_Header) + p.chunk_size;
}


destroy :: (p: *Pool) {
    Basic.free(p.mem);
    <<p = Pool.{};
}


pool_allocator_proc :: (mode: Allocator_Mode, size: s64, old_size: s64, old_memory_pointer: *void, proc_data: *void) -> *void {
    r: *void;
    if #complete mode == {
        case .ALLOCATE;
            r = alloc(cast(*Pool)proc_data, size);
        case .RESIZE;
            free(cast(*Pool)proc_data, old_memory_pointer);
            r = alloc(cast(*Pool)proc_data, size);
        case .FREE;
            free(cast(*Pool)proc_data, old_memory_pointer);
    }
    return r;
}


#scope_file

Basic :: #import "Basic";

