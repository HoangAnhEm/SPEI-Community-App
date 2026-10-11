import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../../domain/repositories/household_repository.dart';
import '../household/household_cubit.dart';
import 'create_household_state.dart';

class CreateHouseholdCubit extends Cubit<CreateHouseholdState> {
  final HouseholdRepository _householdRepository;

  CreateHouseholdCubit(this._householdRepository) : super(CreateHouseholdInitial());

  Future<void> createHousehold(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      emit(const CreateHouseholdFailure('Vui lòng nhập tên hộ gia đình'));
      return;
    }
    if (trimmedName.length < 2) {
      emit(const CreateHouseholdFailure('Tên hộ gia đình phải có ít nhất 2 ký tự'));
      return;
    }

    emit(CreateHouseholdLoading());

    try {
      final household = await _householdRepository.createHousehold(trimmedName);
      // Nạp lại trạng thái hộ gia đình toàn cục
      getIt<HouseholdCubit>().loadHouseholdData();
      emit(CreateHouseholdSuccess(household));
    } catch (e) {
      emit(CreateHouseholdFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
