#!/usr/bin/env ruby
# frozen_string_literal: true

BUILD_ONLY = false
GIT_TAG = "master"

COMMON_CHAIN_NAME = "phala"
COMMON_TAG = "23111001"

NODE_GIT_TAG = GIT_TAG
NODE_DOCKER_TAG = COMMON_TAG
NODE_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-node"

PHERRY_GIT_TAG = GIT_TAG
PHERRY_DOCKER_TAG = COMMON_TAG
PHERRY_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-pherry"

HEADERS_CACHE_GIT_TAG = GIT_TAG
HEADERS_CACHE_DOCKER_TAG = COMMON_TAG
HEADERS_CACHE_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-headers-cache"

REPLAY_GIT_TAG = GIT_TAG
REPLAY_DOCKER_TAG = COMMON_TAG
REPLAY_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-replay"

PRB_GIT_TAG = GIT_TAG
PRB_DOCKER_TAG = COMMON_TAG
PRB_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-prb"

PROUTER_GIT_TAG = GIT_TAG
PROUTER_DOCKER_TAG = COMMON_TAG
PROUTER_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-prouter"

PRUNTIME_GIT_TAG = GIT_TAG
PRUNTIME_DOCKER_TAG = COMMON_TAG
PRUNTIME_EPID_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-pruntime-v2"
PRUNTIME_EPID_WITH_HANDOVER_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-pruntime-v2-with-handover"
PRUNTIME_DCAP_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-pruntime-v2-dcap"
PRUNTIME_DCAP_WITH_HANDOVER_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-pruntime-v2-dcap-with-handover"

SGX_DETECT_DOCKER_REPO = "phala-sgx_detect"

DCAP_TEST_DOCKER_REPO = "phala-dcap_test"

REGISTRIES = [
  "jasl123",
  # "phalanetwork",
  # "swr.cn-east-3.myhuaweicloud.com/phala",
  # "docker.pkg.github.com/phala-network/phala-docker"
]

require "open3"

def run(cmd)
  Open3.popen2e(cmd) do |_stdin, stdout_err, wait_thr|
    while (line = stdout_err.gets)
      puts line
    end
  
    exit_status = wait_thr.value
    unless exit_status.success?
      abort "error"
    end
  end
end

# # Build SGX-Detect
# REGISTRIES.each do |registry|
#   [
#     "docker build -f sgx_detect.Dockerfile -t #{registry}/#{SGX_DETECT_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push SGX-Detect
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{SGX_DETECT_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build DCAP test
# REGISTRIES.each do |registry|
#   [
#     "docker build -f dcap_test.Dockerfile -t #{registry}/#{DCAP_TEST_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push DCAP test
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{DCAP_TEST_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build prebuilt pRuntime
# REGISTRIES.each do |registry|
#   [
#     "docker build -f prebuilt_pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} .",
#     "docker build -f prebuilt_pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push prebuilt pRuntime
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{PRUNTIME_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG}",
#       "docker push #{registry}/#{PRUNTIME_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# Build pRuntime variants
SGX_SIGNER_KEY = "Enclave_private.prod.decrypted.pem"
IAS_SPID = ENV.fetch("IAS_SPID")
IAS_API_KEY = ENV.fetch("IAS_API_KEY")
IAS_LINKABLE = ENV.fetch("IAS_LINKABLE")
IAS_ENV = "PROD"
PRUNTIME_VERSION = ENV.fetch("PRUNTIME_VERSION", PRUNTIME_DOCKER_TAG)
REAL_PRUNTIME_DATA_DIR = "/opt/pruntime/data/#{PRUNTIME_VERSION}"

# Build pRuntime EPID variant
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{PRUNTIME_GIT_TAG} --build-arg SGX_SIGNER_KEY=/root/.priv/#{SGX_SIGNER_KEY} --build-arg RA_TYPE=epid --build-arg IAS_SPID=#{IAS_SPID} --build-arg IAS_LINKABLE=#{IAS_LINKABLE} --build-arg IAS_API_KEY=#{IAS_API_KEY} --build-arg IAS_ENV=#{IAS_ENV} --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime.Dockerfile -t #{registry}/#{PRUNTIME_EPID_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} .",
    "docker build --build-arg PHALA_GIT_TAG=#{PRUNTIME_GIT_TAG} --build-arg SGX_SIGNER_KEY=/root/.priv/#{SGX_SIGNER_KEY} --build-arg RA_TYPE=epid --build-arg IAS_SPID=#{IAS_SPID} --build-arg IAS_LINKABLE=#{IAS_LINKABLE} --build-arg IAS_API_KEY=#{IAS_API_KEY} --build-arg IAS_ENV=#{IAS_ENV} --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime.Dockerfile -t #{registry}/#{PRUNTIME_EPID_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push pRuntime EPID variant
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PRUNTIME_EPID_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG}",
      "docker push #{registry}/#{PRUNTIME_EPID_DOCKER_REPO}"
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end

# Build pRuntime EPID variant with handover launcher
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PRUNTIME_BASE_IMAGE=#{registry}/#{PRUNTIME_EPID_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime-with-handover.Dockerfile -t #{registry}/#{PRUNTIME_EPID_WITH_HANDOVER_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} .",
    "docker build --build-arg PRUNTIME_BASE_IMAGE=#{registry}/#{PRUNTIME_EPID_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime-with-handover.Dockerfile -t #{registry}/#{PRUNTIME_EPID_WITH_HANDOVER_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push pRuntime EPID variant with handover launcher
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PRUNTIME_EPID_WITH_HANDOVER_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG}",
      "docker push #{registry}/#{PRUNTIME_EPID_WITH_HANDOVER_DOCKER_REPO}"
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end

# Build pRuntime DCAP variant
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{PRUNTIME_GIT_TAG} --build-arg SGX_SIGNER_KEY=/root/.priv/#{SGX_SIGNER_KEY} --build-arg RA_TYPE=dcap --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DCAP_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} .",
    "docker build --build-arg PHALA_GIT_TAG=#{PRUNTIME_GIT_TAG} --build-arg SGX_SIGNER_KEY=/root/.priv/#{SGX_SIGNER_KEY} --build-arg RA_TYPE=dcap --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DCAP_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push pRuntime DCAP variant
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PRUNTIME_DCAP_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG}",
      "docker push #{registry}/#{PRUNTIME_DCAP_DOCKER_REPO}"
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end

# Note: handover for DCAP variant isn't support yet
# # Build pRuntime DCAP variant with handover launcher
# REGISTRIES.each do |registry|
#   [
#     "docker build --build-arg PRUNTIME_BASE_IMAGE=#{registry}/#{PRUNTIME_DCAP_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime-with-handover.Dockerfile -t #{registry}/#{PRUNTIME_DCAP_WITH_HANDOVER_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} .",
#     "docker build --build-arg PRUNTIME_BASE_IMAGE=#{registry}/#{PRUNTIME_DCAP_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} --build-arg PRUNTIME_VERSION=#{PRUNTIME_VERSION} --build-arg REAL_PRUNTIME_DATA_DIR=#{REAL_PRUNTIME_DATA_DIR} -f pruntime-with-handover.Dockerfile -t #{registry}/#{PRUNTIME_DCAP_WITH_HANDOVER_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push pRuntime DCAP variant with handover launcher
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{PRUNTIME_DCAP_WITH_HANDOVER_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG}",
#       "docker push #{registry}/#{PRUNTIME_DCAP_WITH_HANDOVER_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build PRouter
# REGISTRIES.each do |registry|
#   [
#     "docker build --build-arg PHALA_GIT_TAG=#{PROUTER_GIT_TAG} -f prouter.Dockerfile -t #{registry}/#{PROUTER_DOCKER_REPO}:#{PROUTER_DOCKER_TAG} .",
#     "docker build --build-arg PHALA_GIT_TAG=#{PROUTER_GIT_TAG} -f prouter.Dockerfile -t #{registry}/#{PROUTER_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push PRouter
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{PROUTER_DOCKER_REPO}:#{PROUTER_DOCKER_TAG}",
#       "docker push #{registry}/#{PROUTER_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build Phala-Node
# REGISTRIES.each do |registry|
#   [
#     "docker build --build-arg PHALA_GIT_TAG=#{NODE_GIT_TAG} -f node.Dockerfile -t #{registry}/#{NODE_DOCKER_REPO}:#{NODE_DOCKER_TAG} .",
#     "docker build --build-arg PHALA_GIT_TAG=#{NODE_GIT_TAG} -f node.Dockerfile -t #{registry}/#{NODE_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push Phala-Node
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{NODE_DOCKER_REPO}:#{NODE_DOCKER_TAG}",
#       "docker push #{registry}/#{NODE_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build Phala-Pherry
# REGISTRIES.each do |registry|
#   [
#     "docker build --build-arg PHALA_GIT_TAG=#{PHERRY_GIT_TAG} -f pherry.Dockerfile -t #{registry}/#{PHERRY_DOCKER_REPO}:#{PHERRY_DOCKER_TAG} .",
#     "docker build --build-arg PHALA_GIT_TAG=#{PHERRY_GIT_TAG} -f pherry.Dockerfile -t #{registry}/#{PHERRY_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push Phala-Pherry
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{PHERRY_DOCKER_REPO}:#{PHERRY_DOCKER_TAG}",
#       "docker push #{registry}/#{PHERRY_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build Phala-Headers-cache
# REGISTRIES.each do |registry|
#   [
#     "docker build --build-arg PHALA_GIT_TAG=#{HEADERS_CACHE_GIT_TAG} -f headers-cache.Dockerfile -t #{registry}/#{HEADERS_CACHE_DOCKER_REPO}:#{HEADERS_CACHE_DOCKER_TAG} .",
#     "docker build --build-arg PHALA_GIT_TAG=#{HEADERS_CACHE_GIT_TAG} -f headers-cache.Dockerfile -t #{registry}/#{HEADERS_CACHE_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push Phala-Headers-cache
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{HEADERS_CACHE_DOCKER_REPO}:#{HEADERS_CACHE_DOCKER_TAG}",
#       "docker push #{registry}/#{HEADERS_CACHE_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build Phala-GK-Replay
# REGISTRIES.each do |registry|
#   [
#     "docker build --build-arg PHALA_GIT_TAG=#{REPLAY_GIT_TAG} -f replay.Dockerfile -t #{registry}/#{REPLAY_DOCKER_REPO}:#{REPLAY_DOCKER_TAG} .",
#     "docker build --build-arg PHALA_GIT_TAG=#{REPLAY_GIT_TAG} -f replay.Dockerfile -t #{registry}/#{REPLAY_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push Phala-GK-Replay
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{REPLAY_DOCKER_REPO}:#{REPLAY_DOCKER_TAG}",
#       "docker push #{registry}/#{REPLAY_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# # Build PRB
# REGISTRIES.each do |registry|
#   [
#     "docker build --build-arg PHALA_GIT_TAG=#{PRB_GIT_TAG} -f prb.Dockerfile -t #{registry}/#{PRB_DOCKER_REPO}:#{PRB_DOCKER_TAG} .",
#     "docker build --build-arg PHALA_GIT_TAG=#{PRB_GIT_TAG} -f prb.Dockerfile -t #{registry}/#{PRB_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push PRB
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{PRB_DOCKER_REPO}:#{PRB_DOCKER_TAG}",
#       "docker push #{registry}/#{PRB_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end
