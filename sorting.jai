

// Note:
//  Best    Avg   Worst
//   n      n^2    n^2
//
// this sorting algorithm is stable
insertion_sort :: (arr: []$T, cmp: (T) -> $R) #modify {
    ti := cast(*Type_Info)R;
    if ti.type == .INTEGER
    	return true;
    if ti.type == .POINTER
    	return true;
    return false;
}{
    i := 1;
    while i < arr.count {
        x := arr[i];
        x_val := cmp(x);
        j := i - 1;
        while j >= 0 && cmp(arr[j]) > x_val {
            arr[j + 1] = arr[j];
            j -= 1;
        }
        arr[j + 1] = x;
        i += 1;
    }
}



merge_sort :: (arr: []$T, cmp: (T) -> $R, allocator := temp) {
    tmp: []T = NewArray(arr.count, T, false, allocator);
    memcpy(tmp.data, arr.data, arr.count*size_of(T));
    helper(tmp, arr, cmp, 0, arr.count);

    helper :: (tmp: []T, arr: []T, cmp: (T) -> R, l: int, r: int) {
        if r - l <= 1
            return; // sorted
        mid := (r + l)/2;
        helper(arr, tmp, cmp, l,   mid);
        helper(arr, tmp, cmp, mid, r);
        merge(tmp, arr, l, mid, r, cmp);
    }

    merge :: (arr: []T, tmp: []T, l: int, m: int, r: int, cmp: (T) -> R) {
        i := l;
        j := m;
        for k: l..r - 1 {
            if i < m && (j >= r || cmp(tmp[i]) <= cmp(tmp[j])) {
                arr[k] = tmp[i];
                i += 1;
            }
            else {
                arr[k] = tmp[j];
                j += 1;
            }
        }
    }
}
