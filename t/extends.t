#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 30;
use Test::Warn;
use Test::Exception;

my $module = 'Test::MockObject::Extends';
use_ok( $module ) or exit;

my $tme = $module->new();
isa_ok( $tme, 'Test::MockObject' );

$tme    = $module->new( 'Test::Builder' );
ok( $tme->isa( 'Test::Builder' ),
	'passing a class name to new() should set inheritance properly' );

$tme = $module->new( 'CGI' );
ok( $INC{'CGI.pm'},
	'new() should load parent module unless already loaded' );

package Some::Class;

@Some::Class::ISA = 'Another::Class';

sub path
{
	return $_[0]->{path};
}

sub foo
{
	return 'original';
}

sub bar
{
	return 'original';
}

package Another::Class;

package main;

# fake that we have loaded these
$INC{'Some/Class.pm'}    = 1;
$INC{'Another/Class.pm'} = 1;

$tme = $module->new( 'Some::Class' );
$tme->set_always( bar => 'mocked' );
is( $tme->bar(), 'mocked',   'mock() should override method in parent' );
is( $tme->foo(), 'original', '... calling original methods in parent'  );

$tme->unmock( 'bar' );
is( $tme->bar(), 'original', 'unmock() should remove method overriding' );

$tme->mock( pass_self => sub
{
	is( shift, $tme, '... and should pass along invocant' );
});

$tme->pass_self();
my ($method, $args) = $tme->next_call();
is( $method, 'bar', '... logging methods appropriately' );

my $sc      = bless { path => 'my path' }, 'Some::Class';
my $mock_sc = $module->new( $sc );
is( $mock_sc->path(), 'my path',
	'... should wrap existing object appropriately' );
isa_ok( $mock_sc, 'Some::Class' )
	or diag( '... marking isa() appropriately on mocked object' );
isa_ok( $mock_sc, 'Another::Class' )
	or diag( '... and delegating isa() appropriately on parent classes' );

ok( ! $mock_sc->isa( 'No::Class' ),
	'... returning the right result even when the class is not a parent' );

$tme->set_always( -foo => 11 );
is( $tme->foo(), 11, 'unlogged methods should work' );
ok( ! $tme->called( 'foo' ), '... and logging should not happen for them' );

warning_is { $tme->set_always( foo => 12 ) } undef, 
	                         '... not throwing redefinition warnings';
$tme->set_always( foo => 12 );
is( $tme->foo(), 12,         '... allowing overriding with logged versions' );
ok( $tme->called( 'foo' ),   '... with logging happening then, obviously'   );

package Parent;

$INC{'Parent.pm'} = 1;

use vars '$somethingnasty';
$somethingnasty = '';

sub new      { bless {}, $_[0] }

sub mockthis { $somethingnasty = 1 }

sub AUTOLOAD { return $_[0]->mockthis() }

package main;

my $parent = Parent->new();
my $extend = Test::MockObject::Extends->new( $parent );
$extend->mock( 'mockthis', sub { return 'foo' } );
is( $extend->foo(), 'foo', 'Mocking worked' );
ok( ! $Parent::somethingnasty, "Method didn't trigger bad method" );

package Foo;

my ($called_foo, $called_autoload, $method_name);

use vars '$AUTOLOAD';

BEGIN
{
	$called_foo      = 0;
	$called_autoload = 0;
	$method_name     = '';
}

sub new
{
	bless {}, $_[0];
}

sub foo
{
	$called_foo++;
	return 'foo';
}

sub AUTOLOAD
{
	$called_autoload++;
	$method_name = $Foo::AUTOLOAD;
	return 'autoload';
}

package main;

my $object = Foo->new();
isa_ok( $object, 'Foo' );

my $mock;
lives_ok { $mock = Test::MockObject::Extends->new( $object ) };
isa_ok( $mock, 'Foo'   );

# Call foo()
is( $mock->foo(),     'foo', 'foo() should return as expected' );
is( $called_foo,          1, '... calling the method'          );
is( $called_autoload,     0, '... not touching AUTOLOAD()'     );
is( $Foo::AUTOLOAD,   undef, '... or $Foo::AUTOLOAD'           );

# Call an autoloaded method
is( $mock->bar(),     'autoload', 'bad() should returns as expected'        );
is( $called_autoload,          1, '... calling AUTOLOAD()'                  );
is( $method_name,     'Foo::bar', '... with the appropriate $Foo::AUTOLOAD' );
