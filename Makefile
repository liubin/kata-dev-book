# build webpages to docs directory and deploy to website branch.
deploy:
	git diff --exit-code || (echo - "\n\n\n\nPLEASE COMMIT CHANGES IN MAIN BRANCH FIRST!\n\n\n\n"; exit 1)
	gitbook build . docs-new
	git checkout website
	rm -rf docs && mv docs-new docs
	git add docs
	git ci -m "update website"
	git push
