$(document).on('ContentLoad', function() { disableAll(); });

function disableAll () {
	$( "textarea" ).each( function() {
		this.disabled = true;
	});
	$( "a.btn" ).each( function() {
		this.remove();
	});
	$( "input.btn" ).each( function() {
		this.remove();
	});
	$( "select" ).each( function() {
		this.disabled = true;
	});
	$( "input" ).each( function() {
		this.disabled = true;
	});
}
