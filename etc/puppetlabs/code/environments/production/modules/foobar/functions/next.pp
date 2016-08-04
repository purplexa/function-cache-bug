function foobar::next {
  if $facts['foobar_index'] {
    $facts['foobar_index'] + 1
  } else {
    0
  }
}
