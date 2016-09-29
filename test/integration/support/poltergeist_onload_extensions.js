var disableAnimationStyles = '-webkit-transition: none !important;' +
                             '-moz-transition: none !important;' +
                             '-ms-transition: none !important;' +
                             '-o-transition: none !important;' +
                             'transition: none !important;'

window.onload = function() {
  // disable animations to speed up the tests and make them more deterministic
  var animationStyles = document.createElement('style');
  animationStyles.type = 'text/css';
  animationStyles.innerHTML = '* {' + disableAnimationStyles + '}';
  document.head.appendChild(animationStyles);

  // make sure the icon elements have size specified before the icons
  // get loaded to prevent unexpected layout changes
  var fixedIconSizes = document.createElement('style');
  fixedIconSizes.type = 'text/css';
  fixedIconSizes.innerHTML = '.pficon, .fa { width: 12px; height: 12px; }';
  document.head.appendChild(fixedIconSizes);
};
