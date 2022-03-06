document.copyToClipboard = function(selector) {
  const copyText = $(selector)[0];
  copyText.select();
  copyText.setSelectionRange(0, 99999); /* For mobile devices */
  document.execCommand("copy");
}
