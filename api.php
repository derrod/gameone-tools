<?php
// script to pull video url's (rtmp) from the riptide.mtvnn.com API and rewrite them to a JSON formatted version working with the Game One Android Application.

// Global Variables:
$api_base = 'http://riptide.mtvnn.com/mediagen/';

// PHP File to get the new shit dude. WTF am I even writing?!
ini_set('display_errors', 'Off');

// the most important function; download files of the server to process them D:
function curl_download($Url){
    // is cURL installed yet?
    if (!function_exists('curl_init')){
        die('Sorry cURL is not installed!');
    }
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $Url);

    // User agent of the Android App used
    curl_setopt($ch, CURLOPT_USERAGENT, "Dalvik/2.0.0 (Linux; U; Android 4.4.4; Nexus 5 Build/KTU84P)");

    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
 
    // go !!!
    $output = curl_exec($ch);
    // Close the cURL resource, and free system resources
    curl_close($ch);
 
    return $output;
}


$id = str_replace('.json','',str_replace('/','',$_GET['param']));
$url = $api_base . $id;
$xml_string = curl_download($url);
$xml = simplexml_load_string($xml_string);

$streams = array();
foreach ( $xml->video->item->rendition as $rtmpstreams )   
{
 $bitrate = (string)$rtmpstreams['bitrate'];
 $url = str_replace('rtmp://cp8619.edgefcs.net/ondemand/riptide/r2/','http://cdn.riptide-mtvn.com/r2/',(string)$rtmpstreams->src);
 $streams[$bitrate] = $url;
} 

krsort($streams);
$streams = array_slice($streams, 0, 3);
$urls = count($streams);
$x = 0;
$quals = array();
while ($x < $urls){
 if ($x == 0) {
  $key = "high";
 } elseif ($x == 1) {
  $key = "medium";
 } elseif ($x == 2) {
  $key = "low";
 }
 $quals[$key] = $streams[$x];
 $x++;
}

// output final array
print(json_encode($quals));


// Log some shit:
$logshit = '[' . date(DATE_RFC822) . '] - Request for ID "' . $id . '" from IP-Adress "' . $_SERVER['HTTP_CF_CONNECTING_IP'] . '".' . "\n";
$fp = fopen('request.log', 'a');
fwrite($fp, $logshit);
fclose($fp);

