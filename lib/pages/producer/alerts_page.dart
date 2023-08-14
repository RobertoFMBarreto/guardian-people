import 'package:flutter/material.dart';
import 'package:guardian/models/alert.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/pages/producer/alerts_page/alert_item.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Alert> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    _loadAlerts().then((value) => setState(() => isLoading = false));
    super.initState();
  }

  Future<void> _loadAlerts() async {
    loadAlerts().then(
      (allAlerts) => alerts.addAll(allAlerts),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alertas',
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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          //!TODO: on remove all alerts
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_forever,
                              color: theme.colorScheme.error,
                            ),
                            Text(
                              'Remover Todos',
                              style: theme.textTheme.bodyLarge!.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView.builder(
                        itemCount: alerts.length,
                        itemBuilder: (context, index) => AlertItem(
                          alert: alerts[index],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: theme.colorScheme.secondary,
        onPressed: () {
          Navigator.of(context).pushNamed('/producer/alert/management');
        },
        label: Text(
          'Gerir avisos',
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(
          Icons.edit,
          color: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }
}
