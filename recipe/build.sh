#!/bin/bash
set -ex

# zstd-sys hardcodes pkg_config(...).statik(true), which selects libzstd.a
# even when ZSTD_SYS_USE_PKG_CONFIG is set. Override its build script
# (links = "zstd") so we link conda's shared libzstd instead.
# Safe because zstd-sys is built without the `bindgen` feature, so the
# pre-generated bindings are used and build.rs output is not needed.
HOST_TRIPLE=$(rustc -vV | sed -n 's/^host: //p')
mkdir -p .cargo
cat > .cargo/config.toml <<EOT
[target.${HOST_TRIPLE}.zstd]
rustc-link-search = ["${PREFIX}/lib"]
rustc-link-lib = ["zstd"]
EOT

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
