const MEGABYTE_IN_BYTES = 1024 * 1024;

function selectAvatar() {
  const fileInputEl = document.createElement("input");
  fileInputEl.type = "file";
  fileInputEl.accept = "image/*";

  fileInputEl.onchange = async functi