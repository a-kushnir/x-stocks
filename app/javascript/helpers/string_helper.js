export function commarize(value) {
  if (Math.abs(value) >= 1e3) {
    const minus = value < 0;
    if (minus) value = -value;

    const units = ["k", "M", "B", "T"];
    const unit = Math.floor((value.toFixed(0).length - 1) / 3) * 3;
    let num = (value / ('1e'+unit)).toFixed(2);
    const unit_name = units[Math.floor(unit / 3) - 1];

    if (minus) num = `-${num}`;
    return `${num}${unit_name}`;
  }
  return value.toLocaleString();
}

function copyString(str) {
  return `${str}`;
}

export function truncate(str, n) {
  const s = copyString(str);
  return (s.length > n + 3) ? `${s.substr(0, n-1)}…` : s;
}

export function generateId(prefix = 'id_') {
  return prefix + Math.random().toString(16).slice(2);
}

export function escapeHTML(value) {
  const text = document.createTextNode(value);
  const span = document.createElement('span');
  span.appendChild(text);
  return span.innerHTML;
}
