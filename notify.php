<?php
/**
 * Xennrex Cloud - PayFast ITN (Instant Transaction Notification) Handler
 * 
 * This script receives payment confirmations from PayFast
 * and sends email notifications to the admin.
 * 
 * Place this file on your web server (not GitHub Pages)
 * GitHub Pages cannot run PHP - you need actual hosting for this.
 * 
 * URL: https://xennrex.org/notify.php (or your hosting URL)
 */

// PayFast Merchant Credentials
$merchant_id = '35854935';
$merchant_key = 'cy5krhuoxvofh';

// Admin notification email
$admin_email = 'info@xennrex.org';

// PayFast ITN URL (sandbox vs live)
$payfast_host = 'https://www.payfast.co.za';

// Log file
$log_file = __DIR__ . '/payfast_log.txt';

/**
 * Log function
 */
function log_itn($message) {
    global $log_file;
    $timestamp = date('Y-m-d H:i:s');
    $line = "[$timestamp] $message" . PHP_EOL;
    file_put_contents($log_file, $line, FILE_APPEND | LOCK_EX);
}

/**
 * Send email notification
 */
function notify_admin($subject, $body) {
    global $admin_email;
    $headers = "From: Xennrex Payments <payments@xennrex.org>
";
    $headers .= "Reply-To: info@xennrex.org
";
    $headers .= "Content-Type: text/plain; charset=UTF-8
";
    mail($admin_email, $subject, $body, $headers);
}

// Start processing
log_itn("=== PAYFAST ITN RECEIVED ===");
log_itn("POST data: " . print_r($_POST, true));

// Check if this is a valid PayFast POST
if (empty($_POST)) {
    log_itn("ERROR: No POST data received");
    http_response_code(400);
    exit("No data");
}

// Required fields from PayFast
$required_fields = [
    'm_payment_id', 'pf_payment_id', 'payment_status', 
    'item_name', 'item_description', 'amount_gross',
    'amount_fee', 'amount_net', 'name_first', 'name_last',
    'email_address', 'custom_str1', 'custom_str2', 'custom_str3'
];

// Validate required fields
foreach ($required_fields as $field) {
    if (!isset($_POST[$field])) {
        log_itn("WARNING: Missing field: $field");
    }
}

// Extract data
$payment_id = $_POST['m_payment_id'] ?? 'UNKNOWN';
$pf_payment_id = $_POST['pf_payment_id'] ?? 'UNKNOWN';
$status = $_POST['payment_status'] ?? 'UNKNOWN';
$item_name = $_POST['item_name'] ?? 'Unknown';
$amount = $_POST['amount_gross'] ?? '0.00';
$email = $_POST['email_address'] ?? 'unknown';
$first_name = $_POST['name_first'] ?? '';
$last_name = $_POST['name_last'] ?? '';
$plan = $_POST['custom_str1'] ?? 'unknown';
$storage = $_POST['custom_str2'] ?? 'unknown';
$company = $_POST['custom_str3'] ?? 'N/A';

log_itn("Payment ID: $payment_id | Status: $status | Amount: R$amount");

/**
 * SECURITY: Validate the signature
 * This prevents fake payment notifications
 */
$signature_data = [];
foreach ($_POST as $key => $value) {
    if ($key != 'signature') {
        $signature_data[$key] = $value;
    }
}
ksort($signature_data);
$signature_string = http_build_query($signature_data);
$calculated_signature = md5($signature_string);

$received_signature = $_POST['signature'] ?? '';

if ($calculated_signature !== $received_signature) {
    log_itn("ERROR: Signature mismatch! Possible fraud attempt.");
    log_itn("Calculated: $calculated_signature");
    log_itn("Received: $received_signature");
    http_response_code(400);
    exit("Invalid signature");
}

log_itn("Signature validated successfully");

/**
 * Verify with PayFast server (optional but recommended)
 * Uncomment this section for production
 */
/*
$verify_data = http_build_query($_POST);
$ch = curl_init($payfast_host . '/eng/query/validate');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $verify_data);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
$response = curl_exec($ch);
curl_close($ch);

if (strpos($response, 'VALID') === false) {
    log_itn("ERROR: PayFast validation failed: $response");
    http_response_code(400);
    exit("Validation failed");
}
log_itn("PayFast server validation passed");
*/

/**
 * Process payment based on status
 */
$customer_name = trim("$first_name $last_name");

switch ($status) {
    case 'COMPLETE':
        log_itn("PAYMENT COMPLETE - Processing...");

        // Send admin notification
        $subject = "[XENNREX] NEW PAYMENT - $customer_name - R$amount";
        $body = <<<EMAIL
XENNREX CLOUD - NEW PAYMENT RECEIVED
═══════════════════════════════════════════════════════════════

Customer:     $customer_name
Company:      $company
Email:        $email
Plan:         $plan
Storage:      $storage
Amount:       R$amount
Payment ID:   $payment_id
PayFast ID:   $pf_payment_id
Date:         " . date('Y-m-d H:i:s') . "

═══════════════════════════════════════════════════════════════
ACTION REQUIRED:
1. Create MEGA account for this client
2. Provision new Pi with install.sh
3. Enter client details during installation
4. Client will receive welcome email automatically

Customer will receive their cloud URL within 1 hour.
═══════════════════════════════════════════════════════════════
EMAIL;

        notify_admin($subject, $body);
        log_itn("Admin notification sent to $admin_email");

        // Send customer confirmation
        $customer_subject = "Welcome to Xennrex Cloud - Payment Confirmed";
        $customer_body = <<<EMAIL
Dear $first_name,

Thank you for subscribing to Xennrex Cloud!

Your payment of R$amount has been received and confirmed.

Order Details:
- Plan: $plan
- Storage: $storage
- Payment ID: $payment_id

What happens next:
1. Our team is preparing your secure cloud instance
2. You will receive your login credentials within 1 hour
3. Your cloud URL will be: https://yourcompany.xennrex.org
4. Set up Two-Factor Authentication on first login

If you have any questions, reply to this email.

Best regards,
The Xennrex Team
info@xennrex.org | 068 668 8888
EMAIL;

        $customer_headers = "From: Xennrex Cloud <info@xennrex.org>
";
        $customer_headers .= "Reply-To: info@xennrex.org
";
        $customer_headers .= "Content-Type: text/plain; charset=UTF-8
";
        mail($email, $customer_subject, $customer_body, $customer_headers);
        log_itn("Customer confirmation sent to $email");

        break;

    case 'FAILED':
        log_itn("PAYMENT FAILED for $payment_id");
        notify_admin(
            "[XENNREX] PAYMENT FAILED - $customer_name",
            "Payment failed for $customer_name ($email)
Amount: R$amount
Payment ID: $payment_id"
        );
        break;

    case 'PENDING':
        log_itn("PAYMENT PENDING for $payment_id");
        notify_admin(
            "[XENNREX] PAYMENT PENDING - $customer_name",
            "Payment pending for $customer_name ($email)
Amount: R$amount
Payment ID: $payment_id"
        );
        break;

    case 'CANCELLED':
        log_itn("PAYMENT CANCELLED for $payment_id");
        notify_admin(
            "[XENNREX] PAYMENT CANCELLED - $customer_name",
            "Payment cancelled for $customer_name ($email)
Amount: R$amount
Payment ID: $payment_id"
        );
        break;

    default:
        log_itn("UNKNOWN STATUS: $status for payment $payment_id");
        break;
}

// Return OK to PayFast
log_itn("=== ITN PROCESSING COMPLETE ===");
http_response_code(200);
echo "OK";
