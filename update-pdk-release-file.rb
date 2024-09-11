#!/usr/bin/env ruby
# frozen_string_literal: true

require "open-uri"
require "oga"

UBUNTU_RELEASE = "jammy"
NIGHTLIES_HOST = "https://nightlies.puppetlabs.com"
PDK_NIGHTLIES_BASE = "#{NIGHTLIES_HOST}/apt/pool/#{UBUNTU_RELEASE}/puppet-tools/p/pdk"
RELEASES_HOST = "https://apt.puppetlabs.com"
PDK_RELEASES_BASE = "#{RELEASES_HOST}/pool/#{UBUNTU_RELEASE}/puppet-tools/p/pdk"
PDK_RELEASE_PKG_REGEX = /^pdk_(?<version>\d+\.\d+\.\d+\.\d+)-1#{UBUNTU_RELEASE}_(amd|arm)64/
PDK_NIGHTLY_PKG_REGEX = /^pdk_(?<version>\d+\.\d+\.\d+\.\d+\..*)-1#{UBUNTU_RELEASE}_(amd|arm)64/

def pdk_nightlies_html
  URI.parse("#{PDK_NIGHTLIES_BASE}/index_by_lastModified_reverse.html").read
rescue OpenURI::HTTPError
  nil
end

def pdk_releases_html
  URI.parse("#{PDK_RELEASES_BASE}/index_by_lastModified_reverse.html").read
rescue OpenURI::HTTPError
  nil
end

def pdk_nightly_versions
  doc = Oga.parse_html(pdk_nightlies_html)

  version_map = doc.css('a[href$="deb"]').collect do |el|
    if matches = el['href'].match(PDK_NIGHTLY_PKG_REGEX)
      {
        :version => matches[:version],
        :released_at => Time.parse(el.parent.next_element.text),
        :href => "#{PDK_NIGHTLIES_BASE}/#{el['href']}",
        :type => "nightly",
      }
    else
      nil
    end
  end

  version_map.compact
end

def pdk_release_versions
  doc = Oga.parse_html(pdk_releases_html)

  version_map = doc.css('a[href$="deb"]').collect do |el|
    if matches = el['href'].match(PDK_RELEASE_PKG_REGEX)
      {
        :version => matches[:version],
        :released_at => Time.parse(el.parent.next_element.text),
        :href => "#{PDK_RELEASES_BASE}/#{el['href']}",
        :type => "release",
      }
    else
      nil
    end
  end

  version_map.compact
end

# Retrieve all PDK releases
all_pdk_releases = (pdk_nightly_versions + pdk_release_versions)

# Find the newest ARM PDK release
all_arm_releases = all_pdk_releases.select{ |i| i[:href].match(/arm64/) }.sort_by { |ver| ver[:released_at] }.reverse
arm_latest = all_arm_releases.first
# Find the newest AMD PDK release
all_amd_releases = all_pdk_releases.select{ |i| i[:href].match(/amd64/) }.sort_by { |ver| ver[:released_at] }.reverse
amd_latest = all_amd_releases.first

File.open('pdk-release.env', 'w+') do |release_file|
  release_file.puts "export PDK_DEB_URL_ARM64=\"#{arm_latest[:href]}\""
  release_file.puts "export PDK_DEB_URL_AMD64=\"#{amd_latest[:href]}\""
  release_file.puts "export PDK_VERSION=\"#{amd_latest[:version]}\""
  release_file.puts "export PDK_RELEASE_TYPE=\"#{amd_latest[:type]}\""
end

exit(0)
