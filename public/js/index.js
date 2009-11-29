
function initialize() {
	next_new_user(0);
}
function next_new_user(page) {
	$.ajax({
		url: "newuser",
		data: "page=" + page,
		success: function(html){
			$("#newuser").replaceWith(html);
		}
	});
}
