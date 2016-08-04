# Puppet Server function caching bug

## Description

It seems that when environment caching is turned on by setting the value of
`environment_timeout` in Puppet Server to `unlimited`, Puppet Server will cache
the result of evaluating functions written in the Puppet language between
Puppet runs, even between different nodes.

This only seems to occur when the function exclusively uses Puppet language
constructs. If the function calls a Ruby function, even a built-in one, the
result of evaluating the function is not cached.

The caching appears to be separate based on the parameters passed to the
function. That is, if `foobar::next('a')` produces the value `2` on a run and
`foobar::next('b')` produces the value `7` on the same run, then on subsequent
runs without the cache being manually evicted, `foobar::next('a')` will continue
to produce `2` and `foobar::next('b')` will continue to produce `7`.

This wouldn't be an issue except that functions can access top-scope variables.
In particular, they can access facts. In this case, two function calls with the
same set of parameters can produce different values if they reference facts
data, which means that this caching can produce dramatically unexpected results
in this scenario.

## Proof of Concept

In this repository are the necessary files for reproducing this behavior. To
use this:
1. Install Puppet Server 2.4.0 on a CentOS 7 machine. This is the latest
   release at the time of this writing.
1. Copy all files from `etc` in this repository into place. All other
   configuration can be left as default.
1. Run `echo -n '0' > /tmp/foobar_value`. Without this, the manifest will fail
   to apply.
1. Set values for `foobar_b` and `foobar_c`. This allows us to see that the
   caching takes into account the parameters passed to the function.
   1. Run `echo -n 'foobar_b=2' > /etc/puppetlabs/facter/facts.d/foobar_b.txt`.
   1. Run `echo -n 'foobar_c=10' > /etc/puppetlabs/facter/facts.d/foobar_b.txt`.
1. Modify `/etc/hosts` so that the hostname `puppet` points at `127.0.0.1`.
1. Start `puppetserver`.
1. Run `puppet agent -t` repeatedly and see that the value of
   `/tmp/foobar_value` keeps increasing, but the values of `foobar_a`,
   `foobar_b`, and `foobar_c` only increase the first run.
1. Restart `puppetserver`.
1. Run `puppet agent -t` and repeatedly and see that, again, the value of
   `/tmp/foobar_value` keeps increasing, but the values of `foobar_a`,
   `foobar_b`, and `foobar_c` only increase the first run.

The output of doing this process is captured in `output.txt` in this
repository, which may be simpler than setting things up yourself.
