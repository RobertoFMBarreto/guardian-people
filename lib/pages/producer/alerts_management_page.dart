import 'package:flutter/material.dart';
import 'package:guardian/models/alert.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/pages/producer/alerts_management_page/alert_management_item.dart';
import 'package:guardian/widgets/pages/producer/alerts_page/add_alert_bottom_sheet.dart';

class AlertsManagementPage extends StatefulWidget {
  const AlertsManagementPage({super.key});

  @override
  State<AlertsManagementPage> createState() => _AlertsManagementPageState();
}

class _AlertsManagementPageState extends State<AlertsManagementPage> {
  List<Alert> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    _loadAlerts().then((value) => setState(() => isLoading = false));
    super.initState();
  }

  Future<void> _loadAlerts() async {
    loadAlerts().then(
      (allAlerts) {
        alerts.addAll(allAlerts);
        isLoading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestão de Alertas',
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: ListView.builder(
                  itemCount: alerts.length,
                  padding: const EdgeInsets.only(bottom: 20.0),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => AddAlertBottomSheet(
                          comparisson: alerts[index].comparisson,
                          hasNotification: alerts[index].hasNotification,
                          parameter: alerts[index].parameter,
                          value: alerts[index].value,
                          onConfirm: (parameter, comparisson, value, hasNotification) {
                            //TODO: edit alert code
                          },
                        ),
                      );
                    },
                    child: AlertManagementItem(
                      alert: alerts[index],
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: theme.colorScheme.secondary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddAlertBottomSheet(
              onConfirm: (parameter, comparisson, value, hasNotification) {
                //TODO: Add alert code
              },
            ),
          );
        },
        label: Text(
          'Adicionar Alerta',
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }
}
