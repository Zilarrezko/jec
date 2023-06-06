
////////////////////////////////////
// NOISE


perlin_LUT_count :: 256;
perlin_LUT_mask :: perlin_LUT_count - 1;
perlin_LUT: [perlin_LUT_count]v3 = #run -> [perlin_LUT_count]v3 {
    push_entropy(2016);

    r: [perlin_LUT_count]v3;
    for i : 0..perlin_LUT_count - 1 {
        r[i] = random_v3();
    }
    return r;
}
perlin_permutation_LUT: [2*perlin_LUT_count]int = #run -> [2*perlin_LUT_count]int {
    push_entropy(2016);

    r: [2*perlin_LUT_count]int;
    for i : 0..perlin_LUT_count - 1 {
        r[i] = i;
    }
    for k : 0..perlin_LUT_count - 1 {
        i: int = random_int(k, perlin_LUT_mask);
        t := r[k];
        r[k] = r[i];
        r[i] = t;
        r[k + perlin_LUT_count] = r[k];
    }
    return r;
}

perlin :: (x: f32) -> f32 {
    return inline perlin(x, 0, 0);
}
perlin :: (x: f32, y: f32) -> f32 {
    return inline perlin(x, y, 0);
}
perlin :: (v: v2) -> f32 {
    return inline perlin(v.x, v.y, 0);
}
perlin :: (v: v3) -> f32 {
    return inline perlin(v.x, v.y, v.z);
}
perlin :: (x: f32, y: f32, z: f32) -> f32 {
    hash :: inline (x: int, y: int, z: int) -> int {
        return perlin_permutation_LUT[perlin_permutation_LUT[perlin_permutation_LUT[x] + y] + z];
    }
    ix0: int = cast(int)x;
    iy0: int = cast(int)y;
    iz0: int = cast(int)z;
    if x < 0
        ix0 = ix0 - 1;
    if y < 0
        iy0 = iy0 - 1;
    if z < 0
        iz0 = iz0 - 1;
    tx: f32 = x - cast(f32)ix0;
    ty: f32 = y - cast(f32)iy0;
    tz: f32 = z - cast(f32)iz0;
    ix0 = ix0 & perlin_LUT_mask;
    iy0 = iy0 & perlin_LUT_mask;
    iz0 = iz0 & perlin_LUT_mask;
    ix1 := (ix0 + 1) & perlin_LUT_mask;
    iy1 := (iy0 + 1) & perlin_LUT_mask;
    iz1 := (iz0 + 1) & perlin_LUT_mask;
    u := quintic(tx);
    v := quintic(ty);
    w := quintic(tz);

    c000 := perlin_LUT[hash(ix0, iy0, iz0)];
    c100 := perlin_LUT[hash(ix1, iy0, iz0)];
    c010 := perlin_LUT[hash(ix0, iy1, iz0)];
    c110 := perlin_LUT[hash(ix1, iy1, iz0)];
    c001 := perlin_LUT[hash(ix0, iy0, iz1)];
    c101 := perlin_LUT[hash(ix1, iy0, iz1)];
    c011 := perlin_LUT[hash(ix0, iy1, iz1)];
    c111 := perlin_LUT[hash(ix1, iy1, iz1)];

    x0 := tx; x1 := tx - 1;
    y0 := ty; y1 := ty - 1;
    z0 := tz; z1 := tz - 1;

    p000 := v3.{x0, y0, z0};
    p100 := v3.{x1, y0, z0};
    p010 := v3.{x0, y1, z0};
    p110 := v3.{x1, y1, z0};
    p001 := v3.{x0, y0, z1};
    p101 := v3.{x1, y0, z1};
    p011 := v3.{x0, y1, z1};
    p111 := v3.{x1, y1, z1};

    a := lerp(dot(c000, p000), dot(c100, p100), u);
    b := lerp(dot(c010, p010), dot(c110, p110), u);
    c := lerp(dot(c001, p001), dot(c101, p101), u);
    d := lerp(dot(c011, p011), dot(c111, p111), u);

    e := lerp(a, b, v);
    f := lerp(c, d, v);

    val := lerp(e, f, w)*0.5 + 0.5;
    return val; // [0..1]
}


