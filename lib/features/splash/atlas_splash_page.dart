import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../home/home_page.dart';

class AtlasSplashPage extends StatefulWidget {
  const AtlasSplashPage({super.key});
  @override State<AtlasSplashPage> createState() => _AtlasSplashPageState();
}

class _AtlasSplashPageState extends State<AtlasSplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2300)); _start(); }
  Future<void> _start() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(transitionDuration: const Duration(milliseconds: 420), pageBuilder: (context, animation, secondaryAnimation) => const HomePage(), transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child)));
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: AtlasColors.background, body: AnimatedBuilder(animation: _controller, builder: (context, child) {
    final value = _controller.value;
    final draw = Curves.easeInOutCubic.transform((value / .62).clamp(0.0, 1.0));
    final word = Curves.easeOut.transform(((value - .48) / .25).clamp(0.0, 1.0));
    final tagline = Curves.easeOut.transform(((value - .68) / .24).clamp(0.0, 1.0));
    return DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(radius: .78, colors: [AtlasColors.green.withValues(alpha: .10 + draw * .12), AtlasColors.background])), child: SafeArea(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width:172,height:205,child:CustomPaint(painter:_AtlasLinePainter(progress:draw))), const SizedBox(height:16),
      Opacity(opacity:word,child:Transform.translate(offset:Offset(0,10*(1-word)),child:const Text('ATLAS',style:TextStyle(color:AtlasColors.white,fontSize:36,fontWeight:FontWeight.w600,letterSpacing:10)))), const SizedBox(height:7),
      Opacity(opacity:word,child:const Text('—  F I N A N C E  —',style:TextStyle(color:AtlasColors.green,fontSize:12,fontWeight:FontWeight.w600,letterSpacing:3))), const SizedBox(height:23),
      Opacity(opacity:tagline,child:const Text('Seu dinheiro. Sob controle.',style:TextStyle(color:AtlasColors.textMuted,fontSize:13,fontWeight:FontWeight.w500,letterSpacing:1.2))),
    ]))));
  }));
}

class _AtlasLinePainter extends CustomPainter {
  const _AtlasLinePainter({required this.progress}); final double progress;
  @override void paint(Canvas canvas, Size size) {
    canvas.save(); canvas.scale(size.width/172,size.height/205);
    final paint=Paint()..color=AtlasColors.green..style=PaintingStyle.stroke..strokeWidth=5..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round;
    final paths=<Path>[
      Path()..moveTo(65,27)..quadraticBezierTo(86,10,107,27)..lineTo(99,38)..quadraticBezierTo(86,32,73,38)..close(),
      Path()..moveTo(69,37)..cubicTo(42,44,33,66,36,94)..cubicTo(38,116,54,125,72,125), Path()..moveTo(102,38)..cubicTo(126,47,135,68,132,94)..cubicTo(130,111,120,120,108,123),
      Path()..moveTo(36,86)..cubicTo(22,92,24,113,38,126)..cubicTo(51,138,65,136,77,135), Path()..moveTo(132,88)..cubicTo(145,94,143,116,130,128)..cubicTo(120,137,111,136,102,134),
      Path()..addOval(const Rect.fromLTWH(79,105,39,39)), Path()..moveTo(79,130)..cubicTo(70,145,62,155,58,169)..lineTo(55,190),
      Path()..moveTo(60,164)..lineTo(83,153)..lineTo(101,160)..lineTo(79,177)..lineTo(66,190), Path()..moveTo(54,190)..lineTo(41,190)..lineTo(35,198)..cubicTo(62,194,109,194,139,199),
    ];
    for(var i=0;i<paths.length;i++){final local=(progress*paths.length-i).clamp(0.0,1.0);if(local<=0)continue;for(final metric in paths[i].computeMetrics()){canvas.drawPath(metric.extractPath(0,metric.length*local),paint);}}
    if(progress>.18){final opacity=((progress-.18)/.35).clamp(0.0,1.0);final tp=TextPainter(text:TextSpan(text:r'$',style:TextStyle(color:AtlasColors.green.withValues(alpha:opacity),fontSize:45,fontWeight:FontWeight.w500)),textDirection:TextDirection.ltr)..layout();tp.paint(canvas,const Offset(72,54));}
    canvas.restore();
  }
  @override bool shouldRepaint(covariant _AtlasLinePainter oldDelegate)=>oldDelegate.progress!=progress;
}
