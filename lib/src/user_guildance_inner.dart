import 'package:flutter/material.dart';

import '../flutter_user_guildance.dart';

typedef UserGuildanceTipBuilder = Widget? Function(
    BuildContext context, AnchorData? data);
typedef UserGuildanceDecorationBuilder = Decoration? Function(
    BuildContext context, AnchorData? data);

class UserGuidanceInner extends StatefulWidget {
  const UserGuidanceInner(
      {Key? key,
      required this.controller,
      this.duration = const Duration(milliseconds: 250),
      this.tipBuilder,
      this.slotBuilder,
      this.opacity = 0.4})
      : super(key: key);

  final UserGuidanceController controller;
  final Duration duration;
  final UserGuildanceTipBuilder? tipBuilder;
  final UserGuildanceDecorationBuilder? slotBuilder;

  final double opacity;

  @override
  _UserGuidanceInnerState createState() => _UserGuidanceInnerState();
}

class _UserGuidanceInnerState extends State<UserGuidanceInner> {
  get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.attach(context);
  }

  @override
  void didUpdateWidget(covariant UserGuidanceInner oldWidget) {
    if (_controller != oldWidget.controller) {
      _controller.attach(context);
      oldWidget.controller.detach();
    }

    super.didUpdateWidget(oldWidget);
  }

  Widget? getDefaultTipWidget(context, data) {
    if (data != null) {
      return TipWidget(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text("${data.tag}")),
        data: data,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserGuildanceModel>(
      valueListenable: _controller,
      builder: (_, value, child) {
        return AnimatedSwitcher(
          duration: widget.duration,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: value.visible
              ? SizedBox(key: const ValueKey("switch_1"), child: child)
              : const SizedBox(key: ValueKey("switch_2")),
        );
      },
      child: GestureDetector(
        onTap: _handlePressed,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color.fromARGB((widget.opacity * 255.0).toInt(), 0, 0, 0),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          backgroundBlendMode: BlendMode.dstOut,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<UserGuildanceModel>(
                      valueListenable: _controller,
                      builder: (context, value, child) {
                        final anchorData = value.data;
                        var rect = Rect.fromLTWH(
                            anchorData?.position.left ?? 0,
                            anchorData?.position.top ?? 0,
                            anchorData?.position.width ?? 0,
                            anchorData?.position.height ?? 0);
                        Decoration? decoration;
                        if (widget.slotBuilder != null) {
                          decoration = widget.slotBuilder!(context, anchorData);
                        }
                        decoration ??= const BoxDecoration(color: Colors.white);

                        return AnimatedPositioned.fromRect(
                          duration: widget.duration,
                          rect: rect,
                          child: AnimatedContainer(
                            duration: widget.duration,
                            decoration: decoration,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ValueListenableBuilder<UserGuildanceModel>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final anchorData = value.data;
                  Widget? tipWidget;
                  if (widget.tipBuilder != null) {
                    tipWidget = widget.tipBuilder!(context, anchorData);
                  } else {
                    if (anchorData?.tag != null) {
                      tipWidget = getDefaultTipWidget(context, anchorData);
                    }
                  }

                  tipWidget ??= Container();

                  return AnimatedSwitcher(
                    duration: widget.duration,
                    child: SizedBox(
                      key: ValueKey(
                          "${value.data?.step}-${value.data?.subStep}"),
                      child: tipWidget,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePressed() {
    _controller.next();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
