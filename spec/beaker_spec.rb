require 'spec_helper'

describe PuppetMetadata::Beaker do
  describe 'os_release_to_setfile' do
    [
      ['CentOS', '7', 'centos7-64'],
      ['CentOS', '8', 'centos8-64'],
      ['Fedora', '31', 'fedora31-64'],
      ['Fedora', '32', 'fedora32-64'],
      ['Debian', '9', 'debian9-64'],
      ['Debian', '10', 'debian10-64'],
      ['Ubuntu', '18.04', 'ubuntu1804-64'],
      ['Ubuntu', '20.04', 'ubuntu2004-64'],
    ].each do |os, release, expected|
      it { expect(described_class.os_release_to_setfile(os, release)).to eq(expected) }
    end

    it { expect(described_class.os_release_to_setfile('SLES', '11')).to be_nil }

    describe 'pidfile_workaround' do
      [
        ['CentOS', '7', 'centos7-64{image=centos:7.6.1810}'],
        ['CentOS', '8', 'centos8-64'],
        ['Ubuntu', '16.04', 'ubuntu1604-64{image=ubuntu:xenial-20191212}'],
        ['Ubuntu', '18.04', 'ubuntu1804-64'],
      ].each do |os, release, expected|
        it { expect(described_class.os_release_to_setfile(os, release, pidfile_workaround: true)).to eq(expected) }
      end

      describe 'use_fqdn' do
        it { expect(described_class.os_release_to_setfile('CentOS', '7', pidfile_workaround: true, use_fqdn: true)).to eq('centos7-64{hostname=centos7-64.example.com,image=centos:7.6.1810}') }
      end
    end
  end
end
