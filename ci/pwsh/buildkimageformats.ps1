#! /usr/bin/pwsh

# Clone
git clone https://invent.kde.org/frameworks/kimageformats.git
cd kimageformats
git checkout $(git describe --abbrev=0).substring(0, 7)


# Get dependencies
if ($IsWindows) {
    choco install ninja nasm
} elseif ($IsMacOS) {
    brew update
    brew install ninja nasm extra-cmake-modules libheif karchive
} else {
    sudo apt-get install ninja-build
    brew update
    brew install nasm openexr libheif karchive
    # Build extra-cmake-modules
    & "$env:BUILD_REPOSITORY_LOCALPATH/ci/pwsh/buildecm.ps1"
}



# Build

# vcvars on windows
if ($IsWindows) {
    & "$env:BUILD_REPOSITORY_LOCALPATH/ci/pwsh/vcvars.ps1"
}

# Build libavif dependency

& "$env:BUILD_REPOSITORY_LOCALPATH/ci/pwsh/buildlibavif.ps1"

$env:libavif_DIR = "libavif/build/installed/usr/local/lib/cmake/libavif/"


cmake -DCMAKE_BUILD_TYPE=Release -DKIMAGEFORMATS_HEIF=ON .

if ($IsWindows) {
    nmake
} else {
    make
    sudo make install
}