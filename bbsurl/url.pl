#!/usr/bin/perl -w

use CGI;

$q = new CGI;
if (defined($q->param('url'))) {
  $url = $q->param('url');
  @lines = split(/\r?\n/, $url);
# 切割成很多行 分別作處理
  $appendType = $q->param('append');
  if ($appendType eq 'auto') {
    if ($lines[0] =~ /^\s.*\d{2}:\d{2}$/) {
      $appendType = 'wretch';
    } elsif ($lines[0] =~ /^\S{1,2}\s/) {
      $appendType = 'ptt';
    } elsif ($lines[0] =~ /\]$/) {
      $appendType = 'pighouse';
    } elsif ($lines[0] =~ /\d{2}\/\d{2}$/) {
      $appendType = 'itoc';
    } elsif ($lines[0] =~ /\\$/) {
      $appendType = 'ptt_body';
    } else {
      $appendType = 'none';
    }
  }
  if ($appendType eq 'wretch') {
    # ex:
    #           xxx:幫我轉到我版上!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 09/12 01:29
    $_ =~ s/^[^:]+:\s*(\S*).*/$1/ foreach (@lines);	#取id後面的接文 到非空白為止
    $_ =~ s/\d{1,2}\/\s?\d{1,2}$// foreach (@lines);	#把可能的日期刪掉
  } elsif ($appendType eq 'itoc') {
    $_ =~ s/^.*?(?:：|:)\s*(\S*).*$/$1/ foreach (@lines);	#取id後面的接文 到非空白為止
  } elsif ($appendType eq 'pighouse') {
    $_ =~ s/^[^:]+:\s*(\S*).*$/$1/ foreach (@lines);	#取id後面的接文 到非空白為止
  } elsif ($appendType eq 'ptt_body') {
    $_ =~ s/^\s*// foreach (@lines);		# 去除最前面的空白
    $_ =~ s/\\$// foreach (@lines);		# 去除最後面的/
  } elsif ($appendType eq 'ptt') {
    # ex:
    # 推 xxxxxxx:test                                                    04/20 23:33
    $_ =~ s/^\S{1,2} \w+:\s?// foreach (@lines);
    $_ =~ s/\s*\d{2}\/\d{2} \d{2}:\d{2}\s*$// foreach(@lines);
  } elsif ($appendType eq 'none') {
    $_ =~ s/^(> )*\s*// foreach (@lines);		#把前面的引言符號去掉
  }
  if ($#lines > 0) {
    $url = join('', @lines);
  } else {
    $url = $lines[0];
  }
  ($protocol,$tryURL,$path) = $url =~ /(\w+:\/\/)?([^\/]+)(.*)/;
# protocol://tryURL/path
  if ($tryURL) {
    if ($protocol =~ /^\s*$/) {
      $protocol = 'http://';
    }
    $url = $protocol.$tryURL.$path;
    ($tu) = gethostbyname($tryURL);
    if (defined($tu)) {
      require LWP::UserAgent;

      my $ua = LWP::UserAgent->new;
      $ua->timeout(3);
      my $response = $ua->get($url);

      if ($response->is_success) {
	print "Location: $url\n\n";
	exit;
      }
    }
  }
}

print "Content-type: text/html; charset=Big5\n\n";
$formtext = defined($url) ? $url : "";
$body = <<BODY;
請輸入多行網址，<br />
本程式可將您的多行網址轉成一行，<br />
並嘗試連到目的網頁。<br />
<form method="post">
<input type="radio" name="append" value="none" checked="checked" />非接文<br />
<input type="radio" name="append" value="wretch" />無名接文模式(半形冒號)<br />
<input type="radio" name="append" value="itoc" />itoc接文模式(全形冒號)<br />
<input type="radio" name="append" value="pighouse" />豬窩接文模式(半形冒號)<br />
<input type="radio" name="append" value="ptt_body" />PTT內文含斷行符號<br />
<input type="radio" name="append" value="ptt" />PTT推文<br />
<input type="radio" name="append" value="auto" checked="checked" />自動偵測(可能誤判)<br />
<textarea name="url" cols="80" rows="20">$formtext
</textarea><br />
<input type="submit"> <input type="reset">
</form>
BODY
  outputHTML(STDOUT, "網址處理", $body);

sub outputHTML {
  my($FD, $title, $body) = @_;
  print $FD <<CONTENT;
<html>
<head>
<title>
$title
</title>
</head>
<body>
$body
</body>
</html>
CONTENT
}

