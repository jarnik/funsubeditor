<?php
function funsub_ulozit() {
  if ($_POST['exportString'] != '' and $_POST['videoUrl'] != '') {
    $video = $_POST['videoUrl'];
    $user_file = 'user-'.$video.'.xml';  
    $text = stripslashes( $_POST['exportString'] );
    $file = fopen($user_file, 'w');
    fwrite($file, $text);
    fclose($file);
  }
  echo "ulozeno";  
}

funsub_ulozit();
?>
