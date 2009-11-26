
function initialize() {
	$.ajax({
		url: "newuser",
		success: function(html){
			$("#newuser").replaceWith(html);
		}
	});
}
