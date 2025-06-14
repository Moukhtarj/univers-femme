import 'package:flutter/material.dart';
import '../screens/reviews_screen.dart';
import '../services/api_service.dart';
import '../models/review.dart';

class ReviewSection extends StatefulWidget {
  final String serviceType;
  final int serviceId;
  final String serviceName;

  const ReviewSection({
    Key? key,
    required this.serviceType,
    required this.serviceId,
    required this.serviceName,
  }) : super(key: key);

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final ApiService _apiService = ApiService();
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _apiService.getServiceReviews(
        widget.serviceType,
        widget.serviceId,
      );
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewsScreen(
                          serviceType: widget.serviceType,
                          serviceId: widget.serviceId,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.rate_review),
                  label: Text('See All'),
                ),
              ],
            ),
          ),
          Divider(),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No reviews yet'),
              ),
            )
          else
            Column(
              children: _reviews.take(2).map((review) => ReviewCard(
                review: review,
                onEdit: review.canEdit ? () {} : null,
                onDelete: review.canEdit ? () {} : null,
                onLike: () {},
              )).toList(),
            ),
        ],
      ),
    );
  }
} 