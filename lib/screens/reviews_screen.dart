import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/review.dart';

class ReviewsScreen extends StatefulWidget {
  final String serviceType;
  final int serviceId;

  const ReviewsScreen({
    Key? key,
    required this.serviceType,
    required this.serviceId,
  }) : super(key: key);

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ApiService _apiService = ApiService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

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
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createReview() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ReviewDialog(
        serviceType: widget.serviceType,
        serviceId: widget.serviceId,
      ),
    );

    if (result != null) {
      try {
        await _apiService.createReview(
          serviceType: widget.serviceType,
          rating: result['rating'],
          comment: result['comment'],
          hammamServiceId: widget.serviceType == 'hammam' ? widget.serviceId : null,
          gymServiceId: widget.serviceType == 'gym' ? widget.serviceId : null,
          makeupServiceId: widget.serviceType == 'makeup' ? widget.serviceId : null,
          hennaServiceId: widget.serviceType == 'henna' ? widget.serviceId : null,
          accessoryServiceId: widget.serviceType == 'accessory' ? widget.serviceId : null,
          melhfaServiceId: widget.serviceType == 'melhfa' ? widget.serviceId : null,
        );
        _loadReviews();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating review: $e')),
        );
      }
    }
  }

  Future<void> _editReview(Review review) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ReviewDialog(
        serviceType: widget.serviceType,
        serviceId: widget.serviceId,
        initialRating: review.rating,
        initialComment: review.comment,
      ),
    );

    if (result != null) {
      try {
        await _apiService.updateReview(
          reviewId: review.id,
          rating: result['rating'],
          comment: result['comment'],
        );
        _loadReviews();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating review: $e')),
        );
      }
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Review'),
        content: Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteReview(review.id);
        _loadReviews();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting review: $e')),
        );
      }
    }
  }

  Future<void> _toggleLike(Review review) async {
    try {
      await _apiService.toggleReviewLike(review.id);
      _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling like: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReviews,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _reviews.isEmpty
                  ? Center(child: Text('No reviews yet'))
                  : ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return ReviewCard(
                          review: review,
                          onEdit: review.canEdit ? () => _editReview(review) : null,
                          onDelete: review.canEdit ? () => _deleteReview(review) : null,
                          onLike: () => _toggleLike(review),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createReview,
        child: Icon(Icons.add),
        tooltip: 'Add Review',
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onLike;

  const ReviewCard({
    Key? key,
    required this.review,
    this.onEdit,
    this.onDelete,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    review.userName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete, size: 20),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    );
                  }),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.serviceName,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(review.comment),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        review.userHasLiked ? Icons.favorite : Icons.favorite_border,
                        color: review.userHasLiked ? Colors.red : null,
                        size: 20,
                      ),
                      onPressed: onLike,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(width: 4),
                    Text('${review.likesCount}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewDialog extends StatefulWidget {
  final String serviceType;
  final int serviceId;
  final int? initialRating;
  final String? initialComment;

  const ReviewDialog({
    Key? key,
    required this.serviceType,
    required this.serviceId,
    this.initialRating,
    this.initialComment,
  }) : super(key: key);

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late int _rating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 5;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialRating == null ? 'Add Review' : 'Edit Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 12,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_commentController.text.isNotEmpty) {
              Navigator.pop(context, {
                'rating': _rating,
                'comment': _commentController.text,
              });
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
} 