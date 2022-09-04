const MEGABYTE_IN_BYTES = 1024 * 1024;

function selectAvatar() {
  const fileInputEl = document.createElement("input");
  fileInputEl.type = "file";
  fileInputEl.accept = "image/*";

  fileInputEl.onchange = async function (event) {
    const file = event.target.files[0];
    const fileSize = file.size;

    if (fileSize > MEGABYTE_IN_BYTES) {
      alert("This file is too large to be uploaded. Files larger than 1 MB are not currently supported");
      return;
    }

    await uploadAvatar