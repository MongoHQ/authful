// Remove preload class on page load to allow transitions
document.addEventListener('DOMContentLoaded', function(event) {
  document.body.classList.remove('preload');
});