# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include lego::renew
class lego::renew(
  Enum['systemd'] $provider = $lego::renew_provider,
  String[1] $timer_interval = $lego::renew_timer_interval,
  Stdlib::AbsolutePath $config_dir = $lego::config_dir,
  String[1] $config_filename = $lego::config_filename,
) {
  if $provider == 'systemd' {
    systemd::timer { 'lego-renewal.timer':
      timer_content   => epp("${module_name}/systemd.renewal.timer.epp", {
        timer_interval => $timer_interval,
      }),
      service_content => epp("${module_name}/systemd.renewal.service.epp", {
        config_path => "${config_dir}/${config_filename}",
      }),
      active          => true,
      enable          => true,
    }
  }
}
