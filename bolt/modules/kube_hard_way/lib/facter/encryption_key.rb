require 'English'

Facter.add(:kubernetes_encryption_key) do
  confine { File.exist? '/var/lib/kubernetes/enc.key' }

  setcode do
    read_encryption_key = File.read('/var/lib/kubernetes/enc.key') if File.exist?('/var/lib/kubernetes/enc.key')

    if read_encryption_key
      read_encryption_key.strip
    else
      nil
    end
  end
end
