# frozen_string_literal: true

require "open-uri"
require "oga"

NIGHTLIES_HOST = "https://nightlies.puppetlabs.com"
PDK_NIGHTLIES_BIONIC_BASE = "#{NIGHTLIES_HOST}/apt/pool/bionic/puppet6-nightly/p/pdk"
RELEASES_HOST = "https://apt.puppetlabs.com"
PDK_RELEASES_BIONIC_BASE = "#{RELEASES_HOST}/pool/bionic/puppet6/p/pdk"
PDK_RELEASE_PKG_REGEX = /^pdk_(?<version>\d+\.\d+\.\d+\.\d+)-1bionic_amd64/
PDK_NIGHTLY_PKG_REGEX = /^pdk_(?<version>\d+\.\d+\.\d+\.\d+\..*)-1bionic_amd64/

def pdk_nightlies_html
  URI.parse("#{PDK_NIGHTLIES_BIONIC_BASE}/index_by_lastModified_reverse.html").read
rescue OpenURI::HTTPError
  nil
end

def pdk_releases_html
  URI.parse("#{PDK_RELEASES_BIONIC_BASE}/index_by_lastModified_reverse.html").read
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
        :href => "#{PDK_NIGHTLIES_BIONIC_BASE}/#{el['href']}",
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
        :href => "#{PDK_RELEASES_BIONIC_BASE}/#{el['href']}",
        :type => "release",
      }
    else
      nil
    end
  end

  version_map.compact
end

all_pdk_releases = (pdk_nightly_versions + pdk_release_versions).sort_by { |ver| ver[:released_at] }.reverse
pdk_latest = all_pdk_releases.first || exit(1)

File.open('pdk-release.env', 'w+') do |release_file|
  release_file.puts "export PDK_DEB_URL=\"#{pdk_latest[:href]}\""
  release_file.puts "export PDK_VERSION=\"#{pdk_latest[:version]}\""
  release_file.puts "export PDK_RELEASE_TYPE=\"#{pdk_latest[:type]}\""
end

exit(0)
