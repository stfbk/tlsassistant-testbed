<?php
$input = isset($_GET['input']) ? $_GET['input'] : '';
$secret = 'ThisIsASecretCSRFToken12345';
echo "User Input: " . htmlspecialchars($input) . "<br>";
echo "Secret Token: " . $secret;
?>
