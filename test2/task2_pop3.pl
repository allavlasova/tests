use 5.010;
use strict;
use warnings;
use IO::Socket::SSL;
use IO::Socket qw(:DEFAULT :crlf);
use Config::Simple;
# соединение с Pop сервером
sub Connect{
	my ($user, $pass, $port) =  @_;
	die "Usermname $user is not valid!\n"
	unless $user =~ /^[a-z0-9\.\-_]+\@([a-z0-9\.\-_]+\.[a-z]{2,4}$)/i;
	my $host = 'pop.'.$1;
	my $sock = IO::Socket::SSL->new(
		PeerHost =>$host,
		PeerPort => $port) 
	or die "could not connect SSL socket $host, $port: $!";
	#проверяем ответ сервера
	my $msg = $sock->getline();
	die "Bad host\n" unless $msg =~ /^\+OK/i;
	#отправляем логин
	print $sock "user " . $user, CRLF;
	$msg = $sock->getline();
	die "no such username: $user\n" unless $msg =~ /^\+OK/i;
	#отправляем пароль
	print $sock "pass " . $pass, CRLF;
	$msg = $sock->getline();
	die "Bad password\n" unless $msg =~ /^\+OK/i;
	return $sock;
}
sub Get_message{
	my ($sock, $message_number) =  @_;
	die "Message number $message_number is not valid!\n" unless $message_number =~ /\d+/;
	#запрашиваем сообщение
	print $sock "RETR ".$message_number,CRLF;
	my $msg = $sock->getline();
	die "Messages could not be displayed\n" unless $msg =~ /^\+OK/i;
	#выводим все сообщение
	while (1) {
    	my $row = $sock->getline();
    	unless (defined $row) {
				return;
    	}
    last if $row =~ /^\.\s*$/;
   # $row =~ s/^\.\././;
    print $row;
  }
}

sub Close{
	my ($sock) =  @_;
	print $sock "QUIT",CRLF;
	my $msg = $sock->getline();
	die "Bad password\n" unless $msg =~ /^\+OK/i;
}

my $cfg = new Config::Simple('myconf.cfg');
my $user = $cfg->param('Username');
my $pass = $cfg->param('Password');
my $message_number = $cfg->param('MessageNumber');
my $conn = Connect($user, $pass, 995);
Get_message($conn, $message_number);
Close($conn);