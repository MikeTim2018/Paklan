import 'package:flutter/material.dart';

/// Simple emoji picker for chat messages
class EmojiPickerWidget extends StatelessWidget {
  final Function(String) onEmojiSelected;
  final VoidCallback? onClose;

  const EmojiPickerWidget({
    Key? key,
    required this.onEmojiSelected,
    this.onClose,
  }) : super(key: key);

  // Common emoji categories
  static const List<Map<String, dynamic>> emojiCategories = [
    {
      'name': 'Smileys',
      'icon': '😊',
      'emojis': [
        '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
        '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍', '🤩',
        '😘', '😗', '😚', '😙', '🥲', '😋', '😛', '😜',
        '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐',
      ]
    },
    {
      'name': 'Gestures',
      'icon': '👍',
      'emojis': [
        '👍', '👎', '👌', '✌️', '🤞', '🤟', '🤘', '🤙',
        '👈', '👉', '👆', '👇', '☝️', '✋', '🤚', '🖐',
        '🖖', '👋', '🤝', '🙏', '💪', '🦾', '🦿', '🦵',
      ]
    },
    {
      'name': 'Emotions',
      'icon': '❤️',
      'emojis': [
        '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
        '🤎', '💔', '❣️', '💕', '💞', '💓', '💗', '💖',
        '💘', '💝', '💟', '☮️', '✝️', '☪️', '🕉', '☸️',
      ]
    },
    {
      'name': 'Objects',
      'icon': '⚽',
      'emojis': [
        '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
        '🥏', '🎱', '🪀', '🏓', '🏸', '🏒', '🏑', '🥍',
        '🏏', '🪃', '🥅', '⛳', '🪁', '🏹', '🎣', '🤿',
      ]
    },
    {
      'name': 'Food',
      'icon': '🍕',
      'emojis': [
        '🍕', '🍔', '🍟', '🌭', '🍿', '🧂', '🥓', '🥚',
        '🍳', '🧇', '🥞', '🧈', '🍞', '🥐', '🥨', '🥯',
        '🥖', '🧀', '🥗', '🥙', '🥪', '🌮', '🌯', '🫔',
      ]
    },
    {
      'name': 'Nature',
      'icon': '🌸',
      'emojis': [
        '🌸', '💮', '🏵️', '🌹', '🥀', '🌺', '🌻', '🌼',
        '🌷', '🌱', '🪴', '🌲', '🌳', '🌴', '🌵', '🌾',
        '🌿', '☘️', '🍀', '🍁', '🍂', '🍃', '🪹', '🪺',
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Prevent taps from closing
      child: Container(
        height: 260, // Reduced from 320 to prevent overflow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            
            // Title with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'Elige un emoji',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

          // Emoji grid
          Expanded(
            child: DefaultTabController(
              length: emojiCategories.length,
              child: Column(
                children: [
                  // Category tabs
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    indicatorColor: const Color(0xFF075E54),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    tabs: emojiCategories.map((category) {
                      return Tab(
                        child: Text(
                          category['icon'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      );
                    }).toList(),
                  ),

                  // Category content
                  Expanded(
                    child: TabBarView(
                      children: emojiCategories.map((category) {
                        final emojis = category['emojis'] as List<String>;
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: emojis.length,
                          itemBuilder: (context, index) {
                            final emoji = emojis[index];
                            return InkWell(
                              onTap: () => onEmojiSelected(emoji),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}
