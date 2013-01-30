jQuery ->
  $('a[rel=popover]').popover({html: true})
  $('*[title]').not('*[rel]').tooltip()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()