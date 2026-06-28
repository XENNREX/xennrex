
/**
 * Xennrex Cloud - PayFast ITN Handler (Google Apps Script)
 * 
 * This script receives PayFast payment confirmations via webhook
 * and sends email notifications + logs to Google Sheets.
 * 
 * SETUP INSTRUCTIONS:
 * 1. Go to https://script.google.com
 * 2. Create new project
 * 3. Paste this entire code
 * 4. Deploy as Web App:
 *    - Execute as: Me (info@xennrex.org)
 *    - Who has access: Anyone (even anonymous)
 * 5. Copy the Web App URL
 * 6. Use that URL as your notify_url in PayFast/checkout.html
 */

// Configuration
var CONFIG = {
  merchantId: '35854935',
  merchantKey: 'cy5krhuoxvofh',
  adminEmail: 'info@xennrex.org',
  spreadsheetId: null // Will create one automatically
};

/**
 * Handle POST requests from PayFast ITN
 */
function doPost(e) {
  try {
    var data = e.parameter;

    // Log raw data for debugging
    Logger.log('PayFast ITN received: ' + JSON.stringify(data));

    // Extract payment details
    var paymentId = data.m_payment_id || 'UNKNOWN';
    var pfPaymentId = data.pf_payment_id || 'UNKNOWN';
    var status = data.payment_status || 'UNKNOWN';
    var amount = data.amount_gross || '0.00';
    var email = data.email_address || 'unknown';
    var firstName = data.name_first || '';
    var lastName = data.name_last || '';
    var plan = data.custom_str1 || 'unknown';
    var storage = data.custom_str2 || 'unknown';
    var company = data.custom_str3 || 'N/A';
    var itemName = data.item_name || 'Unknown';

    var customerName = (firstName + ' ' + lastName).trim() || 'Unknown';

    // Log to spreadsheet
    logToSpreadsheet({
      timestamp: new Date(),
      paymentId: paymentId,
      pfPaymentId: pfPaymentId,
      status: status,
      amount: amount,
      customerName: customerName,
      email: email,
      plan: plan,
      storage: storage,
      company: company,
      itemName: itemName
    });

    // Send notifications based on status
    if (status === 'COMPLETE') {
      sendAdminNotification(customerName, company, email, plan, storage, amount, paymentId);
      sendCustomerConfirmation(firstName, email, plan, storage, amount, paymentId);
    } else {
      sendStatusNotification(status, customerName, email, amount, paymentId);
    }

    // Return OK to PayFast
    return ContentService.createTextOutput("OK");

  } catch (error) {
    Logger.log('ERROR: ' + error.toString());
    return ContentService.createTextOutput("ERROR");
  }
}

/**
 * Handle GET requests (for testing)
 */
function doGet(e) {
  return ContentService.createTextOutput("Xennrex PayFast ITN Handler - Ready");
}

/**
 * Log payment to Google Spreadsheet
 */
function logToSpreadsheet(data) {
  try {
    var ss;

    // Try to get existing spreadsheet, or create new one
    if (CONFIG.spreadsheetId) {
      ss = SpreadsheetApp.openById(CONFIG.spreadsheetId);
    } else {
      // Create new spreadsheet
      ss = SpreadsheetApp.create('Xennrex PayFast Payments');
      CONFIG.spreadsheetId = ss.getId();

      // Add headers
      var sheet = ss.getActiveSheet();
      sheet.appendRow([
        'Timestamp', 'Payment ID', 'PayFast ID', 'Status', 'Amount',
        'Customer', 'Email', 'Plan', 'Storage', 'Company', 'Item Name'
      ]);

      // Format header row
      sheet.getRange(1, 1, 1, 11).setFontWeight('bold').setBackground('#667eea').setFontColor('white');
    }

    var sheet = ss.getActiveSheet();
    sheet.appendRow([
      data.timestamp,
      data.paymentId,
      data.pfPaymentId,
      data.status,
      data.amount,
      data.customerName,
      data.email,
      data.plan,
      data.storage,
      data.company,
      data.itemName
    ]);

  } catch (error) {
    Logger.log('Spreadsheet error: ' + error.toString());
  }
}

/**
 * Send admin notification email
 */
function sendAdminNotification(name, company, email, plan, storage, amount, paymentId) {
  var subject = '[XENNREX] NEW PAYMENT - ' + name + ' - R' + amount;

  var body = 'XENNREX CLOUD - NEW PAYMENT RECEIVED\n' +
    '═══════════════════════════════════════════════════════════════\n\n' +
    'Customer:     ' + name + '\n' +
    'Company:      ' + company + '\n' +
    'Email:        ' + email + '\n' +
    'Plan:         ' + plan + '\n' +
    'Storage:      ' + storage + '\n' +
    'Amount:       R' + amount + '\n' +
    'Payment ID:   ' + paymentId + '\n' +
    'Date:         ' + new Date().toLocaleString() + '\n\n' +
    '═══════════════════════════════════════════════════════════════\n' +
    'ACTION REQUIRED:\n' +
    '1. Create MEGA account for this client\n' +
    '2. Provision new server with install.sh\n' +
    '3. Enter client details during installation\n' +
    '4. Client will receive welcome email automatically\n\n' +
    'Customer will receive their cloud URL within 1 hour.\n' +
    '═══════════════════════════════════════════════════════════════';

  MailApp.sendEmail(CONFIG.adminEmail, subject, body);
  Logger.log('Admin notification sent to ' + CONFIG.adminEmail);
}

/**
 * Send customer confirmation email
 */
function sendCustomerConfirmation(firstName, email, plan, storage, amount, paymentId) {
  var subject = 'Welcome to Xennrex Cloud - Payment Confirmed';

  var body = 'Dear ' + firstName + ',\n\n' +
    'Thank you for subscribing to Xennrex Cloud!\n\n' +
    'Your payment of R' + amount + ' has been received and confirmed.\n\n' +
    'Order Details:\n' +
    '- Plan: ' + plan + '\n' +
    '- Storage: ' + storage + '\n' +
    '- Payment ID: ' + paymentId + '\n\n' +
    'What happens next:\n' +
    '1. Our team is preparing your secure cloud instance\n' +
    '2. You will receive your login credentials within 1 hour\n' +
    '3. Your cloud URL will be sent via email\n' +
    '4. Set up Two-Factor Authentication on first login\n\n' +
    'If you have any questions, reply to this email.\n\n' +
    'Best regards,\n' +
    'The Xennrex Team\n' +
    'info@xennrex.org | 068 668 8888';

  MailApp.sendEmail(email, subject, body, {
    name: 'Xennrex Cloud',
    replyTo: CONFIG.adminEmail
  });
  Logger.log('Customer confirmation sent to ' + email);
}

/**
 * Send status notification for non-complete payments
 */
function sendStatusNotification(status, name, email, amount, paymentId) {
  var subject = '[XENNREX] PAYMENT ' + status + ' - ' + name;
  var body = 'Payment ' + status + ' for ' + name + ' (' + email + ')\n' +
    'Amount: R' + amount + '\n' +
    'Payment ID: ' + paymentId;

  MailApp.sendEmail(CONFIG.adminEmail, subject, body);
}
