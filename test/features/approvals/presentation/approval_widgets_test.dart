import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_cubit.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';
import 'package:shop_approval_app/core/formatters.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/buttons/custom_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/buttons/outline_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/details_bottom_bar.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/request_details_content.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/sheets/confirm_sheet.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/status_badge.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_request.dart';
import 'package:shop_approval_app/models/request_change.dart';
import '../../../helpers/approval_test_data.dart';

Widget _app(Widget body, {FakeConnectivityService? connectivity}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            ConnectivityCubit(connectivity ?? FakeConnectivityService()),
      ),
      BlocProvider(
        create: (_) => ApprovalRequestsCubit(
          MockApprovalApi(
            initialRequests: const <ApprovalRequest>[],
            responseDelay: Duration.zero,
          ),
          isOnline: () => true,
        ),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: body),
    ),
  );
}

ApprovalDecisionCommand _command() => ApprovalDecisionCommand(
  requestId: 1,
  decisionId: 'decision-test-1',
  expectedVersion: 1,
  decision: ApprovalDecision.approve,
);

void main() {
  testWidgets('attention is shown in words and in the warning color', (
    tester,
  ) async {
    const attention = 'المبلغ أعلى من المعتاد لهذا الفرع';
    final request = buildRequest(attentionMessage: attention);

    await tester.pumpWidget(
      _app(
        RequestDetailsContent(
          request: request,
          operation: const DecisionIdle(),
        ),
      ),
    );

    expect(find.text(attention), findsOneWidget);
    expect(find.text('راجع التنبيه قبل اتخاذ القرار.'), findsOneWidget);

    final badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
    expect(badge.approvalStatusStyle.label, 'يحتاج انتباه');
    expect(badge.approvalStatusStyle.foreground, AppColors.warningText);
    expect(badge.approvalStatusStyle.background, AppColors.warningBg);
  });

  testWidgets('shows the request time, and the decision time once decided', (
    tester,
  ) async {
    final pending = buildRequest();

    await tester.pumpWidget(
      _app(
        RequestDetailsContent(
          request: pending,
          operation: const DecisionIdle(),
        ),
      ),
    );

    expect(find.text('وقت الطلب'), findsOneWidget);
    expect(find.text(formatRequestTime(pending.requestedAt)), findsOneWidget);
    expect(find.text('وقت القرار'), findsNothing);

    final approved = pending.copyWith(
      version: 2,
      status: ApprovalStatus.approved,
      decidedAt: fixedNow,
      executedAsEmployee: pending.employeeName,
    );

    await tester.pumpWidget(
      _app(
        RequestDetailsContent(
          request: approved,
          operation: const DecisionIdle(),
        ),
      ),
    );

    expect(find.text('وقت القرار'), findsOneWidget);
    expect(find.text(formatRequestTime(fixedNow)), findsOneWidget);
  });

  testWidgets('an unknown outcome is clearly marked as unconfirmed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        RequestDetailsContent(
          request: buildRequest(),
          operation: DecisionUnknownOutcome(_command()),
        ),
      ),
    );

    expect(find.text('النتيجة غير مؤكدة'), findsOneWidget);
    expect(find.text('غير مؤكد بعد'), findsOneWidget);
    expect(find.textContaining('DEC-DECISION'), findsOneWidget);
  });

  testWidgets('no approve or reject while the outcome is unknown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        DetailsBottomBar(
          request: buildRequest(),
          operation: DecisionUnknownOutcome(_command()),
        ),
      ),
    );

    expect(find.text('تحقق من النتيجة'), findsOneWidget);
    expect(find.text('أعد إرسال نفس القرار'), findsOneWidget);
    expect(find.text('رفض'), findsNothing);
  });

  testWidgets('approve and reject stay disabled until the change is reviewed', (
    tester,
  ) async {
    final change = RequestChange(
      previous: buildRequest(),
      latest: buildRequest(version: 2, amountInPiastres: 134000),
    );

    await tester.pumpWidget(
      _app(
        DetailsBottomBar(
          request: change.latest,
          operation: DecisionRequestChanged(change),
        ),
      ),
    );

    expect(find.text('راجعتُ التعديل'), findsOneWidget);

    final approve = tester.widget<CustomButton>(find.byType(CustomButton));
    expect(approve.onTap, isNull);

    final reject = tester.widget<OutlineButton>(
      find.widgetWithText(OutlineButton, 'رفض'),
    );
    expect(reject.onPressed, isNull);
  });

  testWidgets('confirm sheet stays locked until the warning is reviewed', (
    tester,
  ) async {
    var confirmed = 0;
    final request = buildRequest(attentionMessage: 'المبلغ أعلى من المعتاد');

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => ConfirmSheet.show(
                context: context,
                request: request,
                onConfirm: () => confirmed++,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('المبلغ أعلى من المعتاد'), findsOneWidget);

    await tester.tap(find.text('تأكيد الموافقة'));
    await tester.pumpAndSettle();
    expect(confirmed, 0);
    expect(find.text('تأكيد الموافقة'), findsOneWidget);

    await tester.tap(find.text('راجعتُ التنبيه'));
    await tester.pump();
    await tester.tap(find.text('تأكيد الموافقة'));
    await tester.pumpAndSettle();

    expect(confirmed, 1);
  });

    testWidgets('approve and reject are disabled offline and return with the connection', (
    tester,
  ) async {
    final connectivity = FakeConnectivityService(isOnline: false);

    await tester.pumpWidget(
      _app(
        DetailsBottomBar(
          request: buildRequest(),
          operation: const DecisionIdle(),
        ),
        connectivity: connectivity,
      ),
    );

    CustomButton approve() =>
        tester.widget<CustomButton>(find.byType(CustomButton));
    OutlineButton reject() =>
        tester.widget<OutlineButton>(find.widgetWithText(OutlineButton, 'رفض'));

    expect(approve().onTap, isNull);
    expect(reject().onPressed, isNull);

    connectivity.setOnline(true);
    await tester.pump();

    expect(approve().onTap, isNotNull);
    expect(reject().onPressed, isNotNull);
  });
}
