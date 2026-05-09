import 'package:flutter/material.dart';

import '../models/travel_office_model.dart';
import '../services/api_service.dart';
import 'office_details_screen.dart';

class TravelOfficesDirectory extends StatefulWidget {
  const TravelOfficesDirectory({super.key});

  @override
  State<TravelOfficesDirectory> createState() => _TravelOfficesDirectoryState();
}

class _TravelOfficesDirectoryState extends State<TravelOfficesDirectory> {
  List<TravelOfficeModel> _offices = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOffices(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchOffices({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _offices = [];
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await ApiService.getTravelOffices(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        page: reset ? 1 : _currentPage,
        limit: 10,
      );

      final List<dynamic> data = response['data'] ?? [];
      final int pages = response['pages'] ?? 1;
      final int total = response['total'] ?? 0;

      if (mounted) {
        setState(() {
          if (reset) {
            _offices = data.map((e) => TravelOfficeModel.fromJson(e)).toList();
          } else {
            _offices.addAll(data.map((e) => TravelOfficeModel.fromJson(e)));
          }
          _totalPages = pages;
          _total = total;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load travel offices: $e';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _loadMore() {
    if (_currentPage < _totalPages && !_isLoadingMore) {
      _currentPage++;
      _fetchOffices(reset: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',
            height: 34,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.grey),
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
              // Breadcrumbs / Title
              Text(
                'Travel Offices Directory',
                style: TextStyle(
                  color: Color(0xFF1A94C4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Connect with trusted travel professionals worldwide',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 32),

              // Search & Filters Section
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        
                        if (isSmallScreen) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search offices...',
                                      prefixIcon: Icon(Icons.search, color: Color(0xFF1A94C4)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: const Color(0xFFF5F6F8),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: _cityController,
                                    decoration: InputDecoration(
                                      hintText: 'All Locations',
                                      prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF1A94C4)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: const Color(0xFFF5F6F8),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Minimum Rating',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Any Rating',
                                      prefixIcon: Icon(Icons.star_outline, color: Color(0xFF1A94C4)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: const Color(0xFFF5F6F8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        // Desktop Row layout
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search offices...',
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Color(0xFF1A94C4),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF5F6F8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: _cityController,
                                    decoration: InputDecoration(
                                      hintText: 'All Locations',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF1A94C4),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF5F6F8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Minimum Rating',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Any Rating',
                                      prefixIcon: Icon(
                                        Icons.star_outline,
                                        color: Color(0xFF1A94C4),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF5F6F8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _fetchOffices(reset: true),
                        icon: Icon(Icons.search, size: 20),
                        label: Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A94C4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              Text(
                '$_total travel offices found',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(height: 16),

              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _fetchOffices(reset: true),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_offices.isEmpty)
                Center(child: Text('No travel offices found.'))
              else
                // Grid/List of Office Cards (responsive)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 600;

                    // On phones: use a vertical list (1 card per row) to avoid tight grid height and overflow
                    if (isSmallScreen) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _offices.length,
                        separatorBuilder: (ctx, idx) => SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildOfficeCard(context, _offices[index]);
                        },
                      );
                    }

                    // On larger screens: keep grid layout
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                      itemCount: _offices.length,
                      itemBuilder: (context, index) {
                        return _buildOfficeCard(context, _offices[index]);
                      },
                    );
                  },
                ),

              // Load More / Loading More indicator
              if (!_isLoading && _offices.isNotEmpty) ...[
                SizedBox(height: 24),
                if (_isLoadingMore)
                  Center(child: CircularProgressIndicator())
                else if (_currentPage < _totalPages)
                  Center(
                    child: OutlinedButton(
                      onPressed: _loadMore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A94C4),
                        side: BorderSide(color: Color(0xFF1A94C4)),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Load More (${_offices.length} of $_total)'),
                    ),
                  )
                else
                  Center(
                    child: Text(
                      'Showing all $_total offices',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficeCard(BuildContext context, TravelOfficeModel office) {
    // Use real services from backend
    final List<String> services = office.services.isNotEmpty
        ? office.services
        : ['General Travel', 'Booking'];


    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: office.logoUrl != null && office.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          office.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                                Icons.business,
                                color: Color(0xFF1A94C4),
                                size: 28,
                              ),
                        ),
                      )
                    : Icon(
                        Icons.business,
                        color: Color(0xFF1A94C4),
                        size: 28,
                      ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.amber.withValues(alpha: 0.2) : const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                    SizedBox(width: 4),
                    Text(
                      office.rating != null
                          ? office.rating!.toStringAsFixed(1)
                          : 'N/A',
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
          SizedBox(height: 16),
          Text(
            office.name,
            style: TextStyle(
              
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
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
                  '${office.city ?? ''}${office.city != null && office.country != null ? ', ' : ''}${office.country ?? 'Location N/A'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '${office.reviewsCount ?? 0} reviews',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            office.description ?? 'No description available',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Services:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...services
                  .take(2)
                  .map(
                    (service) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF7FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          color: Color(0xFF1A94C4),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfficeDetailsPage(officeData: office),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                'Visit Profile',
                style: TextStyle(color: Theme.of(context).cardColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
