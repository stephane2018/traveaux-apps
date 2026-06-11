import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/ta_tokens.dart';

/// Jeu d'icônes personnalisées TravauxAbidjan (duotone vert/orange, style logo).
enum TaIcons {
  pin,
  home,
  search,
  doc,
  chat,
  user,
  grid,
  wrench,
  bolt,
  paint,
  hammer,
  brick,
  drop,
  snow,
  leaf,
  key,
  shield,
  badge,
  crown,
  star,
  starHalf,
  check,
  clock,
  eye,
  wallet,
  trend,
  phone,
  send,
  camera,
  bell,
  filter,
  sort,
  plus,
  arrowLeft,
  arrowRight,
  chevronRight,
  chevronDown,
  close,
  globe,
  sun,
  moon,
  mapPin,
  calendar,
  image,
  logout,
  settings,
}

/// Icône duotone : formes principales en vert (`icMain`), accents en orange
/// (`icAcc`). En mode [mono], toute l'icône prend [color].
class TaIcon extends StatelessWidget {
  const TaIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.mono = false,
    this.color,
  });

  final TaIcons icon;
  final double size;
  final bool mono;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.ta;
    final mainColor = mono ? (color ?? tokens.text) : tokens.icMain;
    final accColor = mono ? (color ?? tokens.text) : tokens.icAcc;
    final body = _iconPaths[icon]!(_hex(mainColor), _hex(accColor));
    final opacity = mono ? (color ?? tokens.text).a : 1.0;

    final svg = SvgPicture.string(
      '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">$body</svg>',
      width: size,
      height: size,
    );
    return opacity < 1 ? Opacity(opacity: opacity, child: svg) : svg;
  }

  static String _hex(Color c) {
    final argb = c.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }
}

typedef _IconBuilder = String Function(String m, String a);

final Map<TaIcons, _IconBuilder> _iconPaths = {
  // ----- marque -----
  TaIcons.pin: (m, a) => '''
    <path d="M12 21.5c2.8-3.4 6.5-7 6.5-11A6.5 6.5 0 0 0 12 4a6.5 6.5 0 0 0-6.5 6.5c0 4 3.7 7.6 6.5 11Z" fill="$m"/>
    <circle cx="12" cy="10.5" r="4.3" fill="#fff" fill-opacity="0.92"/>
    <path d="M9.4 10.8 12 8.5l2.6 2.3v2.6H9.4v-2.6Z" fill="$a"/>''',
  // ----- navigation -----
  TaIcons.home: (m, a) => '''
    <path d="M3.5 10.6 12 3.4l8.5 7.2V20a1 1 0 0 1-1 1h-15a1 1 0 0 1-1-1v-9.4Z" fill="$m"/>
    <rect x="9.6" y="13.5" width="4.8" height="7.5" rx="1" fill="$a"/>''',
  TaIcons.search: (m, a) => '''
    <circle cx="10.5" cy="10.5" r="7" fill="$m"/>
    <circle cx="10.5" cy="10.5" r="4.2" fill="#fff" fill-opacity="0.9"/>
    <rect x="15.2" y="13.8" width="7.4" height="3.4" rx="1.7" transform="rotate(45 15.2 13.8)" fill="$a"/>''',
  TaIcons.doc: (m, a) => '''
    <path d="M5 4a2 2 0 0 1 2-2h7l5 5v13a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V4Z" fill="$m"/>
    <path d="M14 2l5 5h-5V2Z" fill="$a"/>
    <rect x="8" y="11" width="8" height="1.8" rx="0.9" fill="#fff" fill-opacity="0.85"/>
    <rect x="8" y="14.6" width="5.5" height="1.8" rx="0.9" fill="#fff" fill-opacity="0.85"/>''',
  TaIcons.chat: (m, a) => '''
    <path d="M3 6a3 3 0 0 1 3-3h12a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3h-7l-4.6 3.6c-.7.5-1.4 0-1.4-.8V17a3 3 0 0 1-2-2.8V6Z" fill="$m"/>
    <circle cx="8.5" cy="10" r="1.4" fill="#fff" fill-opacity="0.9"/>
    <circle cx="12" cy="10" r="1.4" fill="#fff" fill-opacity="0.9"/>
    <circle cx="15.5" cy="10" r="1.4" fill="$a"/>''',
  TaIcons.user: (m, a) => '''
    <circle cx="12" cy="7.5" r="4.5" fill="$m"/>
    <path d="M4 20.2c0-3.8 3.6-6.2 8-6.2s8 2.4 8 6.2c0 .9-.7 1.3-1.5 1.3h-13c-.8 0-1.5-.4-1.5-1.3Z" fill="$a"/>''',
  TaIcons.grid: (m, a) => '''
    <rect x="3" y="3" width="8" height="8" rx="2" fill="$m"/>
    <rect x="13" y="3" width="8" height="8" rx="2" fill="$m"/>
    <rect x="3" y="13" width="8" height="8" rx="2" fill="$m"/>
    <rect x="13" y="13" width="8" height="8" rx="2" fill="$a"/>''',
  // ----- métiers -----
  TaIcons.wrench: (m, a) => '''
    <path d="M20.8 6.3a5.5 5.5 0 0 1-7.4 6.9L7 19.6a2.3 2.3 0 0 1-3.2-3.2L10.2 10a5.5 5.5 0 0 1 6.9-7.4L13.9 5.8l.9 2.8 2.8.9 3.2-3.2Z" fill="$m"/>
    <circle cx="5.6" cy="18" r="1.3" fill="$a"/>''',
  TaIcons.bolt: (m, a) => '''
    <path d="M13.5 2 4.8 13.4h5.2L9.2 22l9-11.8h-5.4L13.5 2Z" fill="$a"/>''',
  TaIcons.paint: (m, a) => '''
    <path d="M3 4.5A1.5 1.5 0 0 1 4.5 3h11A1.5 1.5 0 0 1 17 4.5v3A1.5 1.5 0 0 1 15.5 9h-11A1.5 1.5 0 0 1 3 7.5v-3Z" fill="$m"/>
    <path d="M17 5.5h2.5A1.5 1.5 0 0 1 21 7v3.5c0 .8-.7 1.5-1.5 1.5H13a1 1 0 0 0-1 1v1" stroke="$m" stroke-width="2" stroke-linecap="round" fill="none"/>
    <rect x="10" y="14" width="4" height="8" rx="1.2" fill="$a"/>''',
  TaIcons.hammer: (m, a) => '''
    <path d="M3.2 18.6 11 10.8l2.5 2.5-7.8 7.8a1.7 1.7 0 0 1-2.5-2.5Z" fill="$a"/>
    <path d="M10.5 5.2c2.4-2.4 6-2.7 8.6-1l1.9 1.2-2.1.6c-.8.2-1.3.6-1.7 1.3l-.5.9 1.6 1.6c.5.5.5 1.2 0 1.7l-1 1c-.5.5-1.2.5-1.7 0L10.3 7.2c-.5-.5-.5-1.2 0-1.7l.2-.3Z" fill="$m"/>''',
  TaIcons.brick: (m, a) => '''
    <rect x="2.5" y="4" width="19" height="5" rx="1" fill="$m"/>
    <rect x="2.5" y="10.5" width="9" height="5" rx="1" fill="$a"/>
    <rect x="13" y="10.5" width="8.5" height="5" rx="1" fill="$m"/>
    <rect x="2.5" y="17" width="19" height="4.5" rx="1" fill="$m"/>''',
  TaIcons.drop: (m, a) => '''
    <path d="M12 2.5C8.5 7 5.5 10.6 5.5 14.5a6.5 6.5 0 0 0 13 0c0-3.9-3-7.5-6.5-12Z" fill="$m"/>
    <path d="M9 15a3 3 0 0 0 3 3" stroke="#fff" stroke-opacity="0.9" stroke-width="1.8" stroke-linecap="round" fill="none"/>''',
  TaIcons.snow: (m, a) => '''
    <path d="M12 2v20M3.3 7l17.4 10M3.3 17 20.7 7" stroke="$m" stroke-width="2" stroke-linecap="round"/>
    <circle cx="12" cy="12" r="2.6" fill="$a"/>''',
  TaIcons.leaf: (m, a) => '''
    <path d="M20.5 3.5C10 4 4.5 9.5 4.5 15.5c0 2.5 1.5 5 5 5 6 0 11.5-5.5 11-17Z" fill="$m"/>
    <path d="M5.5 19.5C9 14 13 10.5 18 7.5" stroke="#fff" stroke-opacity="0.85" stroke-width="1.8" stroke-linecap="round" fill="none"/>''',
  TaIcons.key: (m, a) => '''
    <circle cx="7.5" cy="7.5" r="5" fill="$m"/>
    <circle cx="7.5" cy="7.5" r="1.8" fill="#fff" fill-opacity="0.9"/>
    <path d="m10.8 10.8 9.4 9.4M17 17l2.6-2.6M14 14l2.2-2.2" stroke="$a" stroke-width="2.4" stroke-linecap="round"/>''',
  // ----- statuts -----
  TaIcons.shield: (m, a) => '''
    <path d="M12 2 4.5 5v6c0 5 3.2 8.8 7.5 11 4.3-2.2 7.5-6 7.5-11V5L12 2Z" fill="$m"/>
    <path d="m8.7 11.6 2.4 2.4 4.6-4.6" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.badge: (m, a) => '''
    <path d="M12 1.8l2.4 1.9 3-.3 1.1 2.8 2.8 1.1-.3 3 1.9 2.4-1.9 2.4.3 3-2.8 1.1-1.1 2.8-3-.3-2.4 1.9-2.4-1.9-3 .3-1.1-2.8-2.8-1.1.3-3L1.1 12.7 3 10.3l-.3-3 2.8-1.1 1.1-2.8 3 .3L12 1.8Z" fill="$m"/>
    <path d="m8.7 12.2 2.3 2.3 4.4-4.4" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.crown: (m, a) => '''
    <path d="M4 8.5 8 12l4-6 4 6 4-3.5-1.6 9a1.5 1.5 0 0 1-1.5 1.2H7.1a1.5 1.5 0 0 1-1.5-1.2L4 8.5Z" fill="$a"/>
    <circle cx="12" cy="4.6" r="1.7" fill="$m"/>''',
  TaIcons.star: (m, a) => '''
    <path d="m12 2.6 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17l-5.6 3 1.1-6.3L2.9 9.3l6.3-.9L12 2.6Z" fill="$a"/>''',
  TaIcons.starHalf: (m, a) => '''
    <path d="m12 2.6 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17l-5.6 3 1.1-6.3L2.9 9.3l6.3-.9L12 2.6Z" fill="$m" fill-opacity="0.25"/>
    <path d="M12 2.6 9.2 8.4l-6.3.9 4.6 4.4-1.1 6.3L12 17V2.6Z" fill="$a"/>''',
  TaIcons.check: (m, a) => '''
    <path d="m4.5 12.5 5 5L19.5 7" stroke="$m" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.clock: (m, a) => '''
    <circle cx="12" cy="12" r="9.5" fill="$m"/>
    <path d="M12 6.5V12l3.8 2.4" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/>''',
  TaIcons.eye: (m, a) => '''
    <path d="M12 5C6.5 5 2.6 9.4 1.5 12c1.1 2.6 5 7 10.5 7s9.4-4.4 10.5-7C21.4 9.4 17.5 5 12 5Z" fill="$m"/>
    <circle cx="12" cy="12" r="3.4" fill="$a"/>''',
  TaIcons.wallet: (m, a) => '''
    <path d="M3 7a3 3 0 0 1 3-3h11a2 2 0 0 1 2 2v1H6.5a1 1 0 0 0 0 2H20a1 1 0 0 1 1 1v8a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3V7Z" fill="$m"/>
    <circle cx="16.8" cy="14.5" r="1.6" fill="$a"/>''',
  TaIcons.trend: (m, a) => '''
    <path d="M3 17.5 9 11l4 4 7.5-8" stroke="$m" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    <path d="M15 6.5h5.5V12" stroke="$a" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" fill="none"/>''',
  // ----- actions -----
  TaIcons.phone: (m, a) => '''
    <path d="M5 3.8c.6-.7 1.7-.8 2.4-.2l2.5 2.2c.6.5.7 1.5.2 2.2l-1 1.4c1 2 2.6 3.6 4.5 4.5l1.4-1c.7-.5 1.7-.4 2.2.2l2.2 2.5c.6.7.5 1.8-.2 2.4l-1.6 1.5c-.7.7-1.8.9-2.7.5C9.6 17.6 6.4 14.4 4 9.1c-.4-.9-.2-2 .5-2.7L5 3.8Z" fill="$m"/>
    <path d="M14.5 3.5a6.5 6.5 0 0 1 6 6" stroke="$a" stroke-width="2" stroke-linecap="round" fill="none"/>''',
  TaIcons.send: (m, a) => '''
    <path d="M3 11 21 3l-8 18-2.5-7.5L3 11Z" fill="$m"/>
    <path d="m10.5 13.5 4-4" stroke="$a" stroke-width="2" stroke-linecap="round"/>''',
  TaIcons.camera: (m, a) => '''
    <path d="M3 8a2 2 0 0 1 2-2h2.3l1.4-2.2c.3-.5.8-.8 1.4-.8h3.8c.6 0 1.1.3 1.4.8L16.7 6H19a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8Z" fill="$m"/>
    <circle cx="12" cy="13" r="3.6" fill="$a"/>
    <circle cx="12" cy="13" r="1.6" fill="#fff" fill-opacity="0.92"/>''',
  TaIcons.bell: (m, a) => '''
    <path d="M12 2.8c-3.6 0-6 2.7-6 6.2 0 3.6-1.2 5-2 5.8-.5.5-.2 1.7.7 1.7h14.6c.9 0 1.2-1.2.7-1.7-.8-.8-2-2.2-2-5.8 0-3.5-2.4-6.2-6-6.2Z" fill="$m"/>
    <path d="M9.5 19.5a2.6 2.6 0 0 0 5 0h-5Z" fill="$a"/>''',
  TaIcons.filter: (m, a) => '''
    <rect x="3" y="5" width="18" height="2.4" rx="1.2" fill="$m"/>
    <rect x="6" y="10.8" width="12" height="2.4" rx="1.2" fill="$m"/>
    <rect x="9" y="16.6" width="6" height="2.4" rx="1.2" fill="$a"/>''',
  TaIcons.sort: (m, a) => '''
    <path d="M7 4v14m0 0-3.5-3.5M7 18l3.5-3.5" stroke="$m" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M17 20V6m0 0 3.5 3.5M17 6l-3.5 3.5" stroke="$a" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.plus: (m, a) => '''
    <path d="M12 4.5v15M4.5 12h15" stroke="$m" stroke-width="3" stroke-linecap="round"/>''',
  TaIcons.arrowLeft: (m, a) => '''
    <path d="M19 12H5m0 0 6-6m-6 6 6 6" stroke="$m" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.arrowRight: (m, a) => '''
    <path d="M5 12h14m0 0-6-6m6 6-6 6" stroke="$m" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.chevronRight: (m, a) => '''
    <path d="m9 5 7 7-7 7" stroke="$m" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.chevronDown: (m, a) => '''
    <path d="m6 9.5 6 6 6-6" stroke="$m" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.close: (m, a) => '''
    <path d="m6 6 12 12M18 6 6 18" stroke="$m" stroke-width="2.4" stroke-linecap="round"/>''',
  TaIcons.globe: (m, a) => '''
    <circle cx="12" cy="12" r="9.5" fill="$m"/>
    <ellipse cx="12" cy="12" rx="4.2" ry="9.5" stroke="#fff" stroke-opacity="0.85" stroke-width="1.6" fill="none"/>
    <path d="M3 12h18M4.3 7.2h15.4M4.3 16.8h15.4" stroke="#fff" stroke-opacity="0.85" stroke-width="1.6"/>''',
  TaIcons.sun: (m, a) => '''
    <circle cx="12" cy="12" r="4.6" fill="$a"/>
    <path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5 5l2.1 2.1M16.9 16.9 19 19M19 5l-2.1 2.1M7.1 16.9 5 19" stroke="$m" stroke-width="2.2" stroke-linecap="round"/>''',
  TaIcons.moon: (m, a) => '''
    <path d="M20.5 14.5A8.5 8.5 0 0 1 9.5 3.5a8.5 8.5 0 1 0 11 11Z" fill="$m"/>
    <circle cx="17" cy="6" r="1.4" fill="$a"/>''',
  TaIcons.mapPin: (m, a) => '''
    <path d="M12 21.5c2.8-3.4 6.5-7 6.5-11A6.5 6.5 0 0 0 12 4a6.5 6.5 0 0 0-6.5 6.5c0 4 3.7 7.6 6.5 11Z" fill="$m"/>
    <circle cx="12" cy="10.5" r="2.6" fill="$a"/>''',
  TaIcons.calendar: (m, a) => '''
    <rect x="3" y="4.5" width="18" height="17" rx="2.5" fill="$m"/>
    <path d="M3 9.5h18" stroke="#fff" stroke-opacity="0.6" stroke-width="1.6"/>
    <rect x="7" y="2.5" width="2.4" height="4" rx="1.2" fill="$a"/>
    <rect x="14.6" y="2.5" width="2.4" height="4" rx="1.2" fill="$a"/>
    <rect x="6.8" y="12.5" width="4" height="3" rx="1" fill="$a"/>''',
  TaIcons.image: (m, a) => '''
    <rect x="2.5" y="3.5" width="19" height="17" rx="2.5" fill="$m"/>
    <circle cx="8.4" cy="9" r="2" fill="#fff" fill-opacity="0.9"/>
    <path d="m5 18.5 4.5-5 3.5 3.5 3-3.5 4.5 5H5Z" fill="$a"/>''',
  TaIcons.logout: (m, a) => '''
    <path d="M10 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h4" stroke="$m" stroke-width="2.4" stroke-linecap="round" fill="none"/>
    <path d="M20 12H9m11 0-4-4m4 4-4 4" stroke="$a" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>''',
  TaIcons.settings: (m, a) => '''
    <path d="M10.3 2.8c.1-.5.5-.8 1-.8h1.4c.5 0 .9.3 1 .8l.4 1.8c.6.2 1.2.5 1.7 1l1.8-.6c.5-.2 1 0 1.2.5l.7 1.2c.3.4.2 1-.2 1.3l-1.4 1.2c.1.3.1.7.1 1s0 .7-.1 1l1.4 1.2c.4.3.5.9.2 1.3l-.7 1.2c-.2.5-.7.7-1.2.5l-1.8-.6c-.5.5-1.1.8-1.7 1l-.4 1.8c-.1.5-.5.8-1 .8h-1.4c-.5 0-.9-.3-1-.8l-.4-1.8a6 6 0 0 1-1.7-1l-1.8.6c-.5.2-1 0-1.2-.5l-.7-1.2c-.3-.4-.2-1 .2-1.3l1.4-1.2c-.1-.3-.1-.7-.1-1s0-.7.1-1L4.7 9.2c-.4-.3-.5-.9-.2-1.3l.7-1.2c.2-.5.7-.7 1.2-.5l1.8.6c.5-.5 1.1-.8 1.7-1l.4-2Z" fill="$m"/>
    <circle cx="12" cy="12.2" r="2.8" fill="$a"/>''',
};
