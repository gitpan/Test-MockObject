
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Perl extension for emulating troublesome interfaces',
  'AUTHOR' => 'chromatic',
  'BUILD_REQUIRES' => {
    'CGI' => '0',
    'Test::Exception' => '0.31',
    'Test::More' => '0.98',
    'Test::Warn' => '0.23'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'Test-MockObject',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Test::MockObject',
  'PREREQ_PM' => {
    'UNIVERSAL::can' => '1.16',
    'UNIVERSAL::isa' => '1.03'
  },
  'VERSION' => '1.20110606',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



