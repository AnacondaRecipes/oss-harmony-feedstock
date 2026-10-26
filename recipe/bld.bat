@echo on

:: zstd-sys hardcodes pkg_config(...).statik(true), which selects the static
:: zstd lib even when ZSTD_SYS_USE_PKG_CONFIG is set. Override its build script
:: (links = "zstd") so we link conda's shared zstd instead.
for /f "tokens=2" %%i in ('rustc -vV ^| findstr /b host:') do set HOST_TRIPLE=%%i

mkdir .cargo
(
echo [target.%HOST_TRIPLE%.zstd]
echo rustc-link-search = ['%LIBRARY_LIB%']
echo rustc-link-lib = ["zstd"]
) > .cargo\config.toml
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1
