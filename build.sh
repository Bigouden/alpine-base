#!/bin/sh

####################
# Global Variables #
####################

IMAGE="$CI_PROJECT_NAME"
OS_ARCHITECTURE="x86_64"
OS_DISTRIBUTION="alpine-minirootfs"
OS_MAJOR_VERSION="3.11"
OS_VERSION="${OS_MAJOR_VERSION}.6"
COMPRESS_ROOTFS_FILE=${OS_DISTRIBUTION}-${OS_VERSION}-${OS_ARCHITECTURE}.tar.gz
COMPRESS_SHA256_FILE=${OS_DISTRIBUTION}-${OS_VERSION}-${OS_ARCHITECTURE}.tar.gz.sha256
ROOTFS_FILE=${OS_DISTRIBUTION}-${OS_VERSION}-${OS_ARCHITECTURE}.tar
ROOTFS_URL=http://dl-cdn.alpinelinux.org/alpine/v${OS_MAJOR_VERSION}/releases/${OS_ARCHITECTURE}/${COMPRESS_ROOTFS_FILE}
SHA256_URL=http://dl-cdn.alpinelinux.org/alpine/v${OS_MAJOR_VERSION}/releases/${OS_ARCHITECTURE}/${COMPRESS_SHA256_FILE}

##########################
# Functions Declarations #
##########################

# Checksum Control
checksum () {
    log "Checksum Control ..."
    log "FILE   :  $(sha256sum ${2})"
    log "SHA256 :  $(cat ${1})"
    sha256sum -c -s ${1} || { RCODE=${?}; log "Failed to verify checksum for file : ${2}" ; exit ${RCODE}; }
    log "Checksum Control OK"
}

# Cleanup
clean ()
    log "Cleaning ..."
    log "FILE : ${1}"
    gunzip ${1}
    tar -f ${2} --wildcards --delete ./lib/apk/db/*
    log "Clean OK"

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
download ${COMPRESS_ROOTFS_FILE} ${ROOTFS_URL}
download ${COMPRESS_SHA256_FILE} ${SHA256_URL}

# Checksum Control
checksum ${COMPRESS_SHA256_FILE} ${COMPRESS_ROOTFS_FILE}

# Clean RootFS
clean ${COMPRESS_ROOTFS_FILE} ${ROOTFS_FILE}

# Docker Import
import ${ROOTFS_FILE} ${IMAGE}
