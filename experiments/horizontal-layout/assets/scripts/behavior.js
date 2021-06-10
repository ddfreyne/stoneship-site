let elems = document.querySelectorAll(".horizontal-scroll");
let elem = elems[0];

elem.addEventListener("wheel", function (e) {
  if (elem) {
    elem.scrollLeft += e.deltaY;
  }
});

let scrollOffset = 2 * (elem.firstElementChild.offsetWidth + 24);

document.addEventListener("keydown", (event) => {
  console.log(event);
  if (!elem) {
    return;
  }

  if (event.code === "Space" || event.code == "PageDown") {
    elem.scrollBy({
      top: 0,
      left: scrollOffset,
      behavior: "smooth",
    });
  }

  if (event.code == "PageUp") {
    elem.scrollBy({
      top: 0,
      left: -scrollOffset,
      behavior: "smooth",
    });
  }

  if (event.code === "Home") {
    elem.scrollTo({
      top: 0,
      left: 0,
      behavior: "smooth",
    });
  }

  if (event.code === "End") {
    elem.scrollTo({
      top: 0,
      left: 100000000,
      behavior: "smooth",
    });
  }
});
