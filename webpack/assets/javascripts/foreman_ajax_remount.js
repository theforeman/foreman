import $ from 'jquery';

/* eslint-disable prefer-arrow-callback, func-names */

$(document).on('RemountComponents', function() {
  window.tfm.ajaxRemount.remountComponents();
});

export function remountComponents() {
  const range = document.createRange();
  range.selectNode(document.getElementsByTagName('body').item(0));

  $('.react_mounted script').each(function() {
    const inner = $(this).text();
    const documentFragment = range.createContextualFragment(
      `<script> ${inner} </script>`
    );
    document.body.appendChild(documentFragment);
  });
}
