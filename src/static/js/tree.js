const branchSelectEl = document.querySelector(".branch-select");
branchSelectEl.addEventListener("change", (event) => {
  window.location.href = TREE_BRANCH_PATH_TEMPLATE + event.target.value;
});

branchSelectEl.value = BRANCH_NAME;

// Make the entire row clickable
const fileEls = document.querySelectorAll(".file");

fileEls.forEach(fileEl => {
  fileEl.addEventListener("click", () => {
    window.location = fileEl.querySelector("a").href;
  });
});

const starButtonEl = document.querySelector(".star-button");

async function starRepo(repoId) {
  const url = "/api/v1/repos/" + repoId + "/star";
  const response = await fetch(url, {
    method: "POST"
  });
  const json = await response.json();

  if (json.success) {
    return json.result === "true";
  } else {
    throw new Error(json.message);
  }
}

star