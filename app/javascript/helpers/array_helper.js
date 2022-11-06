export function diff(array) {
  const diff = [];
  for (let i = 0; i < array.length - 1; i++) {
    diff.push(array[i + 1] - array[i]);
  }
  diff.push(0);
  return diff;
}
