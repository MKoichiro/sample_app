// helper: トグルリスナー
const addToggleListener = (selectedId, menuId, toggleClass) => {
  let selectedElm = document.querySelector(`#${selectedId}`);
  selectedElm.addEventListener("click", e => {
    e.preventDefault();
    let menu = document.querySelector(`#${menuId}`);
    menu.classList.toggle(toggleClass);
  });
}

// main: クリックをトリガーにしてメニューを開閉する
const menu = () => {
  addToggleListener("hamburger", "navbar-menu", "collapse");
  addToggleListener("account", "dropdown-menu", "active");
}

document.addEventListener("turbo:load", menu);
