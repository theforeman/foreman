$(function () {

  $('[data-toggle="popover"]').on('click', function () {
     var prev_popover = $('.popover:visible').prev('a');
     if (!$(this).is(prev_popover))
       prev_popover.popover('toggle');
     $(this).popover('toggle');
  });

});
