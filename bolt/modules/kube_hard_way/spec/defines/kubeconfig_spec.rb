# frozen_string_literal: true

require 'spec_helper'

describe 'kube_hard_way::kubeconfig' do
  let(:title) { 'admin' }
  let(:params) do
    {
      auth_user: 'admin',
      server_name: '127.0.0.1',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
