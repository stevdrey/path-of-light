# Wiki maintenance

`docs/wiki/` on the repository default branch is the source of truth. Edit and review pages there; the workflow copies Markdown pages to the GitHub wiki on changes to that directory or a manual run. It updates matching filenames and preserves other wiki files. Direct wiki edits to managed filenames will be overwritten.

An administrator must enable and initialize the GitHub wiki with a first page and configure the repository Actions secret `WIKI_SYNC_TOKEN` with a credential authorized to write that wiki. Verify that the credential works for the wiki repository; `GITHUB_TOKEN` access to wiki repositories is not assumed. Run the workflow manually and inspect both its logs and published pages. Rotate the token through repository settings; never commit it or print it in logs. If access is unavailable, the source remains usable in the repository.
