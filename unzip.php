<?php
$zip = new ZipArchive;
$file = 'vender.zip';
if ($zip->open($file) === TRUE) {
    $zip->extractTo('./'); // Extract in current folder
    $zip->close();
    echo 'Extraction complete! vender';
} else {
    echo 'Extraction failed!';
}
?>
