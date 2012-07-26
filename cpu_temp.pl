#!/usr/bin/env perl
use strict;
use warnings;
use CGI qw/:standard/;
use Date::Parse;

open(INPUT,"temp.log")or die $!;

my $data="";

while(defined(my $line = <INPUT>)){
	if($line=~/PDT/){
		chomp($line);
		my ($ss,$mm,$hh,$day,$month,$year,$zone)=strptime($line);
		$year = 1900+$year;

		$data=$data."[new Date($year,$month,$day,$hh,$mm,$ss),";
	}
	if($line=~/temp4:.*\+(\d+\.\d+).*  \(crit/){
		$data=$data."$1],\n";
	}elsif($line=~/\+(\d+\.\d+).*  \(crit/){
		$data=$data."$1,";
	}


}



print header;
print <<HTML;
<html>
  <head>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["annotatedtimeline"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
		data.addColumn('datetime','Date');
		data.addColumn('number','temp1');
		data.addColumn('number','temp2');
		data.addColumn('number','temp3');
		data.addColumn('number','temp4');
		data.addRows([
$data
        ]);

        var options = {
          title: 'CPU Temp (Celsius)'
        };

        var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <div id="chart_div" style="width: 900px; height: 500px;"></div>
  </body>
</html>
HTML
