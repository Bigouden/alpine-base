#!/bin/sh

####################
# Global Variables #
####################

IMAGE="$CI_PROJECT_NAME"
OS_ARCHITECTURE="x86_64"
OS_DISTRIBUTION="alpine-minirootfs"
OS_MAJOR_VERSION="3.11"
OS_VERSION="${OS_MAJOR_VERSION}.6"
ROOTFS_FILE=${OS_DISTRIBUTION}-${OS_VERSION}-${OS_ARCHITECTURE}.tar.gz
SHA256_FILE=${OS_DISTRIBUTION}-${OS_VERSION}-${OS_ARCHITECTURE}.tar.gz.sha256
ROOTFS_URL=http://dl-cdn.alpinelinux.org/alpine/v${OS_MAJOR_VERSION}/releases/${OS_ARCHITECTURE}/${ROOTFS_FILE}
SHA256_URL=http://dl-cdn.alpinelinux.org/alpine/v${OS_MAJOR_VERSION}/releases/${OS_ARCHITECTURE}/${SHA256_FILE}

##########################
# Functions Declarations #
##########################

# Checksum Control
checksum () {
    log "Checksum Control ..."
    log "FILE   :  $(sha256sum ${2})"
    log "SHA256 :  $(cat ${1})"
    sha256sum --check --status ${1} || { RCODE=${?}; log "Failed to verify checksum for file : ${2}" ; exit ${RCODE}; }
    log "Checksum Control OK"
}

# Downloading
download () {
    log "Downloading ..."
    log "URL  : ${2}"
    log "FILE : ${1}"
    curl -f -s -O ${2} || { RCODE=${?}; log "Failed to download : ${1}" ; exit ${RCODE}; }
    log "Download OK"
}

# Import
import() {
    log "Importing RootFS ..."
    docker import ${1} ${2} > /dev/null || { RCODE=${?}; log "Failed to import RootFS : ${1}"; exit ${RCODE}; }
    log "Import OK"
    log "IMAGE  : ${IMAGE}"
}

# Logging 
log () {
	printf "$(date +'%F - %T - ')${1}\n"
}

########
# Main #
########

# Download Files
download ${ROOTFS_FILE} ${ROOTFS_URL}
download ${SHA256_FILE} ${SHA256_URL}

# Checksum Control
checksum ${SHA256_FILE} ${ROOTFS_FILE}

# Docker Import
import ${ROOTFS_FILE} ${IMAGE}
