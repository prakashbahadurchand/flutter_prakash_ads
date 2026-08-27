import 'package:flutter/foundation.dart';

/// Represents an enterprise-grade custom/house ad item for offline fallback or direct campaigns.
///
/// Designed to comply with Google AdMob & Google Play Better Ads Policies:
/// - Prominent "AD" attribution
/// - Clear call-to-action
/// - Transparent advertiser attribution
class CustomAdModel {
  const CustomAdModel({
    required this.title,
    required this.description,
    this.id,
    this.imageUrl,
    this.link,
    this.callToAction = 'Learn More',
    this.advertiser = 'Sponsored',
    this.rating = 4.9,
    this.onTap,
    this.extras,
  });

  /// Unique identifier for analytics and impression tracking.
  final String? id;

  /// Ad title or headline (e.g. "Upgrade to Pro Version").
  final String title;

  /// Ad description or promotional text.
  final String description;

  /// Asset image path (e.g. "assets/images/promo.png") or network image URL.
  final String? imageUrl;

  /// Destination link, deep link, or website URL when clicked.
  final String? link;

  /// Call-to-action button text (default: "Learn More").
  final String callToAction;

  /// Advertiser title or brand label (default: "Sponsored").
  final String advertiser;

  /// Optional star rating (e.g. 4.9).
  final double? rating;

  /// Custom tap callback invoked when user clicks the ad.
  final VoidCallback? onTap;

  /// Optional custom parameters for analytics or routing.
  final Map<String, dynamic>? extras;

  /// Factory constructor to parse from JSON map.
  factory CustomAdModel.fromJson(Map<String, dynamic> json) {
    return CustomAdModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      link: json['link'] as String?,
      callToAction: json['callToAction'] as String? ?? 'Learn More',
      advertiser: json['advertiser'] as String? ?? 'Sponsored',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      extras: json['extras'] as Map<String, dynamic>?,
    );
  }

  /// Converts this model to a serializable JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (link != null) 'link': link,
      'callToAction': callToAction,
      'advertiser': advertiser,
      if (rating != null) 'rating': rating,
      if (extras != null) 'extras': extras,
    };
  }

  /// Creates a copy of this [CustomAdModel] with updated fields.
  CustomAdModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? link,
    String? callToAction,
    String? advertiser,
    double? rating,
    VoidCallback? onTap,
    Map<String, dynamic>? extras,
  }) {
    return CustomAdModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      callToAction: callToAction ?? this.callToAction,
      advertiser: advertiser ?? this.advertiser,
      rating: rating ?? this.rating,
      onTap: onTap ?? this.onTap,
      extras: extras ?? this.extras,
    );
  }

  @override
  String toString() =>
      'CustomAdModel(id: $id, title: $title, link: $link, cta: $callToAction)';
}
