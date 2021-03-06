#
# Cookbook Name:: sshkey
# Provider:: default
#
# Copyright 2013-2014, Thomas Boerger <thomas@webhippie.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "chef/dsl/include_recipe"
include Chef::DSL::IncludeRecipe

action :create do
  directory "#{home_directory}/.ssh" do
    mode 0700
    owner new_resource.username
    group new_resource.group || new_resource.username
  end

  template "#{home_directory}/.ssh/authorized_keys" do
    mode 0600
    owner new_resource.username
    group new_resource.group || new_resource.username

    cookbook "sshkey"
    source "authorized_keys.conf.erb"

    variables(
      "keys" => new_resource.keys
    )
  end

  if new_resource.private_key =~ /^http/
    remote_file "#{home_directory}/.ssh/id_rsa" do
      mode 0600
      owner new_resource.username
      group new_resource.group || new_resource.username

      source new_resource.private_key

      not_if do
        new_resource.private_key.nil?
      end
    end
  else
    file "#{home_directory}/.ssh/id_rsa" do
      mode 0600
      owner new_resource.username
      group new_resource.group || new_resource.username

      content new_resource.private_key

      not_if do
        new_resource.private_key.nil?
      end
    end
  end

  if new_resource.public_key =~ /^http/
    remote_file "#{home_directory}/.ssh/id_rsa.pub" do
      mode 0600
      owner new_resource.username
      group new_resource.group || new_resource.username

      source new_resource.public_key

      not_if do
        new_resource.public_key.nil?
      end
    end
  else
    file "#{home_directory}/.ssh/id_rsa.pub" do
      mode 0600
      owner new_resource.username
      group new_resource.group || new_resource.username

      content new_resource.public_key

      not_if do
        new_resource.public_key.nil?
      end
    end
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  file "#{home_directory}/.ssh/authorized_keys" do
    action :delete
  end

  new_resource.updated_by_last_action(true)
end

def home_directory
  if new_resource.home
    new_resource.home
  else
    if new_resource.username == "root"
      "/root"
    else
      "/home/#{new_resource.username}"
    end
  end
end
