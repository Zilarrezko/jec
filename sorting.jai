

// Note:
//  Best    Avg   Worst
//   n      n^2    n^2
//
// this sorting algorithm is stable
// Fantastic if the array is nearly sorted
insertion_sort :: (arr: []$T, cmp: (T, T) -> bool) {
    i := 1;
    while i < arr.count {
        x := arr[i];
        j := i - 1;
        while j >= 0 && !cmp(arr[j], x) {
            arr[j + 1] = arr[j];
            j -= 1;
        }
        arr[j + 1] = x;
        i += 1;
    }
}

// The bees knees if you're appending onto the array and just need to sort it into an already sorted array
insertion_sort_last :: (arr: []$T, cmp: (T, T) -> bool) {
    if arr.count < 2
        return;
    x := arr[arr.count - 1];
    j := arr.count - 2;
    while j >= 0 && !cmp(arr[j], x) {
        arr[j + 1] = arr[j];
        j -= 1;
    }
    arr[j + 1] = x;
}

merge_sort :: (arr: []$T, cmp: (T, T) -> bool, allocator := temp) {
    tmp: []T = NewArray(arr.count, T, false, allocator);
    k := 1;
    i, j, t: int;
    while k < arr.count {
        left: int;
        while left + k < arr.count {
            right := left + k;
            end := right + k;
            if end > arr.count
                end = arr.count;
            t = left;
            i = left;
            j = right;
            while i < right && j < end {
                if !cmp(arr[j], arr[i]) {
                    tmp[t] = arr[i];
                    i += 1;
                }
                else {
                    tmp[t] = arr[j];
                    j += 1;
                }
                t += 1;
            }
            while i < right {
                tmp[t] = arr[i];
                i += 1;
                t += 1;
            }
            while j < end {
                tmp[t] = arr[j];
                j += 1;
                t += 1;
            }
            for left..end - 1 { // memcpy?
                arr[it] = tmp[it];
            }
            left += 2*k;
        }
        k *= 2;
    }
    free(tmp.data);
}
