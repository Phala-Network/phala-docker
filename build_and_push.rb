#!/usr/bin/env ruby
# frozen_string_literal: true

GIT_TAG = "poc3-p1"

NODE_DOCKER_REPO = "phala-poc3-node"
NODE_DOCKER_TAG = "v3"
NODE_GIT_TAG = GIT_TAG

PHOST_DOCKER_REPO = "phala-poc3-phost"
PHOST_DOCKER_TAG = "v3"
PHOST_GIT_TAG = GIT_TAG

PRUNTIME_DOCKER_REPO = "phala-poc3-pruntime"
PRUNTIME_DOCKER_TAG = "v4"

SGX_DETECT_DOCKER_REPO = "phala-sgx_detect"

REGISTRIES = %w[jasl123 phalanetwork docker.pkg.github.com/phala-network/phala-docker]

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

# Build && Push Phala-Node
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{NODE_GIT_TAG} -f node.Dockerfile -t #{registry}/#{NODE_DOCKER_REPO}:#{NODE_DOCKER_TAG} .",
    "docker build --build-arg PHALA_GIT_TAG=#{NODE_GIT_TAG} -f node.Dockerfile -t #{registry}/#{NODE_DOCKER_REPO} .",
    "docker push #{registry}/#{NODE_DOCKER_REPO}:#{NODE_DOCKER_TAG}",
    "docker push #{registry}/#{NODE_DOCKER_REPO}"
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

# Build && Push Phala-PHost
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{PHOST_GIT_TAG} -f phost.Dockerfile -t #{registry}/#{PHOST_DOCKER_REPO}:#{PHOST_DOCKER_TAG} .",
    "docker build --build-arg PHALA_GIT_TAG=#{PHOST_GIT_TAG} -f phost.Dockerfile -t #{registry}/#{PHOST_DOCKER_REPO} .",
    "docker push #{registry}/#{PHOST_DOCKER_REPO}:#{PHOST_DOCKER_TAG}",
    "docker push #{registry}/#{PHOST_DOCKER_REPO}"
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

# Build && Push Phala-PRuntime
REGISTRIES.each do |registry|
  [
    "docker build -f prebuilt-pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG} .",
    "docker build -f prebuilt-pruntime.Dockerfile -t #{registry}/#{PRUNTIME_DOCKER_REPO} .",
    "docker push #{registry}/#{PRUNTIME_DOCKER_REPO}:#{PRUNTIME_DOCKER_TAG}",
    "docker push #{registry}/#{PRUNTIME_DOCKER_REPO}"
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

# Build && Push SGX_Detect
REGISTRIES.each do |registry|
  [
    "docker build -f sgx_detect.Dockerfile -t #{registry}/#{SGX_DETECT_DOCKER_REPO} .",
    "docker push #{registry}/#{SGX_DETECT_DOCKER_REPO}"
  ].each do |cmd|
    puts cmd
    run cmd
  end
end
