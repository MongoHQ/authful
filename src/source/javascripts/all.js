//= require 'preloader'
//= require 'unhover'
//= require 'headsup'
//= require 'rAF'
//= require 'smoothScroll'
//= require 'prism'
//= require 'modal'

// Landing page scroll
(function() {

  // Cache our hero section
  var landingHero   = document.querySelector( 'section.landing-hero' );

  // Only execute if landing hero exists
  if ( !landingHero ) { return; } else {

  // Cached variables
  var scrollTrigger = document.querySelector( 'a.scroll-trigger' ),
      winHeight;

  // Throttle function (http://bit.ly/1eJxOqL)
  function throttle( fn, threshhold, scope ) {
    threshhold || (threshhold = 250);
    var previous, deferTimer;
    return function () {
      var context = scope || this,
          current = Date.now(),
          args    = arguments;
      if ( previous && current < previous + threshhold ) {
        clearTimeout( deferTimer );
        deferTimer = setTimeout( function () {
        previous   = current;
        fn.apply( context, args );
        }, threshhold );
      } else {
        previous = current;
        fn.apply( context, args );
      }
    };
  }

  // Resize handler function
  function resizeHandler() {
    winHeight = window.innerHeight || document.documentElement.clientHeight || document.getElementsByTagName( 'body' )[0];
    landingHero.setAttribute( 'style', 'height: ' + winHeight + 'px' );
  }

  // Resize function
  window.addEventListener( 'resize', throttle( resizeHandler ), false );

  // Trigger initial resize
  window.dispatchEvent( new Event( 'resize' ) );

  // Cool scrolly bro
  scrollTrigger.addEventListener( 'click', function( e ) {
    e.preventDefault();
    window.scrollTo(0, winHeight, { behavior: 'smooth' });
  }, false );

  }

})();