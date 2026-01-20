
push:
	@git add .
	@git commit -am "Updated at $$(date)" || true
	@git push

test-server-init:
	@mush run -- server:init server1

test-server-list:
	@mush run -- server:list
