#
# Usage:
#  orawls::ohs::rewrite { 'root':
#    $owner       => 'oracle',
#    $group       => 'oracle',
#    $domain_path => '/tmp',
#    $rule        => '^/\$ http://%{HTTP_HOST}/index.html [R]',
#    $cond        => '%{HTTPS} !=on',
#    require      => Orawls::Control["start ohs ${domain_name}"],
#    notify       => Wls_ohsserver["reload ohs ${domain_name}"],
#  }
#
#
# Notify option is needed to OHS restart and load changes.
# Require is needed because without it, notify option may attempt to reload server before it's running.
#
define orawls::ohs::rewrite (
  $owner,
  $group,
  $rule,
  $domain_path,
  $cond = undef,
  $ensure = 'present',
) {
  $convert_spaces_to_underscores = regsubst($title,'\s','_','G')
  $sanitised_title = regsubst($convert_spaces_to_underscores,'[^a-zA-Z0-9_-]','','G')

  file { "${domain_path}/config/fmwconfig/components/OHS/ohs1/mod_wl_ohs.d/rewrite_${sanitised_title}.conf":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => '0640',
    content => template('orawls/ohs/rewrite.conf.erb'),
  }
}
