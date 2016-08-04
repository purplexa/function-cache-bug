class foobar {
  $index_value = foobar::next()

  file { '/etc/puppetlabs/facter/facts.d/foobar_index.txt':
    ensure => file,
    content => "foobar_index=${index_value}",
  }

  $rubied_value = foobar::rubied()

  file { '/tmp/foobar_value':
    ensure => file,
    content => "${rubied_value}",
  }
}
