import 'dart:async';
import 'dart:developer' as developer;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_constants.dart';

/// Centralized result for User Messaging Platform (UMP) consent requests.
class ConsentResult {
  const ConsentResult({
    required this.canRequestAds,
    this.error,
  });

  final bool canRequestAds;
  final FormError? error;
}

/// Helper service for Google User Messaging Platform (UMP) GDPR / CPRA Consent.
///
/// Ensures compliance with Google Play and EU User Consent Policies.
class ConsentManager {
  ConsentManager._();

  static final ConsentManager instance = ConsentManager._();

  /// Requests consent information and shows the consent form if required.
  Future<ConsentResult> requestConsent({
    ConsentDebugSettings? debugSettings,
  }) async {
    if (!AdConstants.isPlatformSupported) {
      developer.log(
        'ConsentManager: Platform not supported for UMP consent. Returning canRequestAds = false.',
        name: 'ConsentManager',
      );
      return const ConsentResult(canRequestAds: false);
    }

    final completer = Completer<ConsentResult>();

    final params = ConsentRequestParameters(
      consentDebugSettings: debugSettings,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        ConsentForm.loadAndShowConsentFormIfRequired(
          (formError) async {
            if (formError != null) {
              developer.log(
                'Consent form error: ${formError.message} (code: ${formError.errorCode})',
                name: 'ConsentManager',
              );
            }

            final canRequestAds =
                await ConsentInformation.instance.canRequestAds();
            if (!completer.isCompleted) {
              completer.complete(
                ConsentResult(
                  canRequestAds: canRequestAds,
                  error: formError,
                ),
              );
            }
          },
        );
      },
      (formError) async {
        developer.log(
          'Failed to update consent info: ${formError.message} (code: ${formError.errorCode})',
          name: 'ConsentManager',
        );
        // Google UMP Policy & Guideline: Check if consent is already cached locally from previous session
        final canRequestAds =
            await ConsentInformation.instance.canRequestAds();
        if (!completer.isCompleted) {
          completer.complete(
            ConsentResult(
              canRequestAds: canRequestAds,
              error: formError,
            ),
          );
        }
      },
    );

    return completer.future;
  }

  /// Checks if ads can be requested based on current consent status.
  Future<bool> canRequestAds() async {
    if (!AdConstants.isPlatformSupported) return false;
    return ConsentInformation.instance.canRequestAds();
  }

  /// Checks if privacy options (consent revocation / update) are required for this user.
  Future<bool> isPrivacyOptionsRequired() async {
    if (!AdConstants.isPlatformSupported) return false;
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// Shows the Privacy Options Form (required for EEA/UK user consent revocation).
  Future<FormError?> showPrivacyOptionsForm() async {
    if (!AdConstants.isPlatformSupported) return null;
    final completer = Completer<FormError?>();
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        developer.log(
          'Privacy options form error: ${formError.message} (code: ${formError.errorCode})',
          name: 'ConsentManager',
        );
      }
      if (!completer.isCompleted) {
        completer.complete(formError);
      }
    });
    return completer.future;
  }

  /// Resets consent state (useful for testing GDPR consent flows in debug mode).
  Future<void> resetConsent() async {
    if (!AdConstants.isPlatformSupported) return;
    await ConsentInformation.instance.reset();
  }
}
