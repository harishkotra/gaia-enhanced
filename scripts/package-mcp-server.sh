#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd "${script_dir}/.." && pwd -P)"

version="${MCP_SERVER_VERSION:-${1:-0.1.0}}"

cd "${repo_root}/mcp-server"

cargo build --release

binary_path="target/release/gaianet-mcp-server"
if [ ! -x "${binary_path}" ]; then
    echo "Build output not found at ${binary_path}" >&2
    exit 1
fi

os_name="$(uname -s)"
arch="$(uname -m)"

if [ "${os_name}" = "Darwin" ]; then
    if [ "${arch}" = "x86_64" ]; then
        suffix="apple-darwin-x86_64"
    elif [ "${arch}" = "arm64" ]; then
        suffix="apple-darwin-aarch64"
    else
        echo "Unsupported architecture: ${arch}" >&2
        exit 1
    fi
elif [ "${os_name}" = "Linux" ]; then
    if [ "${arch}" = "x86_64" ]; then
        suffix="unknown-linux-gnu-x86_64"
    else
        echo "Unsupported architecture: ${arch}" >&2
        exit 1
    fi
else
    echo "Unsupported OS: ${os_name}" >&2
    exit 1
fi

mkdir -p "${repo_root}/dist"
package_name="gaianet-mcp-server-${suffix}.tar.gz"
package_path="${repo_root}/dist/${package_name}"

tar -czf "${package_path}" -C "$(dirname "${binary_path}")" "$(basename "${binary_path}")"

echo "Created ${package_path} (version ${version})"
