# @summary Manage the configuration of lego
#
# It manages the lego configuration file
#
# @example
#   include lego::config
class lego::config (
  Stdlib::AbsolutePath $config_dir = $lego::config_dir,
  String[1] $config_filename = $lego::config_filename,
  Hash $config_hash = $lego::config_hash,
  Boolean $manage_secrets = $lego::manage_secrets,
  Stdlib::AbsolutePath $secrets_dir = $lego::secrets_dir,
  Hash[String, Hash[String, String]] $secrets = $lego::secrets,
) {
  file { $config_dir:
    ensure => directory,
  }

  $config_file_path = "${config_dir}/${config_filename}"

  file { $config_file_path:
    ensure  => file,
    content => stdlib::to_yaml($config_hash),
  }

  if $manage_secrets {
    file { $secrets_dir:
      ensure => directory,
    }

    $secrets.each | String $filename, Hash $values| {
      file {"${secrets_dir}/${filename}.env":
        ensure  => file,
        content => epp("${module_name}/secrets.env.epp", {
          secrets => $values,
        }),
      }
    }
  }

  exec { 'lego run':
    command     => "/usr/bin/lego --config ${config_file_path}",
    path        => $facts['path'],
    provider    => 'shell',
    refreshonly => true,
    subscribe   => File[$config_file_path],
  }
}
