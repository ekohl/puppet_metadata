module PuppetMetadata
  # A class to provide abstractions for integration with beaker
  #
  # @see https://rubygems.org/gems/beaker
  # @see https://rubygems.org/gems/beaker-hostgenerator
  class Beaker
    # Convert an Operating System name with a release to a Beaker setfile
    #
    # @param [String] os
    #   The Operating System string as metadata.json knows it, which in turn is
    #   based on Facter's operatingsystem fact.
    # @param [String] release The OS release
    # @param [Boolean] use_fqdn
    #   Whether or not to use a FQDN, ensuring a domain
    # @param [Boolean] pidfile_workaround
    #   Whether or not to apply the systemd PIDFile workaround. This is only
    #   needed when the daemon uses PIDFile in its service file and using
    #   Docker as a Beaker hypervisor. This is to work around Docker's
    #   limitations.
    #
    # @return [String] The beaker setfile description or nil
    def self.os_release_to_setfile(os, release, use_fqdn: false, pidfile_workaround: false)
      return unless os_supported?(os)

      name = "#{os.downcase}#{release.tr('.', '')}-64"

      options = {}
      options[:hostname] = "#{name}.example.com" if use_fqdn
      # Docker messes up cgroups and modern systemd can't deal with that when
      # PIDFile is used.
      if pidfile_workaround
        case os
        when 'CentOS'
          options[:image] = 'centos:7.6.1810' if release == '7'
        when 'Ubuntu'
          options[:image] = 'ubuntu:xenial-20191212' if release == '16.04'
        end
      end

      setfile = name
      setfile += "{#{options.map { |key, value| "#{key}=#{value}" }.join(',')}}" if options.any?
      setfile
    end

    # Return whether a Beaker setfile can be generated for the given OS
    # @param [String] os The operating system
    def self.os_supported?(os)
      ['CentOS', 'Fedora', 'Debian', 'Ubuntu'].include?(os)
    end
  end
end
