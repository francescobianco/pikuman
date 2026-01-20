
push:
	@git add .
	@git commit -am "Updated at $$(date)" || true
	@git push

install:
	@mush install --path .

test-server-init:
	@mush run -- server:init server1

test-server-list:
	@mush run -- server:list

test-repo-init:
	@mush build
	@export PIKUMAN_HOSTS=../../.hosts && \
		cd tests/demo1 && \
		../../target/debug/pikuman repo:init server1 demo1 && \
		git branch -M main && \
		git add index.html && \
		git commit -m "Initial commit" || true && \
		git push --set-upstream piku main
		git push piku main
