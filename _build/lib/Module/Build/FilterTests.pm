package Module::Build::FilterTests;
use Module::Build;
@ISA = qw(Module::Build);

    use File::Glob;
    use File::Spec::Functions;

    sub ACTION_disttest
    {
        my $self = shift;
        local $ENV{PERL_RUN_ALL_TESTS} = 1;
        $self->SUPER::ACTION_disttest( @_ );
    }

    sub find_test_files
    {
        my $self  = shift;
        my $tests = $self->SUPER::find_test_files( @_ );

        return $tests unless $ENV{PERL_RUN_ALL_TESTS};

        my $test_pattern = catfile(qw( t developer *.t ) );
        push @$tests, File::Glob::bsd_glob( $test_pattern );
        return $tests;
    }

1;
