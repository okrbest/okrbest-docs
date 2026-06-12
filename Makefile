# Makefile for Sphinx documentation
#
.PHONY: Makefile help python-deps linkcheck livehtml python-deps test compass-icons gettext-pot update-po-ko stat-ko html-ko livehtml-ko package-ko

# Check Make version (we need at least GNU Make 3.82). Fortunately,
# 'undefine' directive has been introduced exactly in GNU Make 3.82.
#
# Platform notes:
#
#    macOS has shipped with v3.81 of GNU Make pre-installed and may
#    cause this error. A modern version of GNU Make can be installed
#    using Homebrew (https://brew.sh/).
#
#    Windows users can install a modern version of GNU Make using
#    the Chocolatey (https://chocolatey.org) package manager.
#
ifeq ($(filter undefine,$(.FEATURES)),)
$(error Unsupported Make version. \
    The build system does not work properly with GNU Make $(MAKE_VERSION), \
    please use GNU Make 3.82 or above.)
endif

#
# You can set these variables from the command line, and also
# from the environment for the last three.
SOURCEDIR       = source
BUILDDIR        = build
SPHINXOPTS      ?= -j auto
SPHINXBUILD     ?= pipenv run sphinx-build
SPHINXAUTOBUILD ?= pipenv run sphinx-autobuild
AUTOBUILDOPTS   ?= -D=html_baseurl=http://127.0.0.1:8000

# If we're using Windows, use CMD to run commands in the Makefile.
ifeq ($(OS),Windows_NT)
SHELL=C:\Windows\system32\cmd.exe
.SHELLFLAGS=/C
WARNINGSFILE=$(BUILDDIR)\warnings.log
else
WARNINGSFILE=$(BUILDDIR)/warnings.log
endif

# If we're not on Windows, check to see if 'mm_url_path_prefix' is included in SPHINXOPTS.
# If it is included, extract the PR ID from the prefix and set the html_baseurl config
# option to the preview environment.
ifneq ($(OS),Windows_NT)
ifeq ($(findstring mm_url_path_prefix,$(SPHINXOPTS)),mm_url_path_prefix)
PATH_PREFIX = $(shell echo "$(SPHINXOPTS)" | grep -Eo 'mm_url_path_prefix=\/([0-9]+)' | cut -d / -f 2)
SPHINXOPTS2 = $(SPHINXOPTS) -D html_baseurl=http://mattermost-docs-preview-pulls.s3-website-us-east-1.amazonaws.com/$(PATH_PREFIX)
else
SPHINXOPTS2 = $(SPHINXOPTS)
endif
endif

# Put the help target first so that "make" without arguments runs like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Install necessary dependencies for the Mattermost docs CI build pipeline.
# NOTE: if the version of Python used to build the docs changes, update the `pipenv` command below accordingly.
python-deps:
	pip install pipenv==2025.0.2
	pipenv install --dev --clear --deploy --python 3.12

# Run `make test` to start Sphinx extension unit tests.
test:
	pipenv run pytest

# Run `make livehtml` to start sphinx-autobuild.
# Note: sphinx-autobuild seems to want a build directory
#       setting of $(BUILDDIR)/html instead of $(BUILDDIR)
#       to use the output of a previous `make html` build.
livehtml:
ifeq ($(OS),Windows_NT)
	@IF NOT EXIST $(BUILDDIR) MD $(BUILDDIR)
	@$(SPHINXAUTOBUILD) "$(SOURCEDIR)" "$(BUILDDIR)\html" -d "$(BUILDDIR)\doctrees" $(SPHINXOPTS) $(AUTOBUILDOPTS) $(O)
else
	@mkdir -p "$(BUILDDIR)"
	@$(SPHINXAUTOBUILD) "$(SOURCEDIR)" "$(BUILDDIR)/html" -d "$(BUILDDIR)/doctrees" $(SPHINXOPTS) $(AUTOBUILDOPTS) $(O)
endif

# Run `make linkcheck` to check external links.
# Overriding `exclude_patterns` configuration to exclude
# directories or files not included in the documentation.
linkcheck:
ifeq ($(OS),Windows_NT)
	@IF NOT EXIST $(BUILDDIR) MD $(BUILDDIR)
	@$(SPHINXBUILD) -M $@ -D exclude_patterns=archive\*,process\* "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) -w "$(WARNINGSFILE)"
