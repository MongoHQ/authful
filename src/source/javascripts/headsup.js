/*
* HeadsUp 0.5.6
* @author Kyle Foster (@hkfoster)
* @license MIT
*/
;(function( window, document, undefined ) {

  'use strict';

  // Extend function
  function extend( a, b ) {
    for( var key in b ) {
      if( b.hasOwnProperty( key ) ) {
        a[ key ] = b[ key ];
      }
    }
    return a;
  }

  // Main function definition
  function headsUp( selector, options ) {
    this.selector = document.querySelector( selector );
    this.options  = extend( this.defaults, options );
    this.init();
  }

  // Overridable defaults
  headsUp.prototype = {
    defaults : {
      offset : 300,
      pace   : 20
    },

    // Init function
    init : function( selector ) {
      var self         = this,
          selector     = self.selector,
          options      = self.options,
          oldScrollPos = 0, winHeight;

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
        return winHeight;
      }

      // Resize function
      window.addEventListener( 'resize', throttle( resizeHandler ), false );

      // Trigger initial resize
      window.dispatchEvent( new Event( 'resize' ) );

      // Scroll handler function
      function scrollHandler() {

        // Scoped variables
        var newScrollPos  = window.scrollY,
            docHeight     = Math.max( document.documentElement.clientHeight, document.body.scrollHeight, document.documentElement.scrollHeight, document.body.offsetHeight, document.documentElement.offsetHeight ),
            pastOffset    = newScrollPos > options.offset,
            scrollingDown = newScrollPos > oldScrollPos,
            outpaced      = newScrollPos < oldScrollPos - options.pace,
            bottomedOut   = newScrollPos < 0 || newScrollPos + winHeight >= docHeight;

        // Where the magic happens
        if ( pastOffset && scrollingDown ) {
          selector.classList.add( 'heads-up' );
        } else if ( !scrollingDown && outpaced && !bottomedOut || !pastOffset ) {
          selector.classList.remove( 'heads-up' );
        }

        // Keep on keeping on
        oldScrollPos = newScrollPos;
      }

      // Scroll function
      window.addEventListener( 'scroll', throttle( scrollHandler, 100 ), false ); }
  };

  window.headsUp = headsUp;

})( window, document );

// Instantiate HeadsUp
new headsUp( 'header.branding' );