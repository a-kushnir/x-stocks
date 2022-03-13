export function cancel(event) {
  event.preventDefault();
  event.stopPropagation();
}

export function cancelImmediate(event) {
  event.preventDefault();
  event.stopImmediatePropagation();
}
