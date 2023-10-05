# frozen_string_literal: true

require 'spec_helper'

describe 'kube_hard_way::certificate_authority' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:ca_config_content) do
        <<-JSONDATA
{
    "signing": {
        "default": {
            "expiry": "43824h"
        },
        "profiles": {
            "kubernetes": {
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ],
                "expiry": "43824h"
            }
        }
    }
}
JSONDATA
      end

      let(:csr_config_content) do
        <<-JSONDATA
{
    "CN": "Kubernetes",
    "names": [
        {
            "C": "DE",
            "ST": "Hesse",
            "L": "Frankfurt",
            "O": "Kubernetes",
            "OU": "CA"
        }
    ],
    "key": {
        "size": 2048,
        "algo": "rsa"
    }
}
JSONDATA
      end

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_file('/etc/kubernetes/pki/ca-config.json')
          .with_content(ca_config_content)
      }

      it {
        is_expected.to contain_file('/etc/kubernetes/pki/ca-csr.json')
          .with_content(csr_config_content)
      }

      it {
        is_expected.to contain_exec('cfssl-gencert-ca')
          .with_command('cfssl gencert -initca ca-csr.json | cfssljson -bare ca')
      }
    end
  end
end
