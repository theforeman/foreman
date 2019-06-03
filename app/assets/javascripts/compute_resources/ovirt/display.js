function toggle_keyboard_options() {
    if ($('select.display_type').val().toLowerCase() === 'vnc') {
        $('.keyboard_layout').parents('.form-group').css('display', '');
    } else {
        $('.keyboard_layout').parents('.form-group').css('display', 'none');
    }
}

$(document).on('change', '.display_type', toggle_keyboard_options);
$(document).ready(toggle_keyboard_options);