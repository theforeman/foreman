// case insensitive version of the contains selector
jQuery.expr[':'].icontains = function(a, i, m) {
  return jQuery(a).text().toUpperCase()
      .indexOf(m[3].toUpperCase()) >= 0;
};

// add exists method to any jquery object
jQuery.fn.exists = function(){return ($(this).length > 0);}

// Store a reference to the original remove method.
var originalJQueryShowMethod = jQuery.fn.show;
// Define overriding method.
jQuery.fn.show = function(){
    $(this).removeClass('hidden').removeClass('hide')
    // Execute the original method.
    return originalJQueryShowMethod.apply( this, arguments );
}

jQuery.humanize = function(str) {
    return str.replace(/_/g, ' ')
        .replace(/(\w+)/g, function(match) {
            return match.charAt(0).toUpperCase() + match.slice(1);
        });
};
