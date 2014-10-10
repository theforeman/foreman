//= require jquery_pwstrength_bootstrap
function password_strength_feedback(password){
  var options = {
      ui: {
        showProgressBar : true,
        showPopover : false,
        showStatus : true,
        showErrors : true,
        showVerdictsInsideProgressBar : true,
        container : $(password +" #user_password").parent().parent(),
        viewports : {
          progress : ".col-md-4 .help-block",
          errors : ".help-inline"
        },
        spanError : function (options, key) {
            "use strict";
            var text = options.ui.errorMessages[key];
            if (!text) { return ''; }
            return '<span>' + text + '</span>';
        },
        errorMessages : {
          wordLength: __("Your password is too short"),
          wordNotEmail: __("Do not use your email as your password"),
          wordSimilarToUsername: __("Your password cannot contain your username"),
          wordTwoCharacterClasses: __("Use different character classes"),
          wordRepetitions: __("Too many repetitions"),
          wordSequences: __("Your password contains sequences")
        }
      }
  };

  $(password +" #user_password").pwstrength(options);
  
  $(password +" #user_password_confirmation").keyup(function(){

    if( $(password +" #user_password_confirmation").val() == $(password +" #user_password").val()){

      $(password +" #user_password_confirmation").parent().parent().removeClass("has-error").addClass("has-success");
      $(password +" #user_password_confirmation").parent().siblings(".help-block").html(__("passwords match"));
    }else{
      $(password +" #user_password_confirmation").parent().parent().removeClass("has-success").addClass("has-error");  
      $(password +" #user_password_confirmation").parent().siblings(".help-block").html(__("passwords do not match"));
    }

    if($(password +" #user_password_confirmation").val()==""){
      $(password +" #user_password_confirmation").parent().parent().removeClass("has-success").removeClass("has-error");  
      $(password +" #user_password_confirmation").parent().siblings(".help-block").html("")
    }
  })

}