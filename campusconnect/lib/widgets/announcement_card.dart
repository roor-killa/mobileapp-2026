import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../utils/constants.dart';
import 'user_avatar.dart';

class AnnouncementCard extends StatefulWidget {
  final AnnouncementModel announcement;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onFavoriTap;
  final VoidCallback? onDeleteTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.currentUserId,
    required this.onTap,
    this.onFavoriTap,
    this.onDeleteTap,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMine = widget.currentUserId == widget.announcement.userId;
    final isFavori = widget.currentUserId != null &&
        widget.announcement.isFavoriOf(widget.currentUserId!);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? Colors.grey.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(
                          nom: widget.announcement.userNom,
                          photoUrl: widget.announcement.userPhotoUrl,
                          radius: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.announcement.userNom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppConstants.categoryColor(
                                          widget.announcement.categorie)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      AppConstants.categoryIcon(
                                          widget.announcement.categorie),
                                      size: 12,
                                      color: AppConstants.categoryColor(
                                          widget.announcement.categorie),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppConstants.categoryLabel(
                                          widget.announcement.categorie),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppConstants.categoryColor(
                                            widget.announcement.categorie),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.onFavoriTap != null)
                          _buildFavoriteButton(isFavori),
                        if (widget.onDeleteTap != null && isMine)
                          _buildDeleteButton(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.announcement.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.announcement.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(bool isFavori) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: IconButton(
            icon: Icon(
              isFavori ? Icons.favorite : Icons.favorite_border,
              color: isFavori ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {});
              widget.onFavoriTap?.call();
            },
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: widget.onDeleteTap,
    );
  }
}