#
# This is the main entry point for the lego class
#
class lego (
  Enum['package', 'download'] $install_method = 'download',
  String[1] $package_name = 'lego',
  String[1] $version = '5.2.2',
  Stdlib::AbsolutePath $config_dir = '/etc/lego',
  String[1] $config_filename = 'lego.yml',
  Hash $config_hash = {},
  Boolean $manage_secrets = true,
  Stdlib::AbsolutePath $secrets_dir = '/etc/lego/secrets.d',
  Hash[String, Hash[String, String]] $secrets = {},
  Enum['systemd'] $renew_provider = 'systemd',
  String[1] $renew_timer_interval = 'daily',
  Hash[String, Hash] $certificates = {},
  String[1] $download_source = "https://github.com/go-acme/lego/releases/download/v${version}/lego_v${version}_linux_amd64.tar.gz",
  Stdlib::AbsolutePath $install_path = '/opt/lego',
) {
  include lego::install
  include lego::config
  include lego::renew
}
