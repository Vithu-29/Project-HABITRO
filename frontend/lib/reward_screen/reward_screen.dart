// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/api_services/reward_service.dart';
import 'package:frontend/reward_screen/achievements.dart';
import 'package:frontend/reward_screen/game_card.dart';
import 'package:frontend/reward_screen/quiz_card.dart';
import 'package:frontend/theme.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  Future<Map<String, dynamic>>? _rewardsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _rewardsFuture = RewardService.getRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 110,
        flexibleSpace: FutureBuilder(
          future: _rewardsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            final rewards = snapshot.data as Map<String, dynamic>;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Rewards",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _RewardsSection(rewards: rewards),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              QuizCard(onQuizCompleted: _refreshData),
              Divider(
                height: 50,
                indent: 25,
                endIndent: 25,
                color: AppColors.greyText,
              ),
              Achievements(),
              Divider(
                height: 50,
                indent: 25,
                endIndent: 25,
                color: AppColors.greyText,
              ),
              GameCard(
                onGameCompleted: _refreshData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardsSection extends StatefulWidget {
  final Map<String, dynamic> rewards;

  const _RewardsSection({required this.rewards});

  @override
  __RewardsSectionState createState() => __RewardsSectionState();
}

class __RewardsSectionState extends State<_RewardsSection> {
  //coins to gems conversion dialog
  void _showConvertDialog() {
    final currentCoins = widget.rewards['coins'] as int;
    final formKey = GlobalKey<FormState>();
    int enteredCoins = 0;
    double calculatedGems = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('1000'),
                        Image.asset(
                          'assets/icons/coin.png',
                          width: 24,
                          height: 24,
                        ),
                        Icon(Icons.swap_horiz),
                        const Text('1'),
                        Image.asset(
                          'assets/icons/Diamond.png',
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter coins',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter coins to convert';
                        }
                        final coins = int.tryParse(value);
                        if (coins == null) return 'Invalid number';
                        if (coins < 100) return 'Minimum 100 coins required';
                        if (coins > currentCoins) return 'Insufficient coins';
                        return null;
                      },
                      onChanged: (value) {
                        final coins = int.tryParse(value) ?? 0;
                        setState(() {
                          enteredCoins = coins;
                          calculatedGems = coins / 1000;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Available coins: $currentCoins',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You will receive: $calculatedGems gems',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context); // Close dialog

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      final result =
                          await RewardService.convertCoins(enteredCoins);
                      Navigator.pop(context); // Dismiss loading

                      if (result.containsKey('error')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['error']),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // Update parent state
                        if (mounted) {
                          setState(() {
                            widget.rewards['coins'] = result['coins'];
                            widget.rewards['gems'] = result['gems'];
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Converted $enteredCoins coins to $calculatedGems gems!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Convert'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RewardButton(
          iconAsset: 'assets/icons/coin.png',
          text: "${widget.rewards['coins']}",
          extraIcon: Icons.info_outline,
          onExtraPressed: () => _showPopup(context, "Earn Coins",
              "Complete quizzes, achievements, and daily streaks to earn coins!"),
        ),
        const SizedBox(width: 8),
        _RewardButton(
          iconAsset: 'assets/icons/Diamond.png',
          text: "${widget.rewards['gems']}",
          extraIcon: Icons.compare_arrows,
          onExtraPressed: _showConvertDialog,
        ),
        const SizedBox(width: 8),
        _RewardButton(
          iconAsset: 'assets/icons/fire.png',
          text:
              "${widget.rewards['daily_streak']} day${widget.rewards['daily_streak'] > 1 ? 's' : ''}",
          onPressed: () => _showStreakDialog(context),
        ),
      ],
    );
  }

  void _showStreakDialog(BuildContext context) {
    final lastClaimed = widget.rewards['last_claim_date'];
    DateTime? lastClaimDate;
    bool isClaimedToday = false;

    if (lastClaimed != null) {
      lastClaimDate = DateTime.parse(lastClaimed).toLocal();
      final now = DateTime.now().toLocal();
      isClaimedToday = lastClaimDate.year == now.year &&
          lastClaimDate.month == now.month &&
          lastClaimDate.day == now.day;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Streak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Streak: ${widget.rewards['daily_streak']} days'),
            Text('Max Streak: ${widget.rewards['max_streak']} days'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isClaimedToday
                  ? null // Disable button if already claimed
                  : () async {
                      Navigator.pop(context);
                      final result = await RewardService.claimStreak();
                      setState(() {
                        widget.rewards['daily_streak'] = result['daily_streak'];
                        widget.rewards['max_streak'] = result['max_streak'];
                        widget.rewards['gems'] = result['gems'];
                        widget.rewards['last_claim_date'] =
                            result['last_claim_date'];
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isClaimedToday
                    ? Colors.grey // Grey out if claimed
                    : Theme.of(context).primaryColor,
              ),
              child: Text(
                isClaimedToday ? 'Already Claimed' : 'Claim Today\'s Reward',
                style: TextStyle(
                  color: isClaimedToday ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

//To show reward items coins , gems , daily streak
class _RewardButton extends StatelessWidget {
  final String iconAsset;
  final String text;
  final IconData? extraIcon;
  final VoidCallback? onPressed;
  final VoidCallback? onExtraPressed;

  const _RewardButton({
    required this.iconAsset,
    required this.text,
    this.extraIcon,
    this.onPressed,
    this.onExtraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 0.1),
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50), // Shadow color
              spreadRadius: -5, // Negative spread to keep it inside
              blurRadius: 10,
              offset: Offset(0, 4), // Position
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconAsset,
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (extraIcon != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onExtraPressed,
                child: Icon(extraIcon, size: 16, color: Colors.black),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
