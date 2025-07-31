// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class CalEventInfo extends StatefulWidget {
  const CalEventInfo({
    super.key,
    this.width,
    this.height,
    this.eventTitle,
    this.eventDescription,
    this.startTime,
    this.endTime,
    this.location,
    this.eventColor,
    this.isAllDay = false,
    this.attendees,
    this.showDetails = true,
  });

  final double? width;
  final double? height;
  final String? eventTitle;
  final String? eventDescription;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final Color? eventColor;
  final bool isAllDay;
  final List<String>? attendees;
  final bool showDetails;

  @override
  State<CalEventInfo> createState() => _CalEventInfoState();
}

class _CalEventInfoState extends State<CalEventInfo> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with event color indicator and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (widget.eventColor ?? Theme.of(context).primaryColor)
                  .withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.eventColor ?? Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Event title
                Expanded(
                  child: Text(
                    widget.eventTitle ?? 'Event',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Expand/collapse button
                if (widget.showDetails)
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
              ],
            ),
          ),
          
          // Time information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTimeText(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Location (if provided)
          if (widget.location != null && widget.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.location!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Expandable details section
          if (widget.showDetails && _isExpanded) ...[
            const Divider(height: 24),
            
            // Description
            if (widget.eventDescription != null && widget.eventDescription!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.eventDescription!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

            // Attendees
            if (widget.attendees != null && widget.attendees!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendees (${widget.attendees!.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.attendees!.take(5).map((attendee) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            attendee,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }).toList(),
                    ),
                    if (widget.attendees!.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${widget.attendees!.length - 5} more',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _getTimeText() {
    if (widget.isAllDay) {
      return 'All day';
    }

    if (widget.startTime == null) {
      return 'No time specified';
    }

    final startTimeStr = DateFormat('HH:mm').format(widget.startTime!);
    
    if (widget.endTime == null) {
      return startTimeStr;
    }

    final endTimeStr = DateFormat('HH:mm').format(widget.endTime!);
    
    // Check if it's the same day
    if (DateUtils.isSameDay(widget.startTime!, widget.endTime!)) {
      return '$startTimeStr - $endTimeStr';
    } else {
      final startDateStr = DateFormat('MMM d, HH:mm').format(widget.startTime!);
      final endDateStr = DateFormat('MMM d, HH:mm').format(widget.endTime!);
      return '$startDateStr - $endDateStr';
    }
  }
}