// IMPORTANT: Add this file to your .gitignore to avoid committing secrets!

// Use the SANDBOX/TESTING credentials provided by Airpay
class AirpayConfig {
  // Use either Sandbox or Production credentials based on the isSandbox flag
  static Map<String, String> getCredentials(bool isSandbox) {
    if (isSandbox) {
      // --- SANDBOX / QA CREDENTIALS ---
      return {
        'merchantId': '',
        'username': '',
        'password': '',
        'secretKey': '',
        'clientId': '',
        'clientSecret': '',
        'successUrl': '',
        'failedUrl': '',
      };
    } else {
      // --- PRODUCTION / LIVE CREDENTIALS ---
      return {
        'merchantId': '',
        'username': '',
        'password': '',
        'secretKey': '',
        'clientId': '',
        'clientSecret': '',
        'successUrl': '',
        'failedUrl': '',
      };
    }
  }
}