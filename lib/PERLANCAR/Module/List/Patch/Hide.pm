package PERLANCAR::Module::List::Patch::Hide;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch ();
use base qw(Module::Patch);

our %config;

my $w_list_modules = sub {
    my $ctx  = shift;

    my @mods = split /\s*[;,]\s*/, $config{-module};

    my ($prefix, $opts) = @_;

    my $res = $ctx->{orig}->(@_);
    if ($opts->{list_modules}) {
        for my $mod (keys %$res) {
            if (grep {$mod eq $_} @mods) {
                delete $res->{$mod};
            }
        }
    }
    $res;
};

sub patch_data {
    return {
        v => 3,
        config => {
            -module => {
                summary => 'A string containing semicolon-separated list '.
                    'of module names to hide',
                schema => 'str*',
            },
        },
        patches => [
            {
                action => 'wrap',
                sub_name => 'list_modules',
                code => $w_list_modules,
            },
        ],
    };
}

1;
# ABSTRACT: Hide some modules from PERLANCAR::Module::List

=head1 SYNOPSIS

 % PERL5OPT=-MPERLANCAR::Module::List::Patch::Hide=-module,'Foo::Bar;Baz' app.pl

In the above example C<app.pl> will think that C<Foo::Bar> and C<Baz> are not
installed even though they might actually be installed.


=head1 DESCRIPTION

This module can be used to simulate the absence of certain modules. This only
works if the application uses L<PERLANCAR::Module::List>'s C<list_modules()> to
check the availability of modules.

This module works by patching C<list_modules()> and strip the target modules
from the result.


=head1 append:SEE ALSO

L<Module::List::Patch::Hide>.

L<Module::Path::Patch::Hide>, L<Module::Path::More::Patch::Hide>.

If the application checks he availability of modules by actually trying to
C<require()> them, you can try: L<lib::filter>, L<lib::disallow>,
L<Devel::Hide>.

=cut
