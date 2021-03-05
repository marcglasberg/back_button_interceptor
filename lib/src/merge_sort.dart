/// Copied from algorithms.dart, Copyright (c) 2013, the Dart project authors.
/// Sorts a list between [start] (inclusive) and [end] (exclusive) using the
/// merge sort algorithm.
/// If [compare] is omitted, this defaults to calling [Comparable.compareTo] on
/// the objects. If any object is not [Comparable], this throws a [TypeError].
/// Merge-sorting works by splitting the job into two parts, sorting each
/// recursively, and then merging the two sorted parts.
/// This takes on the order of `n * log(n)` comparisons and moves to sort
/// `n` elements, but requires extra space of about the same size as the list
/// being sorted.
/// This merge sort is stable: Equal elements end up in the same order
/// as they started in.
///
void stableSort<T>(List<T> list, {int start = 0, int? end, int Function(T a, T b)? compare}) {
  end ??= list.length;
  compare ??= defaultCompare<T?>();

  int length = end - start;
  if (length < 2) return;
  if (length < _MERGE_SORT_LIMIT) {
    _insertionSort(list, compare: compare, start: start, end: end);
    return;
  }
  int middle = start + ((end - start) >> 1);
  int firstLength = middle - start;
  int secondLength = end - middle;
  var scratchSpace = List<T>.filled(secondLength, list[start]);
  _mergeSort(list, compare, middle, end, scratchSpace, 0);
  int firstTarget = end - firstLength;
  _mergeSort(list, compare, start, middle, list, firstTarget);
  _merge(compare, list, firstTarget, end, scratchSpace, 0, secondLength, list, start);
}

/// Returns a [Comparator] that asserts that its first argument is comparable.
Comparator<T> defaultCompare<T>() => (value1, value2) => (value1 as Comparable).compareTo(value2);

/// Limit below which merge sort defaults to insertion sort.
const int _MERGE_SORT_LIMIT = 32;

void _insertionSort<T>(List<T> list, {int Function(T a, T b)? compare, int start = 0, int? end}) {
  compare ??= defaultCompare<T>();
  end ??= list.length;

  for (int pos = start + 1; pos < end; pos++) {
    int min = start;
    int max = pos;
    var element = list[pos];
    while (min < max) {
      int mid = min + ((max - min) >> 1);
      int comparison = compare(element, list[mid]);
      if (comparison < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    list.setRange(min + 1, pos + 1, list, min);
    list[min] = element;
  }
}

void _movingInsertionSort<T>(List<T> list, int Function(T a, T b) compare, int start, int end,
    List<T> target, int targetOffset) {
  int length = end - start;
  if (length == 0) return;
  target[targetOffset] = list[start];
  for (int i = 1; i < length; i++) {
    var element = list[start + i];
    int min = targetOffset;
    int max = targetOffset + i;
    while (min < max) {
      int mid = min + ((max - min) >> 1);
      if (compare(element, target[mid]) < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    target.setRange(min + 1, targetOffset + i + 1, target, min);
    target[min] = element;
  }
}

void _mergeSort<T>(List<T> list, int Function(T a, T b) compare, int start, int end, List<T> target,
    int targetOffset) {
  int length = end - start;
  if (length < _MERGE_SORT_LIMIT) {
    _movingInsertionSort(list, compare, start, end, target, targetOffset);
    return;
  }
  int middle = start + (length >> 1);
  int firstLength = middle - start;
  int secondLength = end - middle;
  int targetMiddle = targetOffset + firstLength;
  _mergeSort(list, compare, middle, end, target, targetMiddle);
  _mergeSort(list, compare, start, middle, list, middle);
  _merge(compare, list, middle, middle + firstLength, target, targetMiddle,
      targetMiddle + secondLength, target, targetOffset);
}

void _merge<T>(int Function(T a, T b) compare, List<T> firstList, int firstStart, int firstEnd,
    List<T> secondList, int secondStart, int secondEnd, List<T> target, int targetOffset) {
  assert(firstStart < firstEnd);
  assert(secondStart < secondEnd);
  int cursor1 = firstStart;
  int cursor2 = secondStart;
  var firstElement = firstList[cursor1++];
  var secondElement = secondList[cursor2++];
  while (true) {
    if (compare(firstElement, secondElement) <= 0) {
      target[targetOffset++] = firstElement;
      if (cursor1 == firstEnd) break; // Flushing second list after loop.
      firstElement = firstList[cursor1++];
    } else {
      target[targetOffset++] = secondElement;
      if (cursor2 != secondEnd) {
        secondElement = secondList[cursor2++];
        continue;
      }
      target[targetOffset++] = firstElement;
      target.setRange(targetOffset, targetOffset + (firstEnd - cursor1), firstList, cursor1);
      return;
    }
  }
  target[targetOffset++] = secondElement;
  target.setRange(targetOffset, targetOffset + (secondEnd - cursor2), secondList, cursor2);
}
