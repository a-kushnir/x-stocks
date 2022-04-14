export function setProgressValue(element, value) {
  element.style.width = `${value}%`;
  element.textContent = `${value}%`;
  element.ariaValueNow = value;
}

export function setProgressColor(element, setColor, removeColors) {
  for (const color of removeColors) {
    element.classList.remove(color);
  }
  element.classList.add(setColor);
}
