var isMobile = {
    Android: function() {
        return navigator.userAgent.match(/Android/i);
    },
    BlackBerry: function() {
        return navigator.userAgent.match(/BlackBerry/i);
    },
    iOS: function() {
        return navigator.userAgent.match(/iPhone|iPad|iPod/i);
    },
    Opera: function() {
        return navigator.userAgent.match(/Opera Mini/i);
    },
    Windows: function() {
        return navigator.userAgent.match(/IEMobile/i) || navigator.userAgent.match(/WPDesktop/i);
    },
    any: function() {
        return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
    }
};

$(".feature").on("click", function(evt) {
  $(".feature").removeClass("selected");
  $(evt.target).addClass("selected");
  var idx = $(evt.target).index(".feature");
  var selectedScreenshot = $(".screenshot")[idx];
  $(".screenshot").removeClass("selected");
  $(selectedScreenshot).addClass("selected");
});

var carouselStarted = false;

if (isMobile.any()) {
  $(window).on("scroll", function() {
    if (!carouselStarted && window.scrollY > $("#features").position().top-200) {
      carouselLoop();
    }
  });
}

function carouselLoop() {
  console.log("carouselLoop");
  if (!carouselStarted) {
    carouselStarted = true;
  } else {
    var currentIndex = $(".feature.selected").index(".feature");
    var nextIndex = (currentIndex + 1) % 3;
    $(".feature").removeClass("selected");
    $(".screenshot").removeClass("selected");
    $($(".feature")[nextIndex]).addClass("selected");
    $($(".screenshot")[nextIndex]).addClass("selected");
  }
  console.log("aa", carouselStarted);
  setTimeout(carouselLoop, 5000);
}
