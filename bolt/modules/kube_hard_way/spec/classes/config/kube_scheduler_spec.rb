# frozen_string_literal: true

require 'spec_helper'

describe 'kube_hard_way::config::kube_scheduler' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_file('/etc/kubernetes/config/kube-scheduler.yaml')
      }
    end
  end
end
