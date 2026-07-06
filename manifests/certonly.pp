# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   lego::certonly { 'namevar': }
define lego::certonly (
  Array[String[1]] $domains = [$title],
  Enum['http', 'dns'] $challenge = 'http',
  String[1] $email_address = $lego::email_address,
  String $dns_provider = undef,
  Array[String[1]] $environment = [],
  Boolean $manage_renewal = true,
  String $renew_timer_interval = $lego::renew_timer_interval
) {
  $title_cleaned = regsubst($title, '^\*\.', '')
  
  $default_args = [
    '--accept-tos',
    '--email',
    $email_address,
    '--path /etc/lego',
  ]

  case $challenge {
    'http': {
      $challenge_args = ['--http']
    }
    'dns': {
      $challenge_args = ['--dns', $dns_provider]
    }
  }

  $_domains = join($domains, '\' -d \'')
  $_command = flatten(
    [
      '/usr/bin/lego',
      $default_args,
      $challenge_args,
      "-d '${_domains}'",
      'run',
    ],
  ).filter | $arg | { $arg =~ NotUndef and $arg != [] }
  $command = join($_command, ' ')

  exec { "lego certonly ${title}":
    command     => $command,
    path        => $facts['path'],
    environment => $environment,
    provider    => 'shell',
  }

  if $manage_renewal {
    $_service = @("EOT")
    [Service]
    Type=oneshot
    ExecStart=${command}
    EOT

    systemd::timer { "lego-renewal-${title_cleaned}.timer":
      timer_content   => epp("${module_name}/systemd.renewal.timer.epp", {
        timer_interval => $renew_timer_interval,
      }),
      service_content => $_service,
      active          => true,
      enable          => true,
    }
  }
}
