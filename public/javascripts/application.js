// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function mark_for_destroy(element) {
  $(element).next('.should_destroy').value = 1;
  $(element).up('.lookup_value').hide();
}

function remove_fields(link) {
  $(link).previous("input[type=hidden]").value = "1";
  $(link).up('.fields').hide();
}

function add_fields(link, association, content) {
  // using getTime for unique ids
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
    $(link).up().insert({
      before: content.replace(regexp, new_id)
    });
}
