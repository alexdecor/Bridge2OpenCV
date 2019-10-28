######################
# Options
######################

REVEAL_ARCHIVE_IN_FINDER=true


UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/iphoneuniversal"
OUTPUT_DIR="${PROJECT_DIR}/Output/iphoneuniversal/"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

######################
# Create directory for universal
######################

rm -rf "${UNIVERSAL_LIBRARY_DIR}"
mkdir -p "${UNIVERSAL_LIBRARY_DIR}"

######################
# Build Frameworks
######################

function build() {
    xcodebuild -project Bridge2OpenCV.xcodeproj -scheme $1 -sdk iphonesimulator -configuration Release clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/Release-iphonesimulator 2>&1
    xcodebuild -project Bridge2OpenCV.xcodeproj -scheme $1 -sdk iphoneos -configuration Release clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/Release-iphoneos 2>&1
    
    FRAMEWORK_NAME="$1"
    SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework"
    DEVICE_LIBRARY_PATH="${BUILD_DIR}/Release-iphoneos/${FRAMEWORK_NAME}.framework"
    FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${FRAMEWORK_NAME}.framework"
    
    mkdir "${FRAMEWORK}"
    
    ######################
    # Copy files Framework
    ######################
    
    cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"
    
    
    ######################
    # Make an universal binary
    ######################
    
    lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}" | echo
    
    # For Swift framework, Swiftmodule needs to be copied in the universal framework
    if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
    cp -f ${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/* "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
    fi
    
    if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
    cp -f ${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/* "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
    fi
    
    ######################
    # On Release, copy the result to release directory
    ######################
    
    cp -r "${FRAMEWORK}" "$OUTPUT_DIR"
    }
    
    frameworks=(Bridge2OpenCV)
    for framework in "${frameworks[@]}"
    do
    build $framework
    done
    
    if [ ${REVEAL_ARCHIVE_IN_FINDER} = true ]; then
    open "${OUTPUT_DIR}/"
    fi