# syntax=docker/dockerfile:1.4
#
# BashQuest door-game asset image. Unlike every other door here, bashquest.sh
# is a native late.sh original (Tony "Hardlygospel" Hosaroygard's own project,
# GPL-3.0), not a foreign upstream binary: there is nothing to compile, only a
# plain Bash script to fetch and pin. The stage below still follows the same
# discipline as every compiled door recipe (pinned source, verified checksum,
# fails closed on drift) so an unexpected change to the upstream script can
# never silently ride into a build. Built and pushed by
# .github/workflows/bashquest.yml as
# ghcr.io/mpiorowski/late-sh/door-bashquest:v1; the root Dockerfile pins that
# image as its bashquest-build stage. Bump the tag there on any recipe change.

ARG DEBIAN_VERSION=bookworm

# ==============================================================================
# Stage 0g: bashquest - fetch and verify the pinned bashquest.sh
# ==============================================================================
FROM debian:${DEBIAN_VERSION}-slim AS bashquest-build

# Pinned to a specific commit on hardlygospel/bashquest's main branch, not a
# moving branch ref, so the build is reproducible and a checksum mismatch
# means the pin is stale, not that upstream silently changed underneath us.
ARG BASHQUEST_COMMIT=67310d4670a104578b184f0c263563e909f4a93e
ARG BASHQUEST_URL=https://raw.githubusercontent.com/hardlygospel/bashquest/67310d4670a104578b184f0c263563e909f4a93e/bashquest.sh
ARG BASHQUEST_SHA256=e7f4bc2feaeae4faf63daa21452501b62286b922e33f2748318233d3b6ab21b7

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /bashquest.sh "${BASHQUEST_URL}" \
    && echo "${BASHQUEST_SHA256}  /bashquest.sh" | sha256sum -c - \
    && chmod 0755 /bashquest.sh
