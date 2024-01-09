import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/widgets/ui/animal/animal_data_info_list_item.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// Class that represents the animal history page
class AnimalHistoryPage extends StatefulWidget {
  final Animal animal;
  const AnimalHistoryPage({super.key, required this.animal});

  @override
  State<AnimalHistoryPage> createState() => _AnimalHistoryPageState();
}

class _AnimalHistoryPageState extends State<AnimalHistoryPage> {
  final _firstItemDataKey = GlobalKey();

  late Future _future;
  late DateFormat _dayDateFormat;
  late DateFormat _dateFormat;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  List<AnimalLocationsCompanion> _deviceData = [];

  bool _firstRun = true;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup of the page setting the [_selectedDate] to now and then gets the animal data
  Future<void> _setup() async {
    isSnackbarActive = false;
    _dayDateFormat = DateFormat.EEEE('PT');
    _dateFormat = DateFormat.yMMMMd('PT');
    // _dateFormat = DateFormat.yMMMEd('PT');
    await _getDeviceData();
  }

  /// Method that gets the animal data between the 00:00 hours and 23:59 hours of the [_selectedDate] day and loads into the [_deviceData] list
  ///
  /// Resets the list to prevent duplicates
  Future<void> _getDeviceData() async {
    await AnimalRequests.getAnimalActivityIntervalFromApi(
      context: context,
      startDate: _selectedDate,
      endDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        23, // hour
        59, // minute
        59, // second
      ),
      idAnimal: widget.animal.animal.idAnimal.value,
      onDataGotten: () async {
        await _getDeviceActivity();
      },
      onFailed: (statusCode) {
        if (!hasConnection && !isSnackbarActive) {
          showNoConnectionSnackBar();
        } else {
          if (statusCode == 507 || statusCode == 404) {
            if (_firstRun == true) {
              showNoConnectionSnackBar();
            }
            _firstRun = false;
          } else if (!isSnackbarActive) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          }
        }
      },
    );
  }

  /// Method that gets the animal activity between the 00:00 hours and 23:59 hours of the [_selectedDate] day and loads into the [_deviceData] list
  ///
  /// Resets the list to prevent duplicates
  Future<void> _getDeviceActivity() async {
    await _getAnimalLocalActivity().then(
      (value) async => {
        await AnimalRequests.getAnimalActivityIntervalFromApi(
          context: context,
          startDate: _selectedDate,
          endDate: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            23, // hour
            59, // minute
            59, // second
          ),
          idAnimal: widget.animal.animal.idAnimal.value,
          onDataGotten: () async {
            await _getAnimalLocalActivity();
          },
          onFailed: (statusCode) {
            if (!hasConnection && !isSnackbarActive) {
              showNoConnectionSnackBar();
            } else {
              if (statusCode == 507 || statusCode == 404) {
                if (_firstRun == true) {
                  showNoConnectionSnackBar();
                }
                _firstRun = false;
              } else if (!isSnackbarActive) {
                AppLocalizations localizations = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(localizations.server_error)));
              }
            }
          },
        ),
      },
    );
  }

  Future<void> _getAnimalLocalActivity() async {
    await getAnimalActivity(
      startDate: _selectedDate,
      endDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        23, // hour
        59, // minute
        59, // second
      ),
      idAnimal: widget.animal.animal.idAnimal.value,
    ).then((newDeviceData) {
      setState(() {
        _deviceData = [];
        _deviceData.addAll(newDeviceData);
      });
    });
  }

  /// Method that shows the date picker dialogue
  void _showDateDateSelector(
    BuildContext context,
    AppLocalizations localizations, {
    required Function(DateTime) onDateChange,
    required DateTime date,
    required DateTime maxDate,
  }) {
    DateTime newDate = _selectedDate;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        ThemeData theme = Theme.of(ctx);
        AppLocalizations localizations = AppLocalizations.of(ctx)!;
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: Dialog(
            child: Container(
              constraints: kIsWeb || isBigScreen ? const BoxConstraints(maxWidth: 400) : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SfDateRangePicker(
                      onSelectionChanged: (args) {
                        final data = args.value as DateTime;
                        newDate = data;
                      },
                      selectionMode: DateRangePickerSelectionMode.single,
                      initialSelectedDate: _selectedDate,
                      initialDisplayDate: _selectedDate,
                      maxDate: maxDate,
                      selectionColor: theme.brightness == Brightness.light
                          ? gdSecondaryColor
                          : gdDarkSecondaryColor,
                      todayHighlightColor: theme.brightness == Brightness.light
                          ? gdSecondaryColor
                          : gdDarkSecondaryColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(localizations.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            onDateChange(newDate);
                          },
                          child: Text(localizations.confirm),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.state_history.capitalizeFirst!,
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            GestureDetector(
              key: _firstItemDataKey,
              onTap: () {
                _showDateDateSelector(
                  context,
                  localizations,
                  onDateChange: (newDate) async {
                    setState(() {
                      _selectedDate = newDate;
                      Navigator.of(context).pop();
                      _future = _getDeviceData();
                    });
                  },
                  date: _selectedDate,
                  maxDate: DateTime.now(),
                );
              },
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          theme.brightness == Brightness.light
                              ? gdGradientStart
                              : gdDarkGradientStart,
                          theme.brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 50,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  _dayDateFormat.format(_selectedDate).capitalize!,
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  _dateFormat.format(_selectedDate),
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(child: Center(child: CustomCircularProgressIndicator()));
                } else {
                  return _deviceData.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              localizations.no_data_to_show.capitalizeFirst!,
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              child: AnimalDataInfoList(
                                key: Key('${_deviceData}'),
                                mapKey: _firstItemDataKey,
                                deviceData: _deviceData,
                              ),
                            ),
                          ),
                        );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
