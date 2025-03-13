#!/usr/bin/env ruby
# frozen_string_literal: true

require "open-uri"
require "oga"

UBUNTU_RELEASE = "jammy"
NIGHTLIES_HOST = "https://artifactory.delivery.puppetlabs.net/artifactory/internal_nightly__local"
PDK_NIGHTLIES_BASE = "#{NIGHTLIES_HOST}/apt/pool/#{UBUNTU_RELEASE}/puppet-nightly/p/pdk"
RELEASES_HOST = "https://apt.puppetlabs.com"
PDK_RELEASES_BASE = "#{RELEASES_HOST}/pool/#{UBUNTU_RELEASE}/puppet-tools/p/pdk"
PDK_RELEASE_PKG_REGEX = /^pdk_(?<version>\d+\.\d+\.\d+\.\d+)-1#{UBUNTU_RELEASE}_(amd|arm)64/
PDK_NIGHTLY_PKG_REGEX = /^pdk_(?<version>\d+\.\d+\.\d+\.\d+\..*)-1#{UBUNTU_RELEASE}_(amd|arm)64/

def pdk_nightlies_html
  URI.parse("#{PDK_NIGHTLIES_BASE}").read
rescue OpenURI::HTTPError
  nil
end

def pdk_releases_html
  URI.parse("#{PDK_RELEASES_BASE}/index_by_lastModified_reverse.html").read
rescue OpenURI::HTTPError
  nil
end

def pdk_nightly_versions
  doc = Oga.parse_html(pdk_nightlies_html.squeeze(' '))
  version_map = {}


  # The Oga parse does not return the time correctly associated with each entry
  # On top of this, when new files are uploaded to Artifactory they are all recreated, so there is no difference in the time
  # So we are going to set a base time of the page and then increment it by several seconds for each version
  # Note: this is trusting that the images are in order, which they should be
  base_time = Time.parse(pdk_nightlies_html.match(/(\d{2}-\D{3,4}-\d{4}\s\d{2}:\d{2})/)[0])

  version_map = doc.css('a[href$="deb"]').collect.with_index do |el, index|
    if matches = el['href'].match(PDK_NIGHTLY_PKG_REGEX)
     {
        :version => matches[:version],
        :released_at => base_time + index,
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
  release_doc = Oga.parse_html(pdk_releases_html)

  version_map = release_doc.css('a[href$="deb"]').collect do |el|
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
