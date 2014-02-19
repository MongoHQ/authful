/**
 * modalEffects.js v1.0.0 (http://www.codrops.com)
 * Modified by Kyle Foster (@hkfoster)
 * @license MIT
 */
var ModalEffects = (function() {

  function init() {

    var overlay = document.querySelector( '.modal-overlay' );

    [].slice.call( document.querySelectorAll( '.modal-trigger' ) ).forEach( function( el, i ) {

      var modal = document.querySelector( '#' + el.getAttribute( 'data-modal' ) ),
          close = modal.querySelector( '.modal-close' ),
          body  = document.body;

      function removeModal() {
        modal.classList.remove( 'modal-show' );
        body.style.overflow = ''; // Turn scrolling back on
      }

      el.addEventListener( 'click', function( e ) {
        e.preventDefault();
        modal.classList.add( 'modal-show' );
        body.style.overflow = 'hidden'; // Kill scrolling behind modal
        overlay.removeEventListener( 'click', removeModal );
        overlay.addEventListener( 'click', removeModal );
      });

      close.addEventListener( 'click', function( e ) {
        e.stopPropagation();
        e.preventDefault();
        removeModal();
      });

    } );

  }

  init();

})();