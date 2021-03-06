#
# Copyright (C) 2018 Binero
#
# Author: Tobias Urdin <tobias.urdin@binero.se>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

require 'spec_helper'

describe 'horizon::dashboard' do
  # NOTE(tobasco): Intentionally set to uppercase to make sure
  # it's corrected to lowercase in the code.
  let (:title) { 'HeAt' }

  shared_examples 'horizon::dashboard' do
    context 'with default' do
      it {
        is_expected.to contain_package(platform_params[:heat_dashboard_package_name]).with(
          :ensure => 'present',
          :tag    => ['horizon-dashboard-package'])
      }
    end
  end

  shared_examples 'horizon::dashboard on Debian' do
    before do
      facts.merge!({:os_package_type => 'debian'})
    end

    context 'with default' do
      it {
        is_expected.to contain_package('python3-heat-dashboard').with(
          :ensure => 'present',
          :tag    => ['horizon-dashboard-package'])
      }
    end
  end

  shared_examples 'horizon::dashboard on Ubuntu' do
    context 'with default' do
      it {
        is_expected.to contain_package('python-heat-dashboard').with(
          :ensure => 'present',
          :tag    => ['horizon-dashboard-package'])
      }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          if facts[:os_package_type] == 'debian'
            pkg = 'python3-heat-dashboard'
          else
            pkg = 'python-heat-dashboard'
          end
          { :heat_dashboard_package_name => pkg }
        when 'RedHat'
          { :heat_dashboard_package_name => 'openstack-heat-ui' }
        end
      end

      it_behaves_like 'horizon::dashboard'

      if facts[:osfamily] == 'Debian'
        it_behaves_like "horizon::dashboard on #{facts[:operatingsystem]}"
      end
    end
  end

end
