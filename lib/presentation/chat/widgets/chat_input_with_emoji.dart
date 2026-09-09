import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/core/configs/theme/app_colors.dart';
import 'package:paklan/presentation/chat/widgets/emoji_picker_widget.dart';
import 'package:paklan/common/bloc/button/button_state.dart';
import 'package:paklan/common/bloc/button/button_state_cubit.dart';

/// Chat input widget with emoji picker support
class ChatInputWithEmoji extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSend;
  final String hintText;

  const ChatInputWithEmoji({
    Key? key,
    required this.messageController,
    required this.onSend,
    this.hintText = 'Mensaje',
  }) : super(key: key);

  @override
  State<ChatInputWithEmoji> createState() => _ChatInputWithEmojiState();
}

class _ChatInputWithEmojiState extends State<ChatInputWithEmoji> {
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Hide emoji picker when keyboard appears
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        // Hide keyboard when showing emoji picker
        _focusNode.unfocus();
      }
    });
  }

  void _onEmojiSelected(String emoji) {
    final text = widget.messageController.text;
    final selection = widget.messageController.selection;

    // Check if selection is valid
    final int start = selection.start >= 0 ? selection.start : text.length;
    final int end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(
      start,
      end,
      emoji,
    );

    widget.messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + emoji.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If emoji picker is open, close it instead of going back
        if (_showEmojiPicker) {
          setState(() {
            _showEmojiPicker = false;
          });
          return false; // Don't pop the route
        }
        return true; // Allow normal back navigation
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji picker
          if (_showEmojiPicker)
            EmojiPickerWidget(
              onEmojiSelected: _onEmojiSelected,
              onClose: () {
                setState(() {
                  _showEmojiPicker = false;
                });
              },
            ),

          // Divider
          const Divider(height: 1),

          // Input row with proper constraints
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              // Emoji button
              IconButton(
                onPressed: _toggleEmojiPicker,
                icon: Icon(
                  _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                  color: _showEmojiPicker ? const Color(0xFF075E54) : Colors.grey[600],
                ),
              ),

              // Text field
              Expanded(
                child: TextField(
                  controller: widget.messageController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    fillColor: AppColors.background,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    // Hide emoji picker when tapping text field
                    if (_showEmojiPicker) {
                      setState(() {
                        _showEmojiPicker = false;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 4),

              // Send button with BLoC state
              BlocBuilder<ButtonStateCubit, ButtonState>(
                builder: (context, state) {
                  return Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 4, bottom: 4),
                    child: ElevatedButton(
                      onPressed: state is ButtonLoadingState
                          ? null
                          : () {
                              if (widget.messageController.text.trim().isNotEmpty) {
                                widget.onSend();
                                // Hide emoji picker after sending
                                if (_showEmojiPicker) {
                                  setState(() {
                                    _showEmojiPicker = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: state is ButtonLoadingState
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