else
	@mkdir -p "$(BUILDDIR)"
	@$(SPHINXBUILD) -M $@ -D exclude_patterns=archive/*,process/* "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) -w "$(WARNINGSFILE)"
endif

# Run `make compass-icons` to download the latest Compass Icons assets.
# This target requires the cURL utility. See https://curl.se/ for download instructions.
compass-icons:
ifeq ($(OS),Windows_NT)
	@IF NOT EXIST source/_static/css MD source/_static/css
	@IF NOT EXIST source/_static/font MD source/_static/font
else
	@mkdir -p source/_static/css
	@mkdir -p source/_static/font
endif
	curl --no-progress-meter -o source/_static/css/compass-icons.css https://mattermost.github.io/compass-icons/css/compass-icons.css
	curl --no-progress-meter -o "source/_static/font/compass-icons.#1" "https://mattermost.github.io/compass-icons/font/compass-icons.{eot,woff2,woff,ttf,svg}"

# --- Korean translation (gettext) -------------------------------------------
#
# NOTE: deliberately no LANG variable here. LANG is a standard POSIX locale
# environment variable (e.g. en_US.UTF-8) that make inherits from the shell,
# so `LANG ?= en` silently picks up the locale string and breaks the build.
# These targets are Linux/macOS only.
#
# SPHINXINTL is the standalone sphinx-intl CLI (install: `uv tool install
# sphinx-intl` or `pip install --user sphinx-intl`). It is intentionally NOT
# in the Pipfile: the upstream awscli pin (docutils<=0.19) conflicts with
# sphinx-intl's sphinx dependency (docutils>=0.20) inside the dev category.
# Only update-po-ko/stat-ko need it; html-ko does not (Sphinx compiles
# .po -> .mo itself at build time).

SPHINXINTL ?= sphinx-intl
LOCALESDIR  = $(SOURCEDIR)/locales
POTDIR      = $(BUILDDIR)/gettext

# Extract translatable strings into .pot templates under build/gettext/.
gettext-pot:
	@mkdir -p "$(BUILDDIR)"
	@$(SPHINXBUILD) -b gettext "$(SOURCEDIR)" "$(POTDIR)" $(SPHINXOPTS) $(O) -w "$(BUILDDIR)/warnings-gettext.log"

# Create/refresh Korean .po catalogs (msgmerge with fuzzy matching;
# preserves existing translations).
update-po-ko: gettext-pot
	@$(SPHINXINTL) update -p "$(POTDIR)" -d "$(LOCALESDIR)" -l ko

# Per-file translation progress (translated / fuzzy / untranslated).
stat-ko:
	@$(SPHINXINTL) stat -d "$(LOCALESDIR)" -l ko

# Korean HTML into build/html/ko/ (en stays at build/html/). Separate
# doctrees dir is REQUIRED: doctree caches are language-specific.
html-ko:
	@mkdir -p "$(BUILDDIR)"
	@$(SPHINXBUILD) -b html -D language=ko "$(SOURCEDIR)" "$(BUILDDIR)/html/ko" -d "$(BUILDDIR)/doctrees-ko" $(SPHINXOPTS2) $(O) -w "$(BUILDDIR)/warnings-ko.log"

# Live-reload Korean preview; --watch picks up .po edits.
# --ignore "*.mo" is REQUIRED: Sphinx rewrites compiled .mo files inside
# source/locales on every build, which the watcher would otherwise see as a
# source change, triggering an infinite full-rebuild loop (and eventual OOM).
# On low-memory machines run: make livehtml-ko SPHINXOPTS="-j 2"
livehtml-ko:
	@mkdir -p "$(BUILDDIR)"
	@$(SPHINXAUTOBUILD) "$(SOURCEDIR)" "$(BUILDDIR)/html/ko" -d "$(BUILDDIR)/doctrees-ko" -D language=ko --watch "$(LOCALESDIR)" --ignore "*.mo" $(SPHINXOPTS) $(AUTOBUILDOPTS) $(O)

# Package the Korean site as a tarball for deployment.
package-ko: html-ko
	@tar -czf "$(BUILDDIR)/okrbest-docs-ko.tgz" -C "$(BUILDDIR)/html/ko" .

# Catch-all target: route all unknown targets to Sphinx using the
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
# Note: Instead of $(SPHINXOPTS), non-Windows (i.e. Linux) systems use $(SPHINXOPTS2)
#       to account for Mattermost docs preview builds.
%: Makefile
ifeq ($(OS),Windows_NT)
	@IF NOT EXIST $(BUILDDIR) MD $(BUILDDIR)
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O) -w "$(WARNINGSFILE)"
else
	@mkdir -p "$(BUILDDIR)"
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS2) $(O) -w "$(WARNINGSFILE)"
endif
