export function formatCurrency(value) {
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  });
  return formatter.format(value);
}

export function padStart(number, maxLength = 2, fillString = '0') {
  return number.toString().padStart(maxLength, fillString);
}
