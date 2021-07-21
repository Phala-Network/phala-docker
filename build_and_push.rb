#!/usr/bin/env ruby
# frozen_string_literal: true

BUILD_ONLY = false
GIT_TAG = "master"

COMMON_CHAIN_NAME = "dev"
COMMON_TAG = "21072101"

NODE_DOCKER_REPO = "phala-#{COMMON_CHAIN_NAME}-node"
NODE_DOCKER_TAG = COMMON_TAG
NODE_GIT_TAG = GIT_TAG

PHERRY_DOCKER_REPO = "phala-#{COMMON_CHAIN_NAME}-pherry"
PHERRY_DOCKER_TAG = COMMON_TAG
PHERRY_GIT_TAG = GIT_TAG

PRUNTIME_DOCKER_REPO = "phala-#{COMMON_CHAIN_NAME}-pruntime"
PRUNTIME_DOCKER_TAG = COMMON_TAG

PRUNTIME_BENCH_DOCKER_REPO = "phala-#{COMMON_CHAIN_NAME}-pruntime-bench"
PRUNTIME_BENCH_DOCKER_TAG = COMMON_TAG

SGX_DETECT_DOCKER_REPO = "phala-sgx_detect"


REGISTRIES = [
  "jasl123",
  # "phalanetwork",
  # "swr.cn-east-3.myhuaweicloud.com/phala",
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

# Build SGX-Detect
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

# Build Phala-pRuntime
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
  # Push Phala-pRuntime
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

# Build Phala-pRuntime-bench
# Phala-pRuntime-bench shares the same Dockerfile with Phala-pRuntime
REGISTRIES.each do |registry|
  [
    "docker build -f prebuilt-pruntime.Dockerfile -t #{registry}/#{PRUNTIME_BENCH_DOCKER_REPO}:#{PRUNTIME_BENCH_DOCKER_TAG} .",
    "docker build -f prebuilt-pruntime.Dockerfile -t #{registry}/#{PRUNTIME_BENCH_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push Phala-pRuntime-bench
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PRUNTIME_BENCH_DOCKER_REPO}:#{PRUNTIME_BENCH_DOCKER_TAG}",
      "docker push #{registry}/#{PRUNTIME_BENCH_DOCKER_REPO}"
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

# Build Phala-Pherry
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{PHERRY_GIT_TAG} -f pherry.Dockerfile -t #{registry}/#{PHERRY_DOCKER_REPO}:#{PHERRY_DOCKER_TAG} .",
    "docker build --build-arg PHALA_GIT_TAG=#{PHERRY_GIT_TAG} -f pherry.Dockerfile -t #{registry}/#{PHERRY_DOCKER_REPO} ."
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push Phala-Pherry
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PHERRY_DOCKER_REPO}:#{PHERRY_DOCKER_TAG}",
      "docker push #{registry}/#{PHERRY_DOCKER_REPO}"
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end
