/**
 * Disable hover events on scroll
 * @see http://www.thecssninja.com/javascript/pointer-events-60fps
 */
var root = document.documentElement, timer;

window.addEventListener( 'scroll', function() {
  clearTimeout( timer );

  if ( !root.style.pointerEvents ) {
    root.style.pointerEvents = 'none';
  }

  timer = setTimeout(function() {
    root.style.pointerEvents = '';
  }, 150 );
}, false );