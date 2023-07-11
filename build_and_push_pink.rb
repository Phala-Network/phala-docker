#!/usr/bin/env ruby
# frozen_string_literal: true

BUILD_ONLY = false
GIT_TAG = "master"

COMMON_CHAIN_NAME = "phala"
# COMMON_TAG = "23041501"

PINK_DOCKER_REPO = "#{COMMON_CHAIN_NAME}-pink-builder"
PINK_DOCKER_TAG = "v1.1" # COMMON_TAG
PINK_GIT_TAG = GIT_TAG

REGISTRIES = [
  "jasl123",
  # "phalanetwork",
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

# Build PInk
REGISTRIES.each do |registry|
  [
    "docker build --build-arg PHALA_GIT_TAG=#{PINK_GIT_TAG} -f pink-builder.Dockerfile -t #{registry}/#{PINK_DOCKER_REPO}:#{PINK_DOCKER_TAG} .",
  ].each do |cmd|
    puts cmd
    run cmd
  end
end

unless BUILD_ONLY
  # Push PInk
  REGISTRIES.each do |registry|
    [
      "docker push #{registry}/#{PINK_DOCKER_REPO}:#{PINK_DOCKER_TAG}",
    ].each do |cmd|
      puts cmd
      run cmd
    end
  end
end
