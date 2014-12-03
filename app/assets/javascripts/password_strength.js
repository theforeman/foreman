//= require jquery_pwstrength_bootstrap

$(document).on('ContentLoad', function () {
  password_strength_feedback($('#user_password'));
  $('#user_password_confirmation').bind("change keyup input focusout", function () {
    update_confirmation();
  });
});

function password_strength_feedback(password) {
  var form = password.closest('.form-group');
  var options = {
    common: {
      usernameField: $('#user_login'),
      onLoad: function () {
        form.find('.progress').addClass('hide');
      },
      onKeyUp: function (evt, data) {
        if ($(evt.target).val() == '') {
          form.find('.help-block.help-inline').html(''); // clear errors
          form.removeClass('has-error has-success');
          form.find('.progress').addClass('hide');
        }
        else
          form.find('.progress').removeClass('hide');

        update_confirmation();
      }
    },
    ui: {
      showProgressBar: true,
      showPopover: false,
      showStatus: true,
      showErrors: true,
      showVerdictsInsideProgressBar: true,
      container: form,
      viewports: {
        progress: ".col-md-4 .help-block",
        errors: ".help-inline"
      },
      spanError: function (options, key) {
        "use strict";
        var text = options.ui.errorMessages[key];
        return (!text) ? '' : '<span>' + text + '</span>';
      },
      verdicts: [__("Weak"), __("Normal"), __("Medium"), __("Strong"), __("Very Strong")],
      errorMessages: {
        wordLength: __("Your password is too short"),
        wordNotEmail: __("Do not use your email as your password"),
        wordSimilarToUsername: __("Your password cannot contain your username"),
        wordTwoCharacterClasses: __("Use different character classes"),
        wordRepetitions: __("Too many repetitions"),
        wordSequences: __("Your password contains sequences")
      }
    }
  };

  password.pwstrength(options);
}

function update_confirmation() {
  var confirmation = $('#user_password_confirmation');
  var password = $('#user_password').val();
  var form = confirmation.closest('.form-group');
  var html = '';
  if (confirmation.val() == password) {
    if (password != '') {
      html = __("password match");
      form.removeClass("has-error").addClass("has-success");
    }
    else {
      form.removeClass("has-success has-error");
    }
  }
  else {
    html = __("passwords do not match");
    form.removeClass("has-success").addClass("has-error");
  }

  confirmation.parent().siblings(".help-block").html(html)
}
