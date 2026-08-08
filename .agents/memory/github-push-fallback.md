---
name: GitHub push fallback
description: The native GitHub push helper may reject updates to an already-existing branch even after authorization.
---

When the user has explicitly authorized a secure repository credential, a direct `git push` can be used as a fallback if the native GitHub push helper rejects an existing branch.

**Why:** The helper can return `BRANCH_ALREADY_EXISTS` or `PUSH_REJECTED` while the repository has a valid remote branch and the local commit is ready.

**How to apply:** Never print or expose the credential. Verify the remote commit SHA and required files after pushing, and do not force-update a branch without explicit user confirmation.