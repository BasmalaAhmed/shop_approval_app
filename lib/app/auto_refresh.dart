import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';

class AutoRefresh extends StatefulWidget {
  const AutoRefresh({super.key, required this.child});
  final Widget child;
  @override
  State<AutoRefresh> createState() => _AutoRefreshState();
}

class _AutoRefreshState extends State<AutoRefresh> with WidgetsBindingObserver {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _refresh() {
    if (!mounted) return;
    context.read<ApprovalRequestsCubit>().refreshRequests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, bool>(
      listenWhen: (previous, current) => !previous && current,
      listener: (context, _) => _refresh(),
      child: widget.child,
    );
  }
}
