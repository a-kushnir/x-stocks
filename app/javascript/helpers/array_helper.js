export function diff(array) {
  const diff = [];
  for (let i = 0; i < array.length - 1; i++) {
    diff.push(array[i + 1] - array[i]);
  }
  diff.push(0);
  return diff;
}

export function diffPct(array) {
  const diff = [];
  diff.push(0);
  for (let i = 0; i < array.length - 1; i++) {
    diff.push((array[i] - array[i + 1]) / array[i + 1]);
  }
  return diff;
}
