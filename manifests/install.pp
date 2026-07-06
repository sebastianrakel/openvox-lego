# @summary Manages the installation of lego
#
# Manages the installation of lego
#
# @example
#   include lego::install
class lego::install (
  Enum['package', 'download'] $install_method = $lego::install_method,
  Stdlib::AbsolutePath $install_path = $lego::install_path,
  String[1] $package_name = $lego::package_name,
  String[1] $version = $lego::version,
  String[1] $download_source = $lego::download_source,
) {
  case $install_method {
    'repo': {
      package { $package_name:
        ensure => $version,
      }
    }
    'download': {
      $extract_path = "${install_path}/lego-${version}"

      file { [
        $install_path,
        $extract_path
      ]:
        ensure => directory,
      }

      archive { '/tmp/lego.tar.gz':
        source       => $download_source,
        extract      => true,
        creates      => "${extract_path}/lego",
        extract_path => $extract_path,
      }

      file { '/usr/bin/lego':
        ensure => 'link',
        target => "${extract_path}/lego",
        mode   => '+x',
      }
    }
    default: {
      fail("unsupported install method: ${install_method}")
    }
  }

}