value_lookup_count :: 256;
value_lookup_mask :: value_lookup_count - 1;
value_lookup: [value_lookup_count]f32 = #run -> [value_lookup_count]f32 {
    push_entropy(2016);

    r: [value_lookup_count]f32;
    for i : 0..value_lookup_count - 1 {
        r[i] = random_unilateral();
    }
    return r;
}
value_permutation_LUT: [2*value_lookup_count]int = #run -> [2*value_lookup_count]int {
    push_entropy(2016);

    r: [2*value_lookup_count]int;
    for i : 0..value_lookup_count - 1 {
        r[i] = i;
    }
    for k : 0..value_lookup_count - 1 {
        i: int = random_proc() % value_lookup_count;
        t := r[k];
        r[k] = r[i];
        r[i] = t;
        r[k + value_lookup_count] = r[k];
    }
    return r;
}

value_noise :: (x: f32) -> f32 {
    return inline value_noise(x, 0, 0);
}
value_noise :: (x: f32, y: f32) -> f32 {
    return inline value_noise(x, y, 0);
}
value_noise :: (v: v2) -> f32 {
    return inline value_noise(v.x, v.y, 0);
}
value_noise :: (v: v3) -> f32 {
    return inline value_noise(v.x, v.y, v.z);
}
value_noise :: (x: f32, y: f32, z: f32) -> f32 {
    ix0: int = cast(int)x;
    if x < 0
        ix0 -= 1;
    iy0: int = cast(int)y;
    if y < 0
        iy0 -= 1;
    iz0: int = cast(int)z;
    if z < 0
        iz0 -= 1;
    tx: f32 = x - ix0;
    ty: f32 = y - iy0;
    tz: f32 = z - iz0;
    ix0 = ix0 & value_lookup_mask;
    ix1 := (ix0 + 1) & value_lookup_mask;
    iy0 = iy0 & value_lookup_mask;
    iy1 := (iy0 + 1) & value_lookup_mask;
    iz0 = iz0 & value_lookup_mask;
    iz1 := (iz0 + 1) & value_lookup_mask;
    c000: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix0] + iy0] + iz0]];
    c100: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix1] + iy0] + iz0]];
    c010: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix0] + iy1] + iz0]];
    c110: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix1] + iy1] + iz0]];
    c001: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix0] + iy0] + iz1]];
    c101: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix1] + iy0] + iz1]];
    c011: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix0] + iy1] + iz1]];
    c111: f32 = value_lookup[value_permutation_LUT[value_permutation_LUT[value_permutation_LUT[ix1] + iy1] + iz1]];
    tx = quintic(tx);
    ty = quintic(ty);
    tz = quintic(tz);
    vx1 := lerp(c000, c100, tx);
    vx2 := lerp(c010, c110, tx);
    vx3 := lerp(c001, c101, tx);
    vx4 := lerp(c011, c111, tx);
    vy1 := lerp(vx1, vx2, ty);
    vy2 := lerp(vx3, vx4, ty);
    val := lerp(vy1, vy2, tz);
    return val;
}

noise :: inline (x: f32, y: f32) -> f32 {
    // Typical settings for some noise
    layers :: 4;
    persistance :: 0.5;
    lacunarity :: 2.0;
    return noise(x, y, layers, persistance, lacunarity);
}
noise :: (x: f32, y: f32, layers: int, persistance: f32, lacunarity: f32) -> f32 {
    func :: perlin;
    amp := 1.0;
    freq := 1.0;
    acc: f32;
    for 0..layers - 1 {
        sx := x*freq;
        sy := y*freq;
        acc += amp*func(sx, sy);
        amp *= persistance;
        freq *= lacunarity;
    }
    /*
      amp*func        // [0..amp]
      amp *= persist  // pow(persistance, layers);
      // 1+0.5+0.25+0.125
      // closed form: ((x^n+1) - 1)/(x - 1)
    */
    // max_val: f32 = (pow(persistance, cast(f32)layers) - 1)/(persistance - 1);
    // acc = acc/max_val;
    return acc;
}

curl :: (v: v2) -> v2 {
    eps := 0.0001;
    n1 := noise(v.x + eps, v.y);
    n2 := noise(v.x - eps, v.y);
    a := (n1 - n2)/(2*eps);
    n1 = noise(v.x, v.y + eps);
    n2 = noise(v.x, v.y - eps);
    b := (n1 - n2)/(2*eps);
    return v2.{b, -a};
}
