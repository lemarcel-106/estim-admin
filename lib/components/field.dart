import 'package:estim_admin_photo/components/field_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Field extends StatefulWidget {
  Field(
      {super.key,
      this.type,
      this.prefixIcon,
      this.suffixIcon,
      this.placeholder,
      this.controller,
      this.textInputAction,
      this.description,
      this.hiddenText = false,
      this.inptutType});

  dynamic prefixIcon,
      suffixIcon,
      placeholder,
      controller,
      inptutType,
      textInputAction,
      type,
      description,
      hiddenText,
      inptFormat;

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10).copyWith(top: 0, bottom: 0),
      child: BeautyTextfield(
        fontFamily: 'font1',
        wordSpacing: 0.0,
        fontWeight: FontWeight.bold,

        controller: widget.controller,
        accentColor: Color.fromARGB(206, 248, 245, 245),
        backgroundColor: Color.fromARGB(206, 184, 183, 183),
        width: double.maxFinite,
        maxLines: 1,
        height: 55.0,
        duration: Duration(milliseconds: 300),
        inputType: widget.inptutType,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: Icon(widget.suffixIcon),
        placeholder: widget.placeholder,
        textInputAction: widget.textInputAction,
        obscureText: widget.hiddenText,
        onClickSuffix: () {
          if (widget.controller.text.isEmpty &&
              (widget.type == "password" || widget.type == "text")) {
            Get.snackbar('Notification', widget.description);
          } else if (widget.controller.text.isNotEmpty &&
              widget.type == "text") {
            Get.snackbar(widget.placeholder, widget.controller.text);
          } else if (widget.controller.text.isNotEmpty &&
              widget.type == "password") {
            setState(() {
              widget.hiddenText = !widget.hiddenText;
            });
          }
        },
        // onTap: () {
        //   print('Click');
        // },
        // onChanged: (text) {
        //   print(text);
        // },
        // onSubmitted: (data) {
        //   print(data.length);
        // },
      ),
    );
  }
}
