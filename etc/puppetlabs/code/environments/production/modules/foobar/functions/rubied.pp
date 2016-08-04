function foobar::rubied {
  $foo = file('/tmp/foobar_value')

  if $foo =~ /^\d+$/ {
    $foo + 1
  } else {
    0
  }
}
