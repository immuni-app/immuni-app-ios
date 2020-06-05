# Configuration variables:

# The bundle version of the app.
ifeq ($(BUNDLE_VERSION),)
	export BUNDLE_VERSION := 999
endif

# Whether dev tooling are enabled
ifeq ($(EXCLUDE_DEV_TOOLING),)
	export PROJECT_YAML_FILE := project_debug.yml
else
	export PROJECT_YAML_FILE := project.yml
endif

# Prepare Application workspace for production application
immuni: export SUPPORT_EMAIL = tbd@immuni.org
immuni: export APPSTORE_ID = 1513940977
immuni:
	swiftgen
	xcodegen generate --spec "${PROJECT_YAML_FILE}"

	@if [ -z "$(CI_MODE)" ]; then \
	    pod install; \
			open Immuni.xcworkspace; \
	fi

# Perform UI Tests for the application
# The output will be in: UITests/Screenshots
run_uitests: 
	python UITests/run.py ct-app Immuni.xcworkspace Immuni true 3 en de it

# Reset the project for a clean build
reset:
	rm -rf Immuni.xcodeproj
	rm -rf Immuni.xcworkspace
	rm -rf Pods/

# Install dependencies, download build resources and add pre-commit hook
setup:
	gem install cocoapods -v 1.9.1
	brew bundle
	eval "$$add_pre_commit_script"
	npm install -g @commitlint/cli @commitlint/config-conventional
	sed -e "/^[//].*/d" -e "s/export default/module.exports = { rules: /g" -e "s/};/}};/g" -e "/^$$/d" CI/danger/commitlint/rules.ts > commitlint.config.js
	eval "$$add_commit_msg_script"

###

# Define pre commit script to auto lint and format the code
define _add_pre_commit
SWIFTLINT_PATH=`which swiftlint`
SWIFTFORMAT_PATH=`which swiftformat`

cat > .git/hooks/pre-commit << ENDOFFILE
#!/bin/sh

FILES=\$(git diff --cached --name-only --diff-filter=ACMR "*.swift" | sed 's| |\\ |g')
[ -z "\$FILES" ] && exit 0

# Format
${SWIFTFORMAT_PATH} \$FILES

# Lint
${SWIFTLINT_PATH} autocorrect \$FILES
${SWIFTLINT_PATH} lint \$FILES

# Add back the formatted/linted files to staging
echo "\$FILES" | xargs git add

exit 0
ENDOFFILE

chmod +x .git/hooks/pre-commit
endef
export add_pre_commit_script = $(value _add_pre_commit)

# Define commit msg script to auto check commit msg
define _add_commit_msg

cat > .git/hooks/commit-msg << ENDOFFILE
#!/bin/sh

cat \$1 | commitlint
ENDOFFILE

chmod +x .git/hooks/commit-msg
endef
export add_commit_msg_script = $(value _add_commit_msg) 