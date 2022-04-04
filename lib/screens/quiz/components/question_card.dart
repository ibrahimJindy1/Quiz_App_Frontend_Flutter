import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_app/Statics.dart';
import 'package:quiz_app/ad_helper.dart';
import 'package:quiz_app/controllers/question_controller.dart';
import 'package:quiz_app/models/Questions.dart';
import 'package:quiz_app/screens/MainMenu/MainMenuPage.dart';
import 'package:quiz_app/utils/SizeConfig.dart';

import '../../../constants.dart';
import 'option.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    Key key,
    // it means we have to pass this
    @required this.question,
  }) : super(key: key);

  final Question question;

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

RewardedAd _rewardedAd;

// TODO: Add _isRewardedAdReady
bool _isRewardedAdReady = false;

class _QuestionCardState extends State<QuestionCard> {
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
          setState(() {
            _isRewardedAdReady = false;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a RewardedAd object
    _rewardedAd.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    QuestionController _controller = Get.put(QuestionController());
    return Container(
      height: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.w(25)),
      ),
      child: Column(
        children: [
          Text(
            widget.question.question,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.w(12),
            ),
          ),
          SizedBox(height: kDefaultPadding / 2 * textScale),
          ...List.generate(
            widget.question.options.length,
            (index) => Option(
              index: index,
              text: widget.question.options[index],
              press: () => _controller.checkAns(widget.question, index),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (!widget.question.options[0].toString().isEmpty &&
                  !widget.question.options[1].toString().isEmpty &&
                  !widget.question.options[2].toString().isEmpty &&
                  !widget.question.options[3].toString().isEmpty &&
                  Statics.help > 0)
                await _controller.TwoAnswersDelete(widget.question);
              else if (Statics.help == 0 && _isRewardedAdReady) {
                _controller.stopAnimation();
                // Navigator.pop(context);
                _rewardedAd.show(
                  onUserEarnedReward: (RewardedAd, RewardItem) async {
                    Statics.help++;
                    await fire.setHelp();
                    _controller.resetAnimation();
                  },
                );
              }
              setState(() {
                _controller.forwardAnimation();
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2 * textScale,
              height: MediaQuery.of(context).size.height / 20 * textScale,
              decoration: BoxDecoration(
                color: Statics.help > 0 ? Colors.green[600] : Colors.red[600],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.1,
                    blurRadius: 9,
                    offset: Offset(0, 6),
                  ),
                ],
                borderRadius: BorderRadius.circular(SizeConfig.w(12)),
              ),
              child: Center(
                child: Text(
                  'مساعدة  ${Statics.help}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
