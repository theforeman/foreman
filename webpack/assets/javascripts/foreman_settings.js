import $ from 'jquery';

$(document).ready(() => {
  if (window.location.pathname === window.foreman_url('/settings')) {
    $('.editable').editable({
      params: {
        authenticity_token: window.AUTH_TOKEN,
      },
      error(response) {
        return $.parseJSON(response.responseText).errors;
      },
    });
  }
});
