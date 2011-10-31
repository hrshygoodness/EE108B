#!/usr/local/bin/perl

use Tk;
use strict;
use Carp;
use Socket;
use Errno qw(EAGAIN);
use Getopt::Long;

my $name = `whoami`;
chomp($name);

my %opt = (
             d => 0,
             bbox => 0,
             nx => 40,
             ny => 30,
             f => 4,
          );
my @opts = qw(d nx=s ny=s f=s bbox);
GetOptions(\%opt,@opts) or die "Bad usage\n";

# fifo file for communicating with SPIM
my $fpath = "/tmp/.write.fifo.$name";

my $clock = 0;
# Pong Screen Geometry
my $factor_x = $opt{f};
my $factor_y = $opt{f};

my $mw = MainWindow->new;
$mw->title ("PONG");

# Window Size
my $NX = $opt{nx}*$factor_x+2;
my $NY = $opt{ny}*$factor_y+2;

# Create Window
$mw->geometry($NX . "x" . $NY);
my $canvas = $mw->Canvas( -height => $NY, -width => $NX)->pack(-side => 'top');


my ($i,$j);
my ($x,$y);
my @id;
my $outline;
if ($opt{bbox}) {
   $outline = "#000000000000";
}
else {
   $outline = "#888888888888";;
}
for($i=0;$i<$opt{nx};$i++) {
  for($j=0;$j<$opt{ny};$j++) {
     $x=$factor_x*$i+1;
     $y=$factor_y*$j+1;
     $id[$i][$j] = 
         $canvas->createRectangle($x,$y,$x+$factor_x,$y+$factor_y,
        -fill => "#888888888888",
        -outline=>$outline);
  }
}

# make the fifo pipe
unlink $fpath;
unless (-p $fpath) { # not a pipe
   if (-e _) {       # but a something else
     die "$0: won't overwrite .write.fifo\n";
    } else  {
      require POSIX;
      POSIX::mkfifo($fpath,0666) or die "can't mknod $fpath: $!";
      warn "$0: created $fpath as a named pipe\n";
    }
}

spawn() if ($opt{d});
$mw->after(100,\&clockTick);
MainLoop;

##################################################################

sub spawn () {
   use Fcntl;
   chdir "/tmp";
   
   my $pid;
   my $line;
   FORK: { 
   if ($pid = fork) {
   }
   elsif (defined $pid) {
      my $value = 0x0803;
      my $color = "";
      while(1) {
         die "Pipe file disappeared" unless -p $fpath;
         my $c = int(rand 8); 
         $line = sprintf("%01x%04x",$c, $value % (256*256));
         system("touch /tmp/.fifo.active.$name");
         sysopen(FIFO,$fpath,O_WRONLY) or die "child: opening file failed: $!\n";
         printf FIFO "$line\n";
         close(FIFO);
         $value++;
         $value = $value % (256*256);
      }
   }
   elsif ($! == EAGAIN) {
      sleep 5;
      redo FORK;
   }
   else {
     # weird fork error 
     die "Can't fork: $!\n";
   }
  }
}

##################################################################
my $active_connect;
sub clockTick {
   if (-e "/tmp/.fifo.active.$name") {
   # use this function to interface with SPIM
   # this thread receieves commands from SPIM when
   # address 0xff is received. 
     system("rm -f /tmp/.fifo.active.$name");
     my ($x,$y,$color);
     my ($r,$g,$b);
     $clock++;
     sysopen(FIFO, $fpath,O_RDONLY) or die "parent: opening file failed: $!\n";
     while(<FIFO>) { 
     my $line = $_;
     chomp($line);
     $x = hex(substr($line,-4,2)) ;
     $y = hex(substr($line,-2,2)) ;
     my $c = hex(substr($line,-5,1));
     $b = $c%2;
     $c/=2;
     $g = $c%2;
     $c/=2;
     $r = $c%2;
     if ($r)  { $color = "ffff" } else { $color = "0000" }
     if ($g)  { $color .= "ffff" } else { $color .= "0000" }
     if ($b)  { $color .= "ffff" } else { $color .= "0000" }
     $color = "#" . $color;
     #print "$line $x $y $r$g$b\n";
     print "$x out of bound ($opt{nx})\n" if ($x>$opt{nx});
     print "$y out of bound ($opt{ny})\n" if ($y>$opt{ny});
     if (($x<$opt{nx}) && ($y<$opt{ny}))  {
        $canvas->itemconfigure($id[$x][$y], -fill=> $color, -outline=>$color); 
     }
     $canvas->update;
     $mw->update;
     }
     close(FIFO);

    }
    else {
       $canvas->update;
       $mw->update;
    }
    $mw->after(100,\&clockTick);
}

