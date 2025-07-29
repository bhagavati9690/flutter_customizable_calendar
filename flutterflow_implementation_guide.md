# Flutter Customizable Calendar - FlutterFlow Implementation Guide

## Overview

The `flutter_customizable_calendar` package is a feature-rich Flutter calendar widget that provides highly customizable calendar views for displaying days, weeks, and months. This guide will help you integrate it into your FlutterFlow project.

## Package Features

- **Multiple Views**: DaysView, WeekView, MonthView, and ScheduleListView
- **Dynamic Event Management**: Add, edit, and remove events dynamically
- **Customizable Themes**: Extensive theming options for all components
- **Event Types**: Support for SimpleEvent, TaskDue, Break, and custom events
- **Responsive Design**: Adapts to different screen sizes

## Step 1: Add Dependency to FlutterFlow

1. In your FlutterFlow project, go to **Settings & Integrations**
2. Navigate to **Project Dependencies**
3. Add the following dependency:

```yaml
flutter_customizable_calendar: ^0.3.8
```

## Step 2: Import Required Packages

Add these imports to your custom widgets:

```dart
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
```

## Step 3: Create Custom Widgets in FlutterFlow

### 3.1 Basic Month View Widget

Create a new **Custom Widget** in FlutterFlow:

**Widget Name**: `CustomizableMonthView`

**Parameters**:
- `events` (List<CalendarEvent>) - List of calendar events
- `onDateSelected` (Function) - Callback when date is selected
- `backgroundColor` (Color) - Background color
- `primaryColor` (Color) - Primary theme color

**Widget Code**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:intl/intl.dart';

class CustomizableMonthView extends StatefulWidget {
  const CustomizableMonthView({
    Key? key,
    required this.events,
    this.onDateSelected,
    this.backgroundColor = Colors.white,
    this.primaryColor = Colors.blue,
  }) : super(key: key);

  final List<CalendarEvent> events;
  final Function(DateTime)? onDateSelected;
  final Color backgroundColor;
  final Color primaryColor;

  @override
  State<CustomizableMonthView> createState() => _CustomizableMonthViewState();
}

class _CustomizableMonthViewState extends State<CustomizableMonthView> {
  final MonthViewController _controller = MonthViewController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: MonthView<CalendarEvent>(
        controller: _controller,
        currentDate: DateTime.now(),
        events: widget.events,
        onDateTap: (date) {
          setState(() {
            _selectedDate = date;
          });
          widget.onDateSelected?.call(date);
        },
        monthViewTheme: MonthViewTheme(
          backgroundColor: widget.backgroundColor,
          dayTheme: MonthDayTheme(
            selectedBackgroundColor: widget.primaryColor,
            todayBackgroundColor: widget.primaryColor.withOpacity(0.3),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          headerTheme: MonthHeaderTheme(
            backgroundColor: widget.primaryColor,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Event model for FlutterFlow
class CalendarEvent extends SimpleEvent {
  final String title;
  final String description;
  final Color color;

  CalendarEvent({
    required this.title,
    required this.description,
    required DateTime startDate,
    required DateTime endDate,
    this.color = Colors.blue,
  }) : super(
          startDate: startDate,
          endDate: endDate,
        );

  @override
  String get name => title;
}
```

### 3.2 Week View Widget

**Widget Name**: `CustomizableWeekView`

**Parameters**:
- `events` (List<CalendarEvent>) - List of calendar events
- `onEventTap` (Function) - Callback when event is tapped
- `backgroundColor` (Color) - Background color
- `primaryColor` (Color) - Primary theme color

**Widget Code**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';

class CustomizableWeekView extends StatefulWidget {
  const CustomizableWeekView({
    Key? key,
    required this.events,
    this.onEventTap,
    this.backgroundColor = Colors.white,
    this.primaryColor = Colors.blue,
  }) : super(key: key);

  final List<CalendarEvent> events;
  final Function(CalendarEvent)? onEventTap;
  final Color backgroundColor;
  final Color primaryColor;

  @override
  State<CustomizableWeekView> createState() => _CustomizableWeekViewState();
}

class _CustomizableWeekViewState extends State<CustomizableWeekView> {
  final WeekViewController _controller = WeekViewController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: WeekView<CalendarEvent>(
        controller: _controller,
        currentDate: DateTime.now(),
        events: widget.events,
        onEventTap: (event) {
          widget.onEventTap?.call(event);
        },
        weekViewTheme: WeekViewTheme(
          backgroundColor: widget.backgroundColor,
          dayHeaderTheme: DayHeaderTheme(
            backgroundColor: widget.primaryColor.withOpacity(0.1),
            textStyle: TextStyle(
              color: widget.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          timelineTheme: TimelineTheme(
            backgroundColor: Colors.grey.shade50,
            textStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
        eventBuilder: (context, event, details) {
          return Container(
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(4),
            child: Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
```

### 3.3 Schedule List View Widget

**Widget Name**: `CustomizableScheduleList`

**Parameters**:
- `events` (List<CalendarEvent>) - List of calendar events
- `selectedDate` (DateTime) - Currently selected date
- `onEventTap` (Function) - Callback when event is tapped

**Widget Code**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:intl/intl.dart';

class CustomizableScheduleList extends StatefulWidget {
  const CustomizableScheduleList({
    Key? key,
    required this.events,
    required this.selectedDate,
    this.onEventTap,
  }) : super(key: key);

  final List<CalendarEvent> events;
  final DateTime selectedDate;
  final Function(CalendarEvent)? onEventTap;

  @override
  State<CustomizableScheduleList> createState() => _CustomizableScheduleListState();
}

class _CustomizableScheduleListState extends State<CustomizableScheduleList> {
  final ScheduleListViewController _controller = ScheduleListViewController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScheduleListView<CalendarEvent>(
      controller: _controller,
      events: widget.events,
      currentDate: widget.selectedDate,
      onEventTap: (event) {
        widget.onEventTap?.call(event);
      },
      scheduleListTheme: ScheduleListTheme(
        backgroundColor: Colors.white,
        eventTheme: ScheduleEventTheme(
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        dayHeaderTheme: ScheduleDayHeaderTheme(
          backgroundColor: Colors.grey.shade100,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      eventBuilder: (context, event, details) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: event.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('HH:mm').format(event.startDate)} - ${DateFormat('HH:mm').format(event.endDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            onTap: () => widget.onEventTap?.call(event),
          ),
        );
      },
    );
  }
}
```

## Step 4: Create Event Management Functions

Create **Custom Functions** in FlutterFlow:

### 4.1 Create Event Function

**Function Name**: `createCalendarEvent`

**Parameters**:
- `title` (String)
- `description` (String)
- `startDate` (DateTime)
- `endDate` (DateTime)
- `color` (Color)

**Return Type**: `CalendarEvent`

**Function Code**:

```dart
CalendarEvent createCalendarEvent(
  String title,
  String description,
  DateTime startDate,
  DateTime endDate,
  Color color,
) {
  return CalendarEvent(
    title: title,
    description: description,
    startDate: startDate,
    endDate: endDate,
    color: color,
  );
}
```

### 4.2 Filter Events by Date Function

**Function Name**: `filterEventsByDate`

**Parameters**:
- `events` (List<CalendarEvent>)
- `targetDate` (DateTime)

**Return Type**: `List<CalendarEvent>`

**Function Code**:

```dart
List<CalendarEvent> filterEventsByDate(
  List<CalendarEvent> events,
  DateTime targetDate,
) {
  return events.where((event) {
    final eventDate = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
    );
    final target = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    return eventDate.isAtSameMomentAs(target);
  }).toList();
}
```

## Step 5: Sample Implementation in FlutterFlow

### 5.1 Create a Calendar Page

1. Create a new page in FlutterFlow
2. Add a **Column** widget as the main container
3. Add your **CustomizableMonthView** widget to the column
4. Add your **CustomizableScheduleList** widget below it

### 5.2 Page State Variables

Create these **Page State** variables:
- `selectedDate` (DateTime) - Currently selected date
- `calendarEvents` (List<CalendarEvent>) - List of all events

### 5.3 Sample Events Data

Initialize your events in the page's **initState**:

```dart
// Add this to your page's initState custom code
List<CalendarEvent> sampleEvents = [
  CalendarEvent(
    title: 'Team Meeting',
    description: 'Weekly team sync',
    startDate: DateTime.now().add(Duration(days: 1, hours: 9)),
    endDate: DateTime.now().add(Duration(days: 1, hours: 10)),
    color: Colors.blue,
  ),
  CalendarEvent(
    title: 'Project Deadline',
    description: 'Submit final project',
    startDate: DateTime.now().add(Duration(days: 3, hours: 17)),
    endDate: DateTime.now().add(Duration(days: 3, hours: 18)),
    color: Colors.red,
  ),
  CalendarEvent(
    title: 'Lunch Break',
    description: 'Team lunch',
    startDate: DateTime.now().add(Duration(hours: 12)),
    endDate: DateTime.now().add(Duration(hours: 13)),
    color: Colors.green,
  ),
];

setState(() {
  calendarEvents = sampleEvents;
  selectedDate = DateTime.now();
});
```

## Step 6: Advanced Features

### 6.1 Event Creation Dialog

Create a **Custom Widget** for adding new events:

**Widget Name**: `AddEventDialog`

```dart
import 'package:flutter/material.dart';

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({
    Key? key,
    required this.selectedDate,
    required this.onEventCreated,
  }) : super(key: key);

  final DateTime selectedDate;
  final Function(CalendarEvent) onEventCreated;

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
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
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() => _endTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Color: '),
                ...Colors.primaries.take(6).map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
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
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              final startDateTime = DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month,
                widget.selectedDate.day,
                _startTime.hour,
                _startTime.minute,
              );
              final endDateTime = DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month,
                widget.selectedDate.day,
                _endTime.hour,
                _endTime.minute,
              );

              final event = CalendarEvent(
                title: _titleController.text,
                description: _descriptionController.text,
                startDate: startDateTime,
                endDate: endDateTime,
                color: _selectedColor,
              );

              widget.onEventCreated(event);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Event'),
        ),
      ],
    );
  }
}
```

## Step 7: Integration Tips

### 7.1 State Management

For complex applications, consider using **Provider** or **Riverpod** for state management:

```dart
// Add to your FlutterFlow dependencies
provider: ^6.0.5

