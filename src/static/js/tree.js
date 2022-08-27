const branchSelectEl = document.querySelector(".branch-select");
branchSelectEl.addEventListener("change", (event) => {
  window.location.href = TREE_BRANCH_PATH_TEMPLATE + event.target.value;
});

branchSelectEl.value = BRANCH_NAME;

// Make the entire row clickable
const fileEls = document.querySelectorAll(".file