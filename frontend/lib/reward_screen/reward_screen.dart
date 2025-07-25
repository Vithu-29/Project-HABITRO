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
  int _achievementsRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _rewardsFuture = RewardService.getRewards();
      _achievementsRefreshKey++;
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
              Achievements(
                key: ValueKey(_achievementsRefreshKey),
                onRefresh: _refreshData,
              ),
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            double calculatedGems = enteredCoins / 1000;

            return AlertDialog(
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('1000'),
                        Image.asset('assets/icons/coin.png',
                            width: 24, height: 24),
                        const Icon(Icons.swap_horiz),
                        const Text('1'),
                        Image.asset('assets/icons/Diamond.png',
                            width: 24, height: 24),
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
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('Available coins: $currentCoins',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 16),
                    Text('You will receive: $calculatedGems gems',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext)
                          .pop(enteredCoins); // Pass value back
                    }
                  },
                  child: const Text('Convert'),
                ),
              ],
            );
          },
        );
      },
    ).then((enteredCoins) async {
      if (enteredCoins == null || enteredCoins == 0) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Call your backend
      final result = await RewardService.convertCoins(enteredCoins);

      // Dismiss loading
      Navigator.of(context).pop();

      if (!mounted) return;

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          widget.rewards['coins'] = result['coins'];
          widget.rewards['gems'] = result['gems'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Converted $enteredCoins coins to ${enteredCoins / 1000} gems!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
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
    final cycleDay = widget.rewards['streak_cycle_day'] as int;
    DateTime? lastClaimDate;
    bool isClaimedToday = false;
    double todayReward = _getTodayReward(cycleDay, lastClaimed);

    if (lastClaimed != null) {
      lastClaimDate = DateTime.parse(lastClaimed).toLocal();
      final now = DateTime.now().toLocal();
      isClaimedToday = lastClaimDate.year == now.year &&
          lastClaimDate.month == now.month &&
          lastClaimDate.day == now.day;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        //backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Daily Streak',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Streak Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Streak:',
                    style: TextStyle(color: AppColors.blackText),
                  ),
                  Text(
                    '${widget.rewards['daily_streak']} days',
                    style: TextStyle(color: AppColors.greyText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Max Streak:',
                    style: TextStyle(color: AppColors.blackText),
                  ),
                  Text(
                    '${widget.rewards['max_streak']} days',
                    style: TextStyle(color: AppColors.greyText),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Today's Reward
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      "Today's Reward",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/Diamond.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$todayReward',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Claim Button
              ElevatedButton(
                onPressed: isClaimedToday
                    ? null
                    : () async {
                        Navigator.pop(context);
                        final result = await RewardService.claimStreak();
                        setState(() {
                          widget.rewards['daily_streak'] =
                              result['daily_streak'];
                          widget.rewards['max_streak'] = result['max_streak'];
                          widget.rewards['gems'] = result['gems'];
                          widget.rewards['last_claim_date'] =
                              result['last_claim_date'];
                          widget.rewards['streak_cycle_day'] =
                              result['streak_cycle_day'];
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isClaimedToday ? Colors.grey : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  isClaimedToday ? 'Already Claimed' : 'Claim',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTodayReward(int cycleDay, String? lastClaimed) {
    const rewards = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 1.0];

    if (lastClaimed == null) return rewards[0];

    final lastClaimDate = DateTime.parse(lastClaimed).toLocal();
    final now = DateTime.now().toLocal();
    final isConsecutive = now.difference(lastClaimDate).inDays == 1;

    return isConsecutive ? rewards[(cycleDay + 1) % 7] : rewards[0];
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
