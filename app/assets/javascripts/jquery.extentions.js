// case insensitive version of the contains selector
jQuery.expr[':'].icontains = function(a, i, m) {
  return jQuery(a).text().toUpperCase()
      .indexOf(m[3].toUpperCase()) >= 0;
};

// add exists method to any jquery object
jQuery.fn.exists = function(){return ($(this).length > 0);}
