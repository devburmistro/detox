#!/bin/bash -e

detoxRootPath="$(dirname $(dirname ${0}))"
detoxVersion=`node -p "require('${detoxRootPath}/package.json').version"`

sha1=`(echo "${detoxVersion}" && xcodebuild -version) | shasum | awk '{print $1}' #"${2}"`
detoxFrameworkDirPath="$HOME/Library/Detox/ios/${sha1}"
detoxFrameworkPath="${detoxFrameworkDirPath}/Detox.framework"
detoxSourcePath="${detoxRootPath}"/ios_src

function buildFramework {
  echo "Extracting Detox sources..."

  mkdir -p "${detoxSourcePath}"
  tar -xjf "${detoxRootPath}"/Detox-ios-src.tbz -C "${detoxSourcePath}"

  echo "Building Detox.framework..."

  mkdir -p "${detoxFrameworkDirPath}"
  xcodebuild build -project "${detoxSourcePath}"/Detox.xcodeproj -scheme DetoxFramework -configuration Release -derivedDataPath "${detoxFrameworkDirPath}"/DetoxBuild BUILD_DIR="${detoxFrameworkDirPath}"/DetoxBuild/Build/Products &> "${detoxFrameworkDirPath}"/detox_ios.log
  mv "${detoxFrameworkDirPath}"/DetoxBuild/Build/Products/Release-universal/Detox.framework "${detoxFrameworkDirPath}"
  rm -fr "${detoxFrameworkDirPath}"/DetoxBuild
  rm -fr "${detoxSourcePath}"

  echo "Done"
}


function main {
  if [ -d "${detoxFrameworkDirPath}" ]; then
    if [ ! -d "${detoxFrameworkPath}" ]; then
      echo "${detoxFrameworkDirPath} was found, but could not find Detox.framework inside it. This means that the Detox framework build process was interrupted.
         deleting ${detoxFrameworkDirPath} and trying to rebuild."
      rm -rf "${detoxFrameworkDirPath}"
      buildFramework
    else
      echo "Detox.framework was previously compiled, skipping..."
    fi
  else
    buildFramework
  fi
}

main
