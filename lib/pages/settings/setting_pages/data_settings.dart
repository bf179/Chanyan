import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../services/show_snackbar.dart';

class DataSettings extends StatefulWidget {
  const DataSettings({Key? key}) : super(key: key);

  @override
  State<DataSettings> createState() => DataSettingsState();
}

class DataSettingsState extends State<DataSettings> {
  double _cacheSize = 0.0;

  Future<void> getCacheSize() async {
    Directory applicationDocumentsDirectory;
    Directory temporaryDirectory;

    try {
      applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
      temporaryDirectory = Directory(
          '${(await getTemporaryDirectory()).path}/libCachedImageData');

      final List<FileSystemEntity> entitiesTemp =
          await temporaryDirectory.list().toList();
      for (final entity in entitiesTemp) {
        if (entity is File) {
          setState(() {
            _cacheSize += getFileSize(entity);
          });
        }
      }

      final List<FileSystemEntity> entities =
          await applicationDocumentsDirectory.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          print(entity.path);
          setState(() {
            _cacheSize += getFileSize(entity);
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  double getFileSize(File file) {
    final int sizeInBytes = file.lengthSync();
    final double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }

  Future<void> deleteCache() async {
    Directory applicationDocumentsDirectory;
    Directory temporaryDirectory;

    try {
      applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
      temporaryDirectory = Directory(
          '${(await getTemporaryDirectory()).path}/libCachedImageData');

      final List<FileSystemEntity> entitiesTemp =
          await temporaryDirectory.list().toList();
      for (final entity in entitiesTemp) {
        if (entity is File) {
          await entity.delete();
        }
      }

      final List<FileSystemEntity> entities =
          await applicationDocumentsDirectory.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          await entity.delete();
        }
      }

      showCupertinoSnackbar(
        const Duration(milliseconds: 1800),
        true,
        context,
        'Cache deleted!',
      );

      setState(() {
        _cacheSize = 0.0;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    getCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.getTheme() == ThemeData.dark()
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
            : CupertinoColors.black.withOpacity(0.7),
        brightness: theme.getTheme() == ThemeData.dark()
            ? Brightness.dark
            : Brightness.light,
        leading: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          child: Transform.translate(
            offset: const Offset(-16, 0),
            child: CupertinoNavigationBarBackButton(
              previousPageTitle: 'Settings',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        border: Border.all(color: Colors.transparent),
        previousPageTitle: 'Settings',
        middle: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          child: Text(
            'Data',
            style: TextStyle(
              color: theme.getTheme() == ThemeData.dark()
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
      child: SafeArea(
          child: Column(
        children: [
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: const Text('Cache Size'),
                trailing: Text(
                  '${_cacheSize.toStringAsFixed(2)} MB',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: const Center(
                  child: Text(
                    'Delete Cache',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                onTap: () => deleteCache(),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
