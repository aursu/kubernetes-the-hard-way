# frozen_string_literal: true

require 'spec_helper'

describe 'kube_hard_way::bootstrap::kube_apiserver' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          server_name: '127.0.0.1',
        }
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
