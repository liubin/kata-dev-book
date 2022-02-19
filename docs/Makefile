SHELL:=bash

# build webpages to docs directory and deploy to website branch.
deploy:
	git diff --exit-code || (echo - "\n\n\n\nPLEASE COMMIT CHANGES IN MAIN BRANCH FIRST!\n\n\n\n"; exit 1)
	export build_at=``
	sed -i -e 's/BUILD_VERSION/$(shell git rev-parse HEAD)/g' README.md
	sed -i -e 's/BUILD_DATE/$(shell date '+%Y-%m-%d %H:%M:%S')/g' README.md
	gitbook build . docs-new
	git checkout README.md
	git checkout website
	rm -rf docs && mv docs-new docs
	git add docs
	git ci -m "update website"
	git push
	git checkout main

pdf:
	gitbook pdf
preview:
	$(call nvm,use,v10.24.0)
	gitbook serve
