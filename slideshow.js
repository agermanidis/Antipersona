function slideshow(container, sel, interval) {
  setInterval(function() {
    var images = $(container).find(sel);
    var currentIndex = images.index($(".selected").get(0));
    console.log(currentIndex)
    var nextIndex = (currentIndex+1) % images.length;
    $(sel).removeClass("selected");
    var nextEl = $(sel)[nextIndex];
    $(nextEl).addClass("selected");
  }, interval);
}


