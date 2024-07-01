// トグルリスナー
function addToggleListener(selectedId, menuId, toggleClass) {
  let selectedElm = document.querySelector(`#${selectedId}`);
  selectedElm.addEventListener("click", function (event) {
    event.preventDefault();
    let menu = document.querySelector(`#${menuId}`);
    menu.classList.toggle(toggleClass);
  });
}
// クリックをトリガーにしてメニューを開閉する
document.addEventListener("turbo:load", function () {
  alert("turbo:load");
  addToggleListener("hamburger", "navbar-menu", "collapse");
  addToggleListener("account", "dropdown-menu", "active");
});
