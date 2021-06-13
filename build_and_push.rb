#!/usr/bin/env ruby
# frozen_string_literal: true

BUILD_ONLY = false
GIT_TAG = "master"

COMMON_CHAIN_NAME = "dev"
COMMON_TAG = "21061401"

NODE_DOCKER_REPO = "phala-#{COMMON_CHAIN_NAME}-node"
NODE_DOCKER_TAG = COMMON_TAG
NODE_GIT_TAG = GIT_TAG

PHOST_DOCKER_REPO = "phala-#{COMMON_CHAIN_NAME}-phost"
PHOST_DOCKER_TAG = COMMON_TAG
PHOST_GIT_TAG = GIT_TAG

PRUNTIME_DOCKER_REPO = "phala-#{COMMON_CHAIN_NAME}-pruntime"
PRUNTIME_DOCKER_TAG = COMMON_TAG

SGX_DETECT_DOCKER_REPO = "phala-sgx_detect"

REGISTRIES = [
  "jasl123",
  "phalanetwork",
  "swr.cn-east-3.myhuaweicloud.com/phala",
  "docker.pkg.github.com/phala-network/phala-docker"
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

# # Build SGX_Detect
# REGISTRIES.each do |registry|
#   [
#     "docker build -f sgx_detect.Dockerfile -t #{registry}/#{SGX_DETECT_DOCKER_REPO} ."
#   ].each do |cmd|
#     puts cmd
#     run cmd
#   end
# end

# unless BUILD_ONLY
#   # Push SGX_Detect
#   REGISTRIES.each do |registry|
#     [
#       "docker push #{registry}/#{SGX_DETECT_DOCKER_REPO}"
#     ].each do |cmd|
#       puts cmd
#       run cmd
#     end
#   end
# end

# Build Phala-PRuntime
REGISTRIES.each do |registry|
  [
    "docker build -f prebuilt-pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} .",
    "docker build -f prebuilt-pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push Phala-PRuntime
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PRUNTIME_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG}",
      "docker push #{registry}/#{PRUNTIME_DOCKER_REPO}"
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end

# Build Phala-Node
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{NODE_GIT_TAG} -f node.Dockerfile -t #{registry}/#{NODE_DOCKER_REPO}:#{NODE_DOCKER_TAG} .",
    "docker build --build-arg PHALA_GIT_TAG=#{NODE_GIT_TAG} -f node.Dockerfile -t #{registry}/#{NODE_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push Phala-Node
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{NODE_DOCKER_REPO}:#{NODE_DOCKER_TAG}",
      "docker push #{registry}/#{NODE_DOCKER_REPO}"
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end

# Build Phala-PHost
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{PHOST_GIT_TAG} -f phost.Dockerfile -t #{registry}/#{PHOST_DOCKER_REPO}:#{PHOST_DOCKER_TAG} .",
    "docker build --build-arg PHALA_GIT_TAG=#{PHOST_GIT_TAG} -f phost.Dockerfile -t #{registry}/#{PHOST_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push Phala-PHost
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PHOST_DOCKER_REPO}:#{PHOST_DOCKER_TAG}",
      "docker push #{registry}/#{PHOST_DOCKER_REPO}"
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end
