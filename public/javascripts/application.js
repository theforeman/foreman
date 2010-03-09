// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function mark_for_destroy(element) {
  $(element).next('.should_destroy').value = 1;
  $(element).up('.lookup_value').hide();
}
