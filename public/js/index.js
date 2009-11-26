
function initialize() {
	$.ajax({
		url: "newuser",
		data: "page=0",
		success: function(html){
			$("#newuser").replaceWith(html);
		}
	});
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
