import {microblog} from "../../declarations/microblog";

async function post() {
	let post_button = document.getElementById("post");
	post_button.disabled = true;
	let textarea = document.getElementById("message");
	let text = textarea.value;
	await microblog.post(text);
	post_button.disabled = false;
}

async function getPosts(pid, posts_section) {
	let posts = await microblog.get_someone_posts(pid);
	posts_section.replaceChildren([]);
	let post = document.createElement("l");
	post.innerText = "当前点击用户发布内容如下\n";
	posts_section.appendChild(post);
	for (var i = 0; i < posts.length; i++) {
		let post = document.createElement("p");
		let date = new Date(Number(posts[i]["time"]) / 1000000).toLocaleString().replace(/:\d{1,2}$/, " ");
		post.innerText = "发布内容：" + posts[i]["text"] + "\n" + "author: " + posts[i]["author"] + ", date: " + date;
		posts_section.appendChild(post);
	}
}

let posts_length = 0;
async function load_posts() {
	let posts_section = document.getElementById("posts");
	let posts = await microblog.posts(0);
	if (posts_length < posts.length) {
		posts_section.replaceChildren([]);
		for (var i = 0; i < posts.length; i++) {
			let post = document.createElement("p");
			let date = new Date(Number(posts[i]["time"]) / 1000000).toLocaleString().replace(/:\d{1,2}$/, " ");
			post.innerText = posts[i]["text"] + "\n" + "author: " + posts[i]["author"] + ", date: " + date;
			posts_section.appendChild(post);
		}
		posts_length = posts.length;
	}
}

let follow_length = 0;
async function load_followed() {
	let followed_section = document.getElementById("followed");
	if (follow_length == followed_section.length){return;};
	follow_length = followed_section.length;
	followed_section.replaceChildren([]);
	let followed = await microblog.get_follow_infos();
	let posts_section = document.getElementById("follows_post");
	posts_section.replaceChildren([]);
	
	let postsList = document.querySelector("#postsList");
	if (!postsList) {
		postsList = document.createElement("div");

		postsList.id = "postsList";
		posts_section.appendChild(postsList);
	}
	let pid;
	for (var i = 0; i < followed.length; i++) {
		console.log("dasdfjaklfhakj");
		let follow = document.createElement("f");
		pid = followed[i]["pid"];
		follow.innerText =  "用户名" + i + ":  " + followed[i]["name"] + "\n";
		follow.style = "color : yellow";
		follow.onclick = function(){
			getPosts(pid, postsList);
		}(pid, postsList);
		followed_section.appendChild(follow);
	}
}


function load() {
	let post_button = document.getElementById("post");
	post_button.onclick = post;
	load_posts();
	load_followed();
	setInterval(load_posts, 5000);
	setInterval(load_followed, 5000);
}

window.onload = load;
