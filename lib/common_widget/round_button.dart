import 'package:flutter/material.dart';

import '../common/color_extension.dart';

enum RoundButtonType { bgGradient, bgSGradient , textGradient }

class RoundButton extends StatefulWidget {
  final String title;
  final RoundButtonType type;
  final Future<void> Function()? onPressed;
  final double fontSize;
  final double elevation;
  final FontWeight fontWeight;

  const RoundButton(
      {super.key,
      required this.title,
      this.type = RoundButtonType.bgGradient,
      this.fontSize = 16,
      this.elevation = 1,
      this.fontWeight = FontWeight.w700,
      this.onPressed});

  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  bool _isLoading = false;

  void _handlePress() async {
    if (widget.onPressed != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onPressed!();
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: widget.type == RoundButtonType.bgSGradient ? TColor.secondaryG :  TColor.primaryG,
              ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: widget.type == RoundButtonType.bgGradient ||  widget.type == RoundButtonType.bgSGradient 
              ? const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 0.5,
                      offset: Offset(0, 0.5))
                ]
              : null),
      child: MaterialButton(
        onPressed: _isLoading ? null : _handlePress,
        height: 50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textColor: TColor.primaryColor1,
        minWidth: double.maxFinite,
        elevation: widget.type == RoundButtonType.bgGradient ||  widget.type == RoundButtonType.bgSGradient ? 0 : widget.elevation,
        color: widget.type == RoundButtonType.bgGradient ||  widget.type == RoundButtonType.bgSGradient
            ? Colors.transparent
            : TColor.white,
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TColor.white),
              )
            : widget.type == RoundButtonType.bgGradient ||  widget.type == RoundButtonType.bgSGradient 
                ? Text(widget.title,
                    style: TextStyle(
                        color: TColor.white,
                        fontSize: widget.fontSize,
                        fontWeight: widget.fontWeight))
                : ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                              colors: TColor.primaryG,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight)
                          .createShader(
                              Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                    },
                    child: Text(widget.title,
                        style: TextStyle(
                            color:  TColor.primaryColor1,
                            fontSize: widget.fontSize,
                            fontWeight: widget.fontWeight)),
                  ),
      ),
    );
  }
}