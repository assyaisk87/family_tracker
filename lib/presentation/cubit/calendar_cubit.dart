import 'package:family_tracker/presentation/cubit/calendar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarCubit extends Cubit<CalendarState> {

  CalendarCubit(
  ) : super(const CalendarState());
  
  void selectDay(DateTime selectedDay) {
    emit(state.copyWith(selectedDate: selectedDay));
    emit(state.copyWith(focusedDate: selectedDay));
  }
}