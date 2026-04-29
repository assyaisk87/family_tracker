import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_state.freezed.dart';

@freezed
abstract class CalendarState with _$CalendarState {
  const factory CalendarState({
    DateTime? selectedDate,
    DateTime? focusedDate,
  }) = _CalendarState;
}