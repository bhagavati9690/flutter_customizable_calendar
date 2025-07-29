# Flutter Customizable Calendar Implementation Guide for FlutterFlow

This guide will help you implement the `flutter_customizable_calendar` package in your FlutterFlow project. The package provides highly customizable calendar views including DaysView, WeekView, MonthView, and ScheduleListView.

## Table of Contents
1. [Package Installation](#package-installation)
2. [Basic Setup](#basic-setup)
3. [Calendar Views Implementation](#calendar-views-implementation)
4. [Event Management](#event-management)
5. [Customization Options](#customization-options)
6. [FlutterFlow-Specific Implementation](#flutterflow-specific-implementation)

## Package Installation

### Step 1: Add Dependency in FlutterFlow

1. Go to your FlutterFlow project settings
2. Navigate to **Dependencies** section
3. Add the following dependency:
   ```yaml
   flutter_customizable_calendar: ^0.3.8
   ```

### Step 2: Required Additional Dependencies

The calendar package requires these additional dependencies (add them to your FlutterFlow project):

```yaml
dependencies:
  animations: ^2.0.8
  clock: ^1.1.1
  equatable: ^2.0.5
  flutter_bloc: ^8.1.3
  intl: ^0.20.2
  collection: ^1.17.1
  scrollable_positioned_list: ^0.3.8
  uuid: ^4.0.0  # For generating unique event IDs
```

## Basic Setup

### Import Statements

Add these imports to your custom code files:

```dart
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
```

### Event Model Setup

Create a custom code file for your event models:

```dart
// File: lib/custom_code/models/calendar_events.dart

import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:uuid/uuid.dart';

class MySimpleEvent extends SimpleEvent {
  final String description;
  final Color eventColor;

  MySimpleEvent({
    required String id,
    required DateTime start,
    required Duration duration,
    required String title,
    this.description = '',
    this.eventColor = Colors.blue,
  }) : super(
          id: id,
          start: start,
          duration: duration,
          title: title,
        );

  @override
  MySimpleEvent copyWith({
    String? id,
    DateTime? start,
    Duration? duration,
    String? title,
    String? description,
    Color? eventColor,
  }) {
    return MySimpleEvent(
      id: id ?? this.id,
      start: start ?? this.start,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      description: description ?? this.description,
      eventColor: eventColor ?? this.eventColor,
    );
  }
}

class MyTaskDue extends TaskDue {
  final String description;
  final bool isCompleted;

  MyTaskDue({
    required String id,
    required DateTime start,
    String title = 'Task',
    this.description = '',
    this.isCompleted = false,
  }) : super(
          id: id,
          start: start,
          title: title,
        );

  @override
  MyTaskDue copyWith({
    String? id,
    DateTime? start,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return MyTaskDue(
      id: id ?? this.id,
      start: start ?? this.start,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

## Calendar Views Implementation

### 1. DaysView Implementation

Create a custom widget for DaysView:

```dart
// File: lib/custom_code/widgets/custom_days_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDaysView extends StatefulWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent)? onEventTap;
  final Function(DateTime)? onDateLongPress;
  final Function(CalendarEvent, CalendarEvent)? onEventUpdated;

  const CustomDaysView({
    Key? key,
    required this.events,
    this.onEventTap,
    this.onDateLongPress,
    this.onEventUpdated,
  }) : super(key: key);

  @override
  State<CustomDaysView> createState() => _CustomDaysViewState();
}

class _CustomDaysViewState extends State<CustomDaysView> {
  late final CalendarController<CalendarEvent> _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController<CalendarEvent>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarBloc<CalendarEvent>()
        ..add(CalendarInitialize<CalendarEvent>(widget.events)),
      child: BlocBuilder<CalendarBloc<CalendarEvent>, CalendarState<CalendarEvent>>(
        builder: (context, state) {
          return DaysView<CalendarEvent>(
            controller: _controller,
            itemBuilder: (context, event) => _buildEventTile(event),
            onDateLongPress: widget.onDateLongPress != null 
                ? (dateTime) async {
                    final event = await widget.onDateLongPress!(dateTime);
                    if (event != null) {
                      context.read<CalendarBloc<CalendarEvent>>()
                          .add(CalendarAddEvent<CalendarEvent>(event));
                    }
                    return event;
                  }
                : null,
            onEventUpdated: widget.onEventUpdated != null
                ? (oldEvent, newEvent) {
                    widget.onEventUpdated!(oldEvent, newEvent);
                    context.read<CalendarBloc<CalendarEvent>>()
                        .add(CalendarUpdateEvent<CalendarEvent>(
                          oldEvent: oldEvent,
                          newEvent: newEvent,
                        ));
                  }
                : null,
            // Customization options
            theme: DaysListTheme(
              backgroundColor: Colors.white,
              dayHeaderTheme: DayHeaderTheme(
                backgroundColor: Colors.grey.shade100,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventTile(CalendarEvent event) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getEventColor(event),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => widget.onEventTap?.call(event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (event is SimpleEvent && event.duration.inMinutes > 30)
              Text(
                '${event.start.hour.toString().padLeft(2, '0')}:${event.start.minute.toString().padLeft(2, '0')} - ${event.end.hour.toString().padLeft(2, '0')}:${event.end.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    if (event is MySimpleEvent) {
      return event.eventColor;
    } else if (event is TaskDue) {
      return Colors.orange;
    } else if (event is Break) {
      return Colors.grey;
    }
    return Colors.blue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 2. WeekView Implementation

```dart
// File: lib/custom_code/widgets/custom_week_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomWeekView extends StatefulWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent)? onEventTap;
  final Function(DateTime)? onDateLongPress;

  const CustomWeekView({
    Key? key,
    required this.events,
    this.onEventTap,
    this.onDateLongPress,
  }) : super(key: key);

  @override
  State<CustomWeekView> createState() => _CustomWeekViewState();
}

class _CustomWeekViewState extends State<CustomWeekView> {
  late final CalendarController<CalendarEvent> _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController<CalendarEvent>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarBloc<CalendarEvent>()
        ..add(CalendarInitialize<CalendarEvent>(widget.events)),
      child: BlocBuilder<CalendarBloc<CalendarEvent>, CalendarState<CalendarEvent>>(
        builder: (context, state) {
          return WeekView<CalendarEvent>(
            controller: _controller,
            itemBuilder: (context, event) => _buildEventTile(event),
            onDateLongPress: widget.onDateLongPress != null 
                ? (dateTime) async {
                    final event = await widget.onDateLongPress!(dateTime);
                    if (event != null) {
                      context.read<CalendarBloc<CalendarEvent>>()
                          .add(CalendarAddEvent<CalendarEvent>(event));
                    }
                    return event;
                  }
                : null,
            // Customization
            theme: WeekViewTheme(
              backgroundColor: Colors.white,
              dayHeaderTheme: DayHeaderTheme(
                backgroundColor: Colors.blue.shade50,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
              timelineTheme: TimelineTheme(
                backgroundColor: Colors.grey.shade50,
                textStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventTile(CalendarEvent event) {
    return Container(
      margin: EdgeInsets.all(1),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _getEventColor(event),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () => widget.onEventTap?.call(event),
        child: Text(
          event.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    if (event is MySimpleEvent) {
      return event.eventColor;
    } else if (event is TaskDue) {
      return Colors.orange;
    } else if (event is Break) {
      return Colors.grey;
    }
    return Colors.blue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 3. MonthView Implementation

```dart
// File: lib/custom_code/widgets/custom_month_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomMonthView extends StatefulWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent)? onEventTap;
  final Function(DateTime)? onDateTap;

  const CustomMonthView({
    Key? key,
    required this.events,
    this.onEventTap,
    this.onDateTap,
  }) : super(key: key);

  @override
  State<CustomMonthView> createState() => _CustomMonthViewState();
}

class _CustomMonthViewState extends State<CustomMonthView> {
  late final CalendarController<CalendarEvent> _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController<CalendarEvent>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarBloc<CalendarEvent>()
        ..add(CalendarInitialize<CalendarEvent>(widget.events)),
      child: BlocBuilder<CalendarBloc<CalendarEvent>, CalendarState<CalendarEvent>>(
        builder: (context, state) {
          return MonthView<CalendarEvent>(
            controller: _controller,
            itemBuilder: (context, event) => _buildEventIndicator(event),
            onDateTap: widget.onDateTap,
            // Customization
            theme: MonthViewTheme(
              backgroundColor: Colors.white,
              monthDayTheme: MonthDayTheme(
                backgroundColor: Colors.transparent,
                selectedBackgroundColor: Colors.blue.shade100,
                todayBackgroundColor: Colors.blue.shade50,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                selectedTextStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              daysRowTheme: DaysRowTheme(
                backgroundColor: Colors.grey.shade100,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventIndicator(CalendarEvent event) {
    return Container(
      width: 6,
      height: 6,
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: _getEventColor(event),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    if (event is MySimpleEvent) {
      return event.eventColor;
    } else if (event is TaskDue) {
      return Colors.orange;
    } else if (event is Break) {
      return Colors.grey;
    }
    return Colors.blue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Event Management

### Event Creation Helper

Create a helper class for managing events:

```dart
// File: lib/custom_code/helpers/calendar_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar_events.dart';

class CalendarHelper {
  static const _uuid = Uuid();

  static Future<CalendarEvent?> showAddEventDialog(
    BuildContext context,
    DateTime selectedDate,
  ) async {
    return await showDialog<CalendarEvent>(
      context: context,
      builder: (context) => AddEventDialog(selectedDate: selectedDate),
    );
  }

  static MySimpleEvent createSimpleEvent({
    required DateTime start,
    required Duration duration,
    required String title,
    String description = '',
    Color color = Colors.blue,
  }) {
    return MySimpleEvent(
      id: _uuid.v4(),
      start: start,
      duration: duration,
      title: title,
      description: description,
      eventColor: color,
    );
  }

  static MyTaskDue createTaskDue({
    required DateTime start,
    required String title,
    String description = '',
  }) {
    return MyTaskDue(
      id: _uuid.v4(),
      start: start,
      title: title,
      description: description,
    );
  }

  static Break createBreak({
    required DateTime start,
    required Duration duration,
    String title = 'Break',
  }) {
    return Break(
      id: _uuid.v4(),
      start: start,
      duration: duration,
      title: title,
    );
  }
}

class AddEventDialog extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventDialog({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  EventType _selectedType = EventType.simple;
  TimeOfDay _startTime = TimeOfDay.now();
  int _durationHours = 1;
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<EventType>(
              value: _selectedType,
              decoration: InputDecoration(labelText: 'Event Type'),
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Start Time'),
              subtitle: Text(_startTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (time != null) {
                  setState(() => _startTime = time);
                }
              },
            ),
            if (_selectedType != EventType.task) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Duration: '),
                  Slider(
                    value: _durationHours.toDouble(),
                    min: 0.5,
                    max: 8.0,
                    divisions: 15,
                    label: '${_durationHours}h',
                    onChanged: (value) => setState(() => _durationHours = value.toInt()),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.teal,
              ].map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createEvent,
          child: Text('Add'),
        ),
      ],
    );
  }

  void _createEvent() {
    if (_titleController.text.isEmpty) return;

    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    CalendarEvent event;

    switch (_selectedType) {
      case EventType.simple:
        event = CalendarHelper.createSimpleEvent(
          start: startDateTime,
          duration: Duration(hours: _durationHours),
          title: _titleController.text,
          description: _descriptionController.text,
          color: _selectedColor,
        );
        break;
      case EventType.task:
        event = CalendarHelper.createTaskDue(
          start: startDateTime,
          title: _titleController.text,
          description: _descriptionController.text,
        );
        break;
      case EventType.break:
        event = CalendarHelper.createBreak(
          start: startDateTime,
          duration: Duration(hours: _durationHours),
          title: _titleController.text,
        );
        break;
    }

    Navigator.of(context).pop(event);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

enum EventType { simple, task, break }
```

## FlutterFlow-Specific Implementation

### 1. Creating a Calendar Page in FlutterFlow

1. **Create a new page** in FlutterFlow called "CalendarPage"
2. **Add Custom Code Widget** to the page
3. **Configure the Custom Code Widget:**
   - Widget Name: `CustomCalendarWidget`
   - Parameters:
     - `events` (List<dynamic>)
     - `viewType` (String) - "day", "week", "month"
     - `onEventTap` (Function)

### 2. Custom Calendar Widget for FlutterFlow

```dart
// File: lib/custom_code/widgets/custom_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'custom_days_view.dart';
import 'custom_week_view.dart';
import 'custom_month_view.dart';
import '../models/calendar_events.dart';
import '../helpers/calendar_helper.dart';

class CustomCalendarWidget extends StatefulWidget {
  final List<dynamic>? events;
  final String viewType;
  final Function? onEventTap;
  final Function? onEventAdd;
  final Function? onEventUpdate;

  const CustomCalendarWidget({
    Key? key,
    this.events,
    this.viewType = 'month',
    this.onEventTap,
    this.onEventAdd,
    this.onEventUpdate,
  }) : super(key: key);

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  List<CalendarEvent> _calendarEvents = [];

  @override
  void initState() {
    super.initState();
    _convertEvents();
  }

  @override
  void didUpdateWidget(CustomCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.events != oldWidget.events) {
      _convertEvents();
    }
  }

  void _convertEvents() {
    _calendarEvents = (widget.events ?? [])
        .map((e) => _convertToCalendarEvent(e))
        .where((e) => e != null)
        .cast<CalendarEvent>()
        .toList();
  }

  CalendarEvent? _convertToCalendarEvent(dynamic eventData) {
    try {
      if (eventData is Map<String, dynamic>) {
        final type = eventData['type'] as String? ?? 'simple';
        final title = eventData['title'] as String? ?? 'Event';
        final startStr = eventData['start'] as String?;
        final durationMinutes = eventData['durationMinutes'] as int? ?? 60;
        
        if (startStr == null) return null;
        
        final start = DateTime.parse(startStr);
        final duration = Duration(minutes: durationMinutes);
        
        switch (type) {
          case 'simple':
            return MySimpleEvent(
              id: eventData['id'] as String? ?? '',
              start: start,
              duration: duration,
              title: title,
              description: eventData['description'] as String? ?? '',
              eventColor: _parseColor(eventData['color']),
            );
          case 'task':
            return MyTaskDue(
              id: eventData['id'] as String? ?? '',
              start: start,
              title: title,
              description: eventData['description'] as String? ?? '',
            );
          case 'break':
            return Break(
              id: eventData['id'] as String? ?? '',
              start: start,
              duration: duration,
              title: title,
            );
        }
      }
    } catch (e) {
      print('Error converting event: $e');
    }
    return null;
  }

  Color _parseColor(dynamic colorData) {
    if (colorData is String) {
      switch (colorData.toLowerCase()) {
        case 'red': return Colors.red;
        case 'green': return Colors.green;
        case 'blue': return Colors.blue;
        case 'orange': return Colors.orange;
        case 'purple': return Colors.purple;
        case 'teal': return Colors.teal;
        default: return Colors.blue;
      }
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          _buildViewSelector(),
          Expanded(child: _buildCalendarView()),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildViewButton('Day', 'day'),
          _buildViewButton('Week', 'week'),
          _buildViewButton('Month', 'month'),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, String type) {
    final isSelected = widget.viewType == type;
    return ElevatedButton(
      onPressed: isSelected ? null : () {
        // Trigger FlutterFlow action to change viewType
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildCalendarView() {
    switch (widget.viewType) {
      case 'day':
        return CustomDaysView(
          events: _calendarEvents,
          onEventTap: (event) => widget.onEventTap?.call(event),
          onDateLongPress: _handleDateLongPress,
          onEventUpdated: _handleEventUpdate,
        );
      case 'week':
        return CustomWeekView(
          events: _calendarEvents,
          onEventTap: (event) => widget.onEventTap?.call(event),
          onDateLongPress: _handleDateLongPress,
        );
      case 'month':
      default:
        return CustomMonthView(
          events: _calendarEvents,
          onEventTap: (event) => widget.onEventTap?.call(event),
          onDateTap: _handleDateTap,
        );
    }
  }

  Future<CalendarEvent?> _handleDateLongPress(DateTime dateTime) async {
    final event = await CalendarHelper.showAddEventDialog(context, dateTime);
    if (event != null) {
      widget.onEventAdd?.call(_convertEventToMap(event));
    }
    return event;
  }

  void _handleDateTap(DateTime dateTime) {
    // Handle date tap for month view
    print('Date tapped: $dateTime');
  }

  void _handleEventUpdate(CalendarEvent oldEvent, CalendarEvent newEvent) {
    widget.onEventUpdate?.call(
      _convertEventToMap(oldEvent),
      _convertEventToMap(newEvent),
    );
  }

  Map<String, dynamic> _convertEventToMap(CalendarEvent event) {
    return {
      'id': event.id,
      'title': event.title,
      'start': event.start.toIso8601String(),
      'durationMinutes': event is SimpleEvent ? event.duration.inMinutes : 0,
      'type': event.runtimeType.toString().toLowerCase().contains('simple')
          ? 'simple'
          : event.runtimeType.toString().toLowerCase().contains('task')
              ? 'task'
              : 'break',
      'description': event is MySimpleEvent ? event.description : '',
      'color': event is MySimpleEvent ? event.eventColor.toString() : 'blue',
    };
  }
}
```

### 3. FlutterFlow Page Setup

In your FlutterFlow page:

1. **Add Custom Code Widget**
2. **Set Widget Name**: `CustomCalendarWidget`
3. **Configure Parameters**:
   - `events`: Connect to your app state variable (List of Maps)
   - `viewType`: Connect to a page state variable (String)
   - `onEventTap`: Create an action to handle event taps
   - `onEventAdd`: Create an action to add new events
   - `onEventUpdate`: Create an action to update events

### 4. Sample Event Data Structure for FlutterFlow

Create app state variables with this structure:

```dart
// App State Variable: calendarEvents (List<Map>)
[
  {
    "id": "1",
    "title": "Meeting",
    "start": "2024-01-15T10:00:00Z",
    "durationMinutes": 60,
    "type": "simple",
    "description": "Team meeting",
    "color": "blue"
  },
  {
    "id": "2",
    "title": "Task Deadline",
    "start": "2024-01-16T14:00:00Z",
    "type": "task",
    "description": "Complete project"
  }
]
```

## Customization Options

### Theme Customization

You can customize the appearance by modifying the theme properties in each view:

```dart
// Example theme customization
DaysListTheme(
  backgroundColor: Colors.white,
  dayHeaderTheme: DayHeaderTheme(
    backgroundColor: Colors.blue.shade50,
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.blue.shade800,
    ),
  ),
  timelineTheme: TimelineTheme(
    backgroundColor: Colors.grey.shade50,
    textStyle: TextStyle(
      fontSize: 12,
      color: Colors.grey.shade600,
    ),
  ),
)
```

### Event Styling

Customize event appearance in the `_buildEventTile` methods:

```dart
Widget _buildEventTile(CalendarEvent event) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [_getEventColor(event), _getEventColor(event).withOpacity(0.8)],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    // ... rest of the styling
  );
}
```

## Best Practices

1. **State Management**: Use FlutterFlow's built-in state management for event data
2. **Performance**: Limit the number of events displayed at once (consider pagination)
3. **Responsive Design**: Test on different screen sizes
4. **Error Handling**: Implement proper error handling for date parsing and event creation
5. **Accessibility**: Add proper semantic labels and accessibility features

## Troubleshooting

### Common Issues:

1. **Events not displaying**: Check event data format and date parsing
2. **Performance issues**: Reduce the number of events or implement lazy loading
3. **Theme not applying**: Ensure theme properties are properly set in the view constructors
4. **FlutterFlow build errors**: Verify all required dependencies are added

### Debug Tips:

- Use `print()` statements to debug event data conversion
- Check FlutterFlow logs for custom code errors
- Test with minimal event data first, then add complexity

This comprehensive guide should help you successfully implement the flutter_customizable_calendar package in your FlutterFlow project. The calendar will provide rich functionality for displaying and managing events with a highly customizable interface.