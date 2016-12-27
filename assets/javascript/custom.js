

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

$.fn.search.settings.templates.custom = function(response, fields) {
      var
        html = ''
      ;
      if(response[fields.results] !== undefined) {

        // each result
        $.each(response[fields.results], function(index, result) {
          if(result[fields.url]) {
            html  += '<a class="result" href="' + result[fields.url] + '">';
          }
          else {
            html  += '<a class="result">';
          }
          html += '<div class="content">';
          if(result["post_title"]) {
            html += '<div class="title">' + result["post_title"] + '</div>';
          }
          if(result["tag_title"]) {
            html += '<div class="title"><span class="ui '+result["color"]+' tag label">' + result["tag_title"] + '</span></div>';
          }
          html  += '</div></a>';
        });
        return html;
      }
      return false;
    }




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

