import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/features/approvals/data/approval_api.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';

class ApprovalRequestsCubit extends Cubit<ApprovalRequestsState> {
  final ApprovalApi api;
  ApprovalRequestsCubit(this.api) : super(const ApprovalRequestsInitial());

  Future<void> loadRequests() async {
    emit(ApprovalRequestsLoading());

    try {
      final requests = await api.fetchRequests();
      emit(ApprovalRequestsSuccess(requests));
    } on Exception {
      emit(const ApprovalRequestsFailure('تعذر تحميل الطلبات. حاول مرة اخرى'));
    }
  }
}
