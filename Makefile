
# build webpages to docs directory and deploy to website branch.
deploy:
	gitbook build . docs
	git checkout website
	git add docs
	git ci -m "update website"
	git push
