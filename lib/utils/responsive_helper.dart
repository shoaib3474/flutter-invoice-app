import 'package:flutter/material.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveHelper {
  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return DeviceScreenType.mobile;
    } else if (width < 1200) {
      return DeviceScreenType.tablet;
    } else {
      return DeviceScreenType.desktop;
    }
  }
  
  static double getAppBarHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceScreenType.mobile:
        return 56.0;
      case DeviceScreenType.tablet:
        return 64.0;
      case DeviceScreenType.desktop:
        return 72.0;
    }
  }
  
  static double getFontSize(BuildContext context, double baseFontSize) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceScreenType.mobile:
        return baseFontSize;
      case DeviceScreenType.tablet:
        return baseFontSize * 1.1;
      case DeviceScreenType.desktop:
        return baseFontSize * 1.2;
    }
  }
  
  static EdgeInsets getScreenPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceScreenType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }
  
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceScreenType.mobile:
        return width * 0.9;
      case DeviceScreenType.tablet:
        return width * 0.7;
      case DeviceScreenType.desktop:
        return width * 0.3;
    }
  }
  
  static int getGridCrossAxisCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceScreenType.mobile:
        return 1;
      case DeviceScreenType.tablet:
        return 2;
      case DeviceScreenType.desktop:
        return 4;
    }
  }
  
  static double getGridChildAspectRatio(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceScreenType.mobile:
        return 1.2;
      case DeviceScreenType.tablet:
        return 1.3;
      case DeviceScreenType.desktop:
        return 1.4;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceScreenType deviceType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceScreenType.mobile:
            return mobile;
          case DeviceScreenType.tablet:
            return tablet ?? mobile;
          case DeviceScreenType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}
