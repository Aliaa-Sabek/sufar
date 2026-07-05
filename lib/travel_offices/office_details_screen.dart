import 'package:flutter/material.dart';
import '../models/travel_office_model.dart';

class OfficeDetailsPage extends StatelessWidget {
  final TravelOfficeModel officeData;

  const OfficeDetailsPage({super.key, required this.officeData});

  @override
  Widget build(BuildContext context) {
    final officeName = officeData.name;
    final rating = officeData.rating?.toStringAsFixed(1) ?? '--';
    final reviewsCount = officeData.reviewsCount?.toString() ?? '0';

    return Scaffold( // Colors.grey[50] in screenshot maybe?
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.black),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        officeData.logoUrl != null &&
                                officeData.logoUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  officeData.logoUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.business,
                                        color: Color(0xFF1A94C4),
                                        size: 40,
                                      ),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: Color(0xFF1A94C4),
                                  size: 40,
                                ),
                              ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      officeName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.amber.withOpacity(0.2) : const Color(0xFFFFF9E6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Color(0xFFFFC107),
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          rating.isEmpty ? '--' : rating,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                reviewsCount == '0'
                                    ? 'No reviews yet'
                                    : '$reviewsCount reviews',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),

                              SizedBox(height: 12),

                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${officeData.city ?? ''}${officeData.city != null && officeData.country != null ? ', ' : ''}${officeData.country ?? 'Location N/A'}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      officeData.phone ?? 'Phone N/A',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      officeData.email ?? 'Email N/A',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      officeData.website ?? 'Website N/A',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildBadge('IATA Certified'),
                                  _buildBadge('ASTA Member'),
                                  _buildBadge('BBB Accredited'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Two columns for larger screens, Vertical for mobile.
              // Using Column for mobile.

              // About Section
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A94C4),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      officeData.description ??
                          'No description available for this office.',
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // AI Sentiment Card (Highlighted in Blue)
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D6488), Color(0xFF1A94C4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_graph, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'AI Sentiment Score',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '92',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Excellent service with highly positive customer feedback',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Key Strengths:',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildStrength('Professional staff'),
                    SizedBox(height: 4),
                    _buildStrength('Great value'),
                    SizedBox(height: 4),
                    _buildStrength('Quick response'),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Services Offered
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services Offered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A94C4),
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      children:
                          (officeData.specialties ?? '')
                              .split(',')
                              .where((s) => s.trim().isNotEmpty)
                              .map((s) => _ServiceItem(text: s.trim()))
                              .toList()
                              .isEmpty
                          ? const [
                              _ServiceItem(text: 'General Travel'),
                            ] // Fallback
                          : (officeData.specialties ?? '')
                                .split(',')
                                .where((s) => s.trim().isNotEmpty)
                                .map((s) => _ServiceItem(text: s.trim()))
                                .toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Get in Touch
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.phone, color: Theme.of(context).cardColor),
                        label: Text(
                          'Call: ${officeData.phone ?? "N/A"}',
                          style: TextStyle(color: Theme.of(context).cardColor),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A94C4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF1A94C4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Request Quote',
                          style: TextStyle(color: Color(0xFF1A94C4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Reviews
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    SizedBox(height: 16),
                    // Review 1
                    _buildReviewItem(
                      name: 'Sarah Johnson',
                      date: 'December 2024',
                      rating: 5,
                      text:
                          'Absolutely amazing service! They planned our honeymoon to Bali and everything was perfect. Highly recommend!',
                    ),
                    const Divider(height: 32),
                    // Review 2
                    _buildReviewItem(
                      name: 'Michael Chen',
                      date: 'November 2024',
                      rating: 5,
                      text:
                          'Professional and efficient. They helped with our family trip to Europe and took care of every detail.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Color(0xFF1A94C4),
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrength(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required int rating,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFC107),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(text, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String text;
  const _ServiceItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Color(0xFF1A94C4),
          size: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle( fontSize: 13),
          ),
        ),
      ],
    );
  }
}
