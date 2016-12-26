window.less = {
        async        : true,
        environment  : 'production',
        fileAsync    : false,
        onReady      : false,
        useFileCache : true
};

$(function() {
    $('a[href*="#"]:not([href="#"])').click(function() {
      if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
        if (target.length) {
          $('html, body').animate({
            scrollTop: target.offset().top
          }, 1000);
          return false;
        }
      }
    });
    $('.scrollToTop').fadeOut();
    $(window).scroll(function(){
      if ($(this).scrollTop() > 100) {
        $('.scrollToTop').fadeIn();
      } else {
        $('.scrollToTop').fadeOut();
      }
    });

    $('.scrollToTop').click(function(){
      $('html, body').animate({scrollTop : 0},800);
      return false;
    });
});

$('.masthead h1 b').typed({
  strings         : [
    "a web developer.","a software developer.","a programmer." , "a chess player." , "an open-source enthusiast.", "a coffee-lover.","a carnatic vocalist.","a grammar nazi.","a fan of TV series'."
  ],
  showCursor      : false,
  typeSpeed       : 50,
  backSpeed       : 50,
  backDelay       : 50,
  frontDelay      : 1000,
  loop: true
});

// window.sr = ScrollReveal({ reset: true });
// sr.reveal('.sr');

var post_content = [
{ url: "http://github.com",  post_title: 'The Covariance Confusion' },
{ url: "http://github.com",  post_title: 'Hello World' },
{ url: "http://github.com",  post_title: 'A man has no name' },
{ url: "http://github.com",  post_title: 'Kharagpur Winter of Code 2016' }
];

var tag_content = [
{ url: "http://github.com",  tag_title: 'AUV', color: 'red' },
{ url: "http://github.com",  tag_title: 'Metakgp', color: 'black' },
{ url: "http://github.com",  tag_title: 'Series', color: 'teal' },
{ url: "http://github.com",  tag_title: 'Ruby', color: 'green' }
];

$('.post_search .ui.search')
.search({
  searchFields: ['post_title'],
  source: post_content,
  maxResults: 5,
  showNoResults: true,
  type: "custom"
})
;

$('.tag_search .ui.search')
.search({
  searchFields: ['tag_title'],
  source: tag_content,
  maxResults: 5,
  showNoResults: true,
  type: "custom"
})
;

