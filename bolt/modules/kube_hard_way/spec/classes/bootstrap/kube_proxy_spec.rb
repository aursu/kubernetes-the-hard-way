# frozen_string_literal: true

require 'spec_helper'

describe 'kube_hard_way::bootstrap::kube_proxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          kubernetes_version: '1.28.4',
        }
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
