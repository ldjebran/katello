require 'katello_test_helper'

module Katello
  class RepositoryTestBase < ActiveSupport::TestCase
    def setup
      @acme_corporation                 = get_organization
      @fedora_17_x86_64                 = katello_repositories(:fedora_17_x86_64)
      @fedora_17_x86_64_dev             = katello_repositories(:fedora_17_x86_64_dev)
      @fedora_17_library_library_view   = katello_repositories(:fedora_17_library_library_view)
      @fedora_17_dev_library_view       = katello_repositories(:fedora_17_dev_library_view)
      @puppet_forge                     = katello_repositories(:p_forge)
      @redis                            = katello_repositories(:redis)
      @ostree                           = katello_repositories(:ostree)
      @ostree_rhel7                     = katello_repositories(:ostree_rhel7)
      @fedora                           = katello_products(:fedora)
      @library                          = katello_environments(:library)
      @dev                              = katello_environments(:dev)
      @staging                          = katello_environments(:staging)
      @unassigned_gpg_key               = katello_gpg_keys(:unassigned_gpg_key)
      @library_dev_staging_view         = katello_content_views(:library_dev_staging_view)
      @library_view                     = katello_content_views(:library_view)
      @content_view_puppet_environment  = katello_content_view_puppet_environments(:archive_view_puppet_environment)
      @admin                            = users(:admin)
    end

    # Returns a list of valid labels
    def valid_label_list
      [
        RFauxFactory.gen_alpha(1),
        RFauxFactory.gen_numeric_string(1),
        RFauxFactory.gen_alphanumeric(rand(2..127)),
        RFauxFactory.gen_alphanumeric(128),
        RFauxFactory.gen_alpha(rand(2..127)),
        RFauxFactory.gen_alpha(128)
      ]
    end

    # Returns a list of valid credentials for HTTP authentication
    def valid_http_credentials_list(escape = false)
      credentials = [
        { login: 'admin', pass: 'changeme', quote: false },
        { login: '@dmin', pass: 'changeme', quote: true },
        { login: 'adm/n', pass: 'changeme', quote: false },
        { login: 'admin2', pass: 'ch@ngeme', quote: true },
        { login: 'admin3', pass: 'chan:eme', quote: false },
        { login: 'admin4', pass: 'chan/eme', quote: true },
        { login: 'admin5', pass: 'ch@n:eme', quote: true },
        { login: '0', pass: 'mypassword', quote: false },
        { login: '0123456789012345678901234567890123456789', pass: 'changeme', quote: false },
        { login: 'admin', pass: '', quote: false },
        { login: '', pass: 'mypassword', quote: false },
        { login: '', pass: '', quote: false },
        { login: RFauxFactory.gen_alpha(rand(1..512)), pass: RFauxFactory.gen_alpha, quote: false },
        { login: RFauxFactory.gen_alphanumeric(rand(1..512)), pass: RFauxFactory.gen_alphanumeric, quote: false },
        { login: RFauxFactory.gen_utf8(rand(1..50)), pass: RFauxFactory.gen_utf8, quote: true }
      ]
      if escape
        credentials = credentials.map do |cred|
          { login: CGI.escape(cred[:login]), pass: CGI.escape(cred[:pass]), quote: cred[:quote] }
        end
      end
      credentials
    end

    # Returns a list of invalid credentials for HTTP authentication
    def invalid_http_credentials(escape = false)
      credentials = [
        { login: RFauxFactory.gen_alpha(1024), pass: '', string_type: :alpha },
        { login: RFauxFactory.gen_alpha(512), pass: RFauxFactory.gen_alpha(512), string_type: :alpha },
        { login: RFauxFactory.gen_utf8(512), pass: RFauxFactory.gen_utf8(512), string_type: :utf8 }
      ]
      if escape
        credentials = credentials.map do |cred|
          { login: CGI.escape(cred[:login]), pass: CGI.escape(cred[:pass])}
        end
      end
      credentials
    end

    def valid_docker_upstream_names
      value_0 = RFauxFactory.gen_alphanumeric(rand(3..6)).downcase
      value_1 = RFauxFactory.gen_alphanumeric(rand(3..6)).downcase
      value_2 = RFauxFactory.gen_alphanumeric(rand(3..6)).downcase
      value_3 = RFauxFactory.gen_alphanumeric(rand(3..6)).downcase
      value_4 = RFauxFactory.gen_alphanumeric(1).downcase
      [
        # boundaries
        RFauxFactory.gen_alphanumeric(1).downcase,
        RFauxFactory.gen_alphanumeric(255).downcase,
        "#{RFauxFactory.gen_alphanumeric(1).downcase}/#{RFauxFactory.gen_alphanumeric(1).downcase}",
        "#{RFauxFactory.gen_alphanumeric(127).downcase}/#{RFauxFactory.gen_alphanumeric(127).downcase}",
        'valid',
        'thisisareallylongbutstillvalidnam',
        # allowed non alphanumeric character
        'abc/valid',
        'soisthis/thisisareallylongbutstillvalidname',
        'single/slash',
        'multiple/slash/es',
        'abc/def/valid',
        "#{value_0}-#{value_1}_#{value_2}/#{value_2}-#{value_1}_#{value_0}.#{value_3}",
        "#{value_4}-_-_/#{value_4}-_."
      ]
    end

    def invalid_docker_upstream_names
      [
        RFauxFactory.gen_alphanumeric(256).downcase,
        "#{RFauxFactory.gen_alphanumeric(127).downcase}/#{RFauxFactory.gen_alphanumeric(128).downcase}",
        "#{RFauxFactory.gen_alphanumeric(128).downcase}/#{RFauxFactory.gen_alphanumeric(127).downcase}",
        'things with spaces',
        # with upper case
        'Ab', 'UPPERCASE', 'Uppercase', 'uppercasE', 'Upper/case', 'UPPER/case', 'upper/Case',
        # not allowed non alphanumeric character
        '$ymbols', '$tuff.th@t.m!ght.h@ve.w%!rd.r#g#x.m*anings()', '/startingslash', 'trailingslash/',
        'abcd/.-_',
        'abc1d+_ab1cd/ab1cd-abc1d_1abcd.1abcd',
        'abc1d-ab1cd_ab1cd/ab1cd+ab1cd_abc1d.1abcd',
        "#{RFauxFactory.gen_alphanumeric(1).downcase}-_-_/-_.",
        "-_-_/#{RFauxFactory.gen_alphanumeric(1).downcase}-_."
      ]
    end
  end
end
