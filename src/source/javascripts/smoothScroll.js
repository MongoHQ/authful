/**
 * SmoothScroll - https://github.com/iamdustan/smoothscroll
 * Polyfill for window.scroll() & window.scrollTo()
 * Modified by Kyle Foster (@hkfoster)
 * @license MIT
 */
(function () {

  'use strict';

  if ('scrollBehavior' in document.documentElement.style) return;

  var SCROLL_TIME = 300,
      originalScrollTo = window.scrollTo,
      frame, startY, startX, endX, endY;

  function now() {
    return window.performance !== undefined && window.performance.now !== undefined ? window.performance.now() : Date.now !== undefined ? Date.now() : new Date().getTime();
  }

  function ease(k) {
    return 0.5 * (1 - Math.cos(Math.PI * k));
  }

  function smoothScroll(x, y) {
    var sx = window.pageXOffset,
        sy = window.pageYOffset;

    if (typeof startX === 'undefined') {
      startX = sx;
      startY = sy;
      endX = x;
      endY = y;
    }

    var startTime = now();

    var step = function() {
      var time = now();
      var elapsed = (time - startTime) / SCROLL_TIME;
      elapsed = elapsed > 1 ? 1 : elapsed;

      var value = ease(elapsed);
      var cx = sx + ( x - sx ) * value;
      var cy = sy + ( y - sy ) * value;

      originalScrollTo(cx, cy);

      if (cx === endX && cy === endY) {
        startX = startY = endX = endY = undefined;
        return;
      }

      frame = requestAnimationFrame(step);
    };

    if (frame) cancelAnimationFrame(frame);
    frame = requestAnimationFrame(step);
  }

  window.scroll = window.scrollTo = function(x, y, scrollOptions) {
    if (scrollOptions.behavior !== 'smooth')
      return originalScroll(x, y);
    return smoothScroll(x, y);
  };

  function scrollElement(el, x, y) {
    el.scrollTop = y;
    el.scrollLeft = x;
  }

  function scroll(el, endCoords) {
    var sx = el.scrollLeft;
    var sy = el.scrollTop;

    var x = endCoords.left;
    var y = endCoords.top;

    if (typeof startX === 'undefined') {
      startX = sx;
      startY = sy;
      endX = endCoords.left;
      endY = endCoords.top;
    }

    var startTime = now();

    var step = function() {
      var time = now();
      var elapsed = (time - startTime) / SCROLL_TIME;
      elapsed = elapsed > 1 ? 1 : elapsed;

      var value = ease(elapsed);
      var cx = sx + ( x - sx ) * value;
      var cy = sy + ( y - sy ) * value;

      scrollElement(el, cx, cy);

      if (cx === endX && cy === endY) {
        startX = startY = endX = endY = undefined;
        return;
      }

      frame = requestAnimationFrame(step);
    };

    if (frame) cancelAnimationFrame(frame);
    frame = requestAnimationFrame(step);
  }

}());