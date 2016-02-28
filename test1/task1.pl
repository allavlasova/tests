#! /usr/bin/perl
use 5.010;
use strict;
use warnings;
use Data::Dumper qw(Dumper);
#прочитать из файла в хэш
sub Read_hash{
	my ($filename) = @_;
	my %hash;
	open(my $fh, '<', $filename) 
		or die "couldn't open $filename for reading: $!";
	while (my $row = <$fh>){
		my $marks_regex = qr/((?:[2345](?:\,\s)?){0,6})/; #для оценок
		die "string $row is invalid\n"
		unless $row=~/\{\s(name)\s\=\>\s\"(\w+\s\w+)\"\,\s(marks)\s\=\>\s\[${marks_regex}\]\s\}/;
		my $name =  $2;
		my @marks =  split /\,\s/,$4;
		@{$hash{$name}} = @marks;
	}
	return %hash;
}
#вывести хэш
sub Show{
	my (%hash) = @_;
	foreach my $key(keys %hash){
		print "$key - >" , Dumper $hash{$key};
	}
}

#среднее значение
sub average {
	my @array = @_;
	if (@array == 0){
		return 0;
	}
	my $sum;
	foreach (@array) { $sum += $_; } 
	return $sum/@array; 
}

#Вывод списка студентов, отсортированного по возрастанию по среднему баллу.
sub Sort_by_average {
	my (%hash) = @_;
	foreach my $key(sort { average(@{$hash{$a}}) <=> average(@{$hash{$b}}) } keys %hash) {
   		print "$key -> ", average(@{$hash{$key}}),"\n";
	}	
}

#Вывод студентов, чей средний балл выше X
sub Marks_higher_than{
	my (%hash) = @_;
	my $mark = $ARGV[0];
	foreach my $key(keys %hash){
		if(average(@{$hash{$key}}) >= $mark){
			print "$key - >", average(@{$hash{$key}}),"\n";
		}
	}
}

#Поиск студентов по имени (имя передается в командной строке).
sub Search_student_by_name {
	my (%hash) = @_;
	my $name = $ARGV[0];
	if(exists($hash{$name})){
		print "Студент $name найден!\n";
		return 1;
    } else {
    	"Студент $name не найден!\n";
		return 0;
	}
}

my %hash = Read_hash('file.txt');
Show(%hash);
Sort_by_average(%hash);
#Marks_higher_than(%hash);
#Search_student_by_name(%hash);
