#!/usr/bin/perl -w

use CGI;

$q = new CGI;
if (defined($q->param('url'))) {
  $url = $q->param('url');
  @lines = split(/\r?\n/, $url);
# ���Φ��ܦh�� ���O�@�B�z
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
    #           xxx:�������ڪ��W!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 09/12 01:29
    $_ =~ s/^[^:]+:\s*(\S*).*/$1/ foreach (@lines);	#��id�᭱������ ��D�ťլ���
    $_ =~ s/\d{1,2}\/\s?\d{1,2}$// foreach (@lines);	#��i�઺����R��
  } elsif ($appendType eq 'itoc') {
    $_ =~ s/^.*?(?:�G|:)\s*(\S*).*$/$1/ foreach (@lines);	#��id�᭱������ ��D�ťլ���
  } elsif ($appendType eq 'pighouse') {
    $_ =~ s/^[^:]+:\s*(\S*).*$/$1/ foreach (@lines);	#��id�᭱������ ��D�ťլ���
  } elsif ($appendType eq 'ptt_body') {
    $_ =~ s/^\s*// foreach (@lines);		# �h���̫e�����ť�
    $_ =~ s/\\$// foreach (@lines);		# �h���̫᭱��/
  } elsif ($appendType eq 'ptt') {
    # ex:
    # �� xxxxxxx:test                                                    04/20 23:33
    $_ =~ s/^\S{1,2} \w+:\s?// foreach (@lines);
    $_ =~ s/\s*\d{2}\/\d{2} \d{2}:\d{2}\s*$// foreach(@lines);
  } elsif ($appendType eq 'none') {
    $_ =~ s/^(> )*\s*// foreach (@lines);		#��e�����ި��Ÿ��h��
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
�п�J�h����}�A<br />
���{���i�N�z���h����}�ন�@��A<br />
�ù��ճs��ت������C<br />
<form method="post">
<input type="radio" name="append" value="none" checked="checked" />�D����<br />
<input type="radio" name="append" value="wretch" />�L�W����Ҧ�(�b�Ϋ_��)<br />
<input type="radio" name="append" value="itoc" />itoc����Ҧ�(���Ϋ_��)<br />
<input type="radio" name="append" value="pighouse" />�޺۱���Ҧ�(�b�Ϋ_��)<br />
<input type="radio" name="append" value="ptt_body" />PTT����t�_��Ÿ�<br />
<input type="radio" name="append" value="ptt" />PTT����<br />
<input type="radio" name="append" value="auto" checked="checked" />�۰ʰ���(�i��~�P)<br />
<textarea name="url" cols="80" rows="20">$formtext
</textarea><br />
<input type="submit"> <input type="reset">
</form>
BODY
  outputHTML(STDOUT, "���}�B�z", $body);

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

