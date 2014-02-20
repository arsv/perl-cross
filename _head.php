<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<? $mtime = date('Y-m-d H:i T', filemtime($_SERVER['SCRIPT_FILENAME'])) ?>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta name="author" content="Alex Suykov">
	<meta name="revised" content="<?=$mtime?>">
	<title>Cross-compiling perl</title>
	<link rel="stylesheet" href="style.css">
</head>

<body>
<? if(empty($h1)) $h1 = "Cross-compiling perl" ?>
<h1><?=$h1?></h1>
<?

$navbar = array(
	'index.html'	=> 'Intro',
	'download.html'	=> 'Download',
	'usage.html'	=> 'Usage',
	'design.html'	=> 'Design',
	'modules.html'	=> 'Modules',
	'hints.html'	=> 'Hints',
	'testing.html'	=> 'Testing'
);

$self = basename($_SERVER['PHP_SELF']);
$self = preg_replace("/\.php$/", '.html', $self);

?>
	
<div class="navbar">
<? foreach($navbar as $f => $t) { ?>
<?	if($self == $f) { ?>
	<a class="current" href="<?=$f?>"><?=$t?></a>
<?	} else { ?>
	<a href="<?=$f?>"><?=$t?></a>
<?	} ?>
<? } ?>
</div>
