# By default use production (ros2/rosindex:gh-pages) as the cache so a build
# always starts from a known good state.
cache_url=`git remote get-url origin`
cache_branch=gh-pages

staging_url=git@github.com:sloretz/rosindex-staging.git
staging_branch=gh-pages

# This target is invoked by a doc_independent job on the ROS buildfarm.
html: download-cache build deploy-staging

# Clone a bunch of other repos part of the rosdistro and build the index.
build:
	bundle exec jekyll build --verbose --trace --config=_config.yml

# Push to a staging github repo for use with github pages.
# A pull request to production must be manually created.
deploy-staging:
	git clone $(staging_url) --branch $(staging_branch) _deploy
	# Copy new files from last build
	cp -R _build _deploy
	# copy modified cache files to staging
	cp --no-clobber --verbose _caches/* _deploy
	cd _deploy && git status
	cd _deploy && git commit -m "make deploy-staging by `whoami` on `date`"
	cd _deploy && git push

download-cache:
	mkdir -p _checkout
	git submodule update --init --recursive --force
	# Shallow clone cache repo since it won't be pushed to from this script
	git clone $(cache_url) --depth 1 --branch $(cache_branch) _caches

clean:
	rm -rf _caches
	rm -rf _deploy
	rm -rf _build
	rm -rf _rosdistro/*
	rm -rf _checkout