// Create a CalendarProvider
class CalendarProvider extends ChangeNotifier {
  List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();

  List<CalendarEvent> get events => _events;
  DateTime get selectedDate => _selectedDate;

  void addEvent(CalendarEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void removeEvent(CalendarEvent event) {
    _events.remove(event);
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
```

### 7.2 Data Persistence

To persist events, integrate with **Firebase** or **Supabase**:

```dart
// Firebase integration example
Future<void> saveEventToFirebase(CalendarEvent event) async {
  await FirebaseFirestore.instance.collection('events').add({
    'title': event.title,
    'description': event.description,
    'startDate': event.startDate,
    'endDate': event.endDate,
    'color': event.color.value,
  });
}

Future<List<CalendarEvent>> loadEventsFromFirebase() async {
  final snapshot = await FirebaseFirestore.instance.collection('events').get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    return CalendarEvent(
      title: data['title'],
      description: data['description'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      color: Color(data['color']),
    );
  }).toList();
}
```

## Step 8: Customization Options

### 8.1 Theme Customization

You can extensively customize the appearance:

```dart
// Custom theme example
final customTheme = MonthViewTheme(
  backgroundColor: Colors.grey.shade50,
  dayTheme: MonthDayTheme(
    selectedBackgroundColor: Colors.deepPurple,
    todayBackgroundColor: Colors.deepPurple.withOpacity(0.3),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    selectedTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  headerTheme: MonthHeaderTheme(
    backgroundColor: Colors.deepPurple,
    textStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);
```

### 8.2 Custom Event Builders

Create custom event displays:

```dart
Widget customEventBuilder(
  BuildContext context,
  CalendarEvent event,
  EventDetails details,
) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [event.color, event.color.withOpacity(0.7)],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: event.color.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (event.description.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            event.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    ),
  );
}
```

## Troubleshooting

### Common Issues:

1. **Events not showing**: Ensure event dates are properly formatted and within the visible date range
2. **Performance issues**: Limit the number of events loaded at once, implement pagination
3. **Theme not applying**: Make sure to pass the theme to the correct view component
4. **Controller errors**: Always dispose controllers in the widget's dispose method

### Performance Tips:

1. Use `ListView.builder` for large event lists
2. Implement lazy loading for events
3. Cache frequently accessed data
4. Use `const` constructors where possible

## Conclusion

This guide provides a comprehensive implementation of the flutter_customizable_calendar package in FlutterFlow. The package offers extensive customization options and can be adapted to various use cases. Remember to test thoroughly on different screen sizes and devices to ensure optimal user experience.

For more advanced features and customizations, refer to the official package documentation and example implementations.