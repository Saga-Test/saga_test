import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SaPopupMenu extends StatefulWidget {
  const SaPopupMenu({
    Key? key,
    required this.child,
    required this.title,
    required this.content,
    this.height,
    this.initStateFunction,
  }) : super(key: key);

  final Widget child;
  final String title;
  final List<Widget> content;
  final double? height;
  final Future<void> Function()? initStateFunction;

  @override
  State<SaPopupMenu> createState() => _SaPopupMenuState();
}

class _SaPopupMenuState extends State<SaPopupMenu> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      splashColor: const Color(0xffE7E7EE),
      onTap: _showPopupMenu,
      child: widget.child,
    );
  }

  void _showPopupMenu() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        RenderBox renderBox =
            (widget.child.key as GlobalKey).currentContext?.findRenderObject() as RenderBox;
        Offset position = renderBox.localToGlobal(Offset.zero);
        return PopupMenuContainer(
          position: position,
          size: renderBox.size,
          title: widget.title,
          content: widget.content,
          height: widget.height,
          initStateFunction: widget.initStateFunction,
        );
      },
    );
  }
}

class PopupMenuContainer extends StatefulWidget {
  const PopupMenuContainer({
    Key? key,
    required this.position,
    required this.size,
    required this.title,
    required this.content,
    this.height,
    this.initStateFunction,
  }) : super(key: key);

  final Offset position;
  final Size size;
  final String title;
  final List<Widget> content;
  final double? height;
  final Future<void> Function()? initStateFunction;

  @override
  State<PopupMenuContainer> createState() => _PopupMenuContainerState();
}

class _PopupMenuContainerState extends State<PopupMenuContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (widget.initStateFunction != null) {
      widget.initStateFunction!();
    }

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closePopup();
        return false;
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: widget.position.dx - 300,
              top: widget.position.dy,
              right:
                  (MediaQuery.of(context).size.width - widget.position.dx) - widget.size.width,
              child: AnimatedBuilder(
                animation: _animationController.view,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    alignment: Alignment.topRight,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  height: widget.height ?? 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // DAQUI PRA BAIXO É CONTEUDO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            onPressed: _closePopup,
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      const Divider(),
                      ...widget.content
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closePopup() {
    _animationController.reverse().whenComplete(() {
      Navigator.of(context).pop();
    });
  }
}
