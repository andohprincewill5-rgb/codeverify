class CodeAnalysis {
  final bool isLegit;
  final String verdict;
  final String reason;
  final double confidence;

  CodeAnalysis({
    required this.isLegit,
    required this.verdict,
    required this.reason,
    required this.confidence,
  });
}

class CodeAnalyzer {
  static const List<String> _suspiciousDomains = [
    'bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly',
    'is.gd', 'buff.ly', 'adf.ly', 'bc.vc', 'sh.st',
  ];

  static const List<String> _suspiciousKeywords = [
    'login', 'verify', 'account', 'secure', 'update', 'confirm',
    'banking', 'paypal', 'signin', 'password', 'credential',
    'free-gift', 'you-won', 'click-here', 'limited-offer',
  ];

  static const List<String> _trustedDomains = [
    'google.com', 'apple.com', 'microsoft.com', 'amazon.com',
    'facebook.com', 'instagram.com', 'twitter.com', 'youtube.com',
    'github.com', 'linkedin.com', 'wikipedia.org', 'airtel.com',
    'mtn.com', 'orange.com', 'vodafone.com', 'samsung.com',
  ];

  static CodeAnalysis analyze(String code) {
    final trimmed = code.trim();

    // Check if it's a URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return _analyzeUrl(trimmed);
    }

    // Check if it looks like a license/activation key
    if (_isLicenseKey(trimmed)) {
      return _analyzeLicenseKey(trimmed);
    }

    // Check if it's a plain text code
    return _analyzeGenericCode(trimmed);
  }

  static CodeAnalysis _analyzeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      final path = uri.path.toLowerCase();
      final fullUrl = url.toLowerCase();

      // Check for trusted domains
      for (final trusted in _trustedDomains) {
        if (host == trusted || host.endsWith('.$trusted')) {
          return CodeAnalysis(
            isLegit: true,
            verdict: 'Likely Legitimate',
            reason: 'This URL belongs to a well-known and trusted domain.',
            confidence: 0.9,
          );
        }
      }

      // Check for URL shorteners (suspicious)
      for (final shortener in _suspiciousDomains) {
        if (host == shortener || host.endsWith('.$shortener')) {
          return CodeAnalysis(
            isLegit: false,
            verdict: 'Suspicious',
            reason: 'This is a shortened URL which can hide malicious destinations. Proceed with caution.',
            confidence: 0.75,
          );
        }
      }

      // Check for IP address URLs (suspicious)
      final ipPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
      if (ipPattern.hasMatch(host)) {
        return CodeAnalysis(
          isLegit: false,
          verdict: 'Suspicious',
          reason: 'This URL uses a raw IP address instead of a domain name, which is a common phishing tactic.',
          confidence: 0.85,
        );
      }

      // Check for suspicious keywords in URL
      for (final keyword in _suspiciousKeywords) {
        if (fullUrl.contains(keyword)) {
          return CodeAnalysis(
            isLegit: false,
            verdict: 'Potentially Suspicious',
            reason: 'This URL contains suspicious keywords often used in phishing attacks.',
            confidence: 0.65,
          );
        }
      }

      // Check for too many subdomains (suspicious)
      final parts = host.split('.');
      if (parts.length > 4) {
        return CodeAnalysis(
          isLegit: false,
          verdict: 'Suspicious',
          reason: 'This URL has an unusual number of subdomains, which is a common phishing technique.',
          confidence: 0.7,
        );
      }

      // Check for HTTP (not HTTPS)
      if (url.startsWith('http://')) {
        return CodeAnalysis(
          isLegit: false,
          verdict: 'Not Secure',
          reason: 'This URL uses HTTP instead of HTTPS, meaning the connection is not encrypted.',
          confidence: 0.6,
        );
      }

      // Passed all checks
      return CodeAnalysis(
        isLegit: true,
        verdict: 'Appears Legitimate',
        reason: 'This URL passed all security checks. No suspicious patterns detected.',
        confidence: 0.7,
      );
    } catch (e) {
      return CodeAnalysis(
        isLegit: false,
        verdict: 'Invalid URL',
        reason: 'This does not appear to be a valid URL.',
        confidence: 0.9,
      );
    }
  }

  static bool _isLicenseKey(String code) {
    // Common license key patterns: XXXXX-XXXXX-XXXXX or similar
    final licensePattern = RegExp(
        r'^[A-Z0-9]{4,6}(-[A-Z0-9]{4,6}){2,5}$',
        caseSensitive: false);
    return licensePattern.hasMatch(code);
  }

  static CodeAnalysis _analyzeLicenseKey(String code) {
    final parts = code.split('-');
    final allSameLength = parts.every((p) => p.length == parts[0].length);

    if (allSameLength && parts.length >= 3) {
      return CodeAnalysis(
        isLegit: true,
        verdict: 'Valid Format',
        reason: 'This appears to be a properly formatted license or activation key.',
        confidence: 0.65,
      );
    }

    return CodeAnalysis(
      isLegit: false,
      verdict: 'Invalid Format',
      reason: 'This key does not match standard license key formats.',
      confidence: 0.6,
    );
  }

  static CodeAnalysis _analyzeGenericCode(String code) {
    // Check for suspicious patterns
    if (code.length < 3) {
      return CodeAnalysis(
        isLegit: false,
        verdict: 'Too Short',
        reason: 'This code is too short to be a valid identifier.',
        confidence: 0.8,
      );
    }

    // Check for only numbers (barcode)
    if (RegExp(r'^\d+$').hasMatch(code)) {
      if (code.length == 8 || code.length == 12 || code.length == 13) {
        return CodeAnalysis(
          isLegit: true,
          verdict: 'Valid Barcode Format',
          reason: 'This appears to be a valid EAN-8, UPC-A, or EAN-13 barcode.',
          confidence: 0.75,
        );
      }
    }

    // Alphanumeric code
    if (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(code)) {
      return CodeAnalysis(
        isLegit: true,
        verdict: 'Valid Code Format',
        reason: 'This appears to be a valid alphanumeric code.',
        confidence: 0.55,
      );
    }

    return CodeAnalysis(
      isLegit: false,
      verdict: 'Unrecognized Format',
      reason: 'This code contains unusual characters and could not be verified.',
      confidence: 0.6,
    );
  }
}
