library HUDManager;

import 'dart:html';

class HUDManager 
{
  // Images
  static const ROOT = "../";
  static const FOLDER = "images/";
  static const URL_PREFIX = "url('";
  static const URL_POSTFIX = "')";
  static const PREFIX = "score_number_";
  static const POSTFIX = "_resized.png";
  
  static const score_number_0 = URL_PREFIX + ROOT + FOLDER + PREFIX + "0" + POSTFIX + URL_POSTFIX;
  static const score_number_1 = URL_PREFIX + ROOT + FOLDER + PREFIX + "1" + POSTFIX + URL_POSTFIX;
  static const score_number_2 = URL_PREFIX + ROOT + FOLDER + PREFIX + "2" + POSTFIX + URL_POSTFIX;
  static const score_number_3 = URL_PREFIX + ROOT + FOLDER + PREFIX + "3" + POSTFIX + URL_POSTFIX;
  static const score_number_4 = URL_PREFIX + ROOT + FOLDER + PREFIX + "4" + POSTFIX + URL_POSTFIX;
  static const score_number_5 = URL_PREFIX + ROOT + FOLDER + PREFIX + "5" + POSTFIX + URL_POSTFIX;
  static const score_number_6 = URL_PREFIX + ROOT + FOLDER + PREFIX + "6" + POSTFIX + URL_POSTFIX;
  static const score_number_7 = URL_PREFIX + ROOT + FOLDER + PREFIX + "7" + POSTFIX + URL_POSTFIX;
  static const score_number_8 = URL_PREFIX + ROOT + FOLDER + PREFIX + "8" + POSTFIX + URL_POSTFIX;
  static const score_number_9 = URL_PREFIX + ROOT + FOLDER + PREFIX + "9" + POSTFIX + URL_POSTFIX;

  // Selectors
  static const selector_thousands = "#div_score_digit_thousands";
  static const selector_hundredths = "#div_score_digit_hundredths";
  static const selector_tenths = "#div_score_digit_tenths";
  static const selector_ones = "#div_score_digit_ones";

  updateScore(int score) 
  {
    // Parse score on digits and update accordingly
    int thousands = score ~/ 1000;
    print(thousands);
    int hundredths = (score - thousands * 1000) ~/ 100;
    print(hundredths);
    int tenths = (score - thousands * 1000 - hundredths * 100) ~/ 10;
    print(tenths);
    int ones = score % 10;
    print(ones);

    switch (thousands) {
      case 0: querySelector(selector_thousands).style.backgroundImage = score_number_0; break;
      case 1: querySelector(selector_thousands).style.backgroundImage = score_number_1; break;
      case 2: querySelector(selector_thousands).style.backgroundImage = score_number_2; break;
      case 3: querySelector(selector_thousands).style.backgroundImage = score_number_3; break;
      case 4: querySelector(selector_thousands).style.backgroundImage = score_number_4; break;
      case 5: querySelector(selector_thousands).style.backgroundImage = score_number_5; break;
      case 6: querySelector(selector_thousands).style.backgroundImage = score_number_6; break;
      case 7: querySelector(selector_thousands).style.backgroundImage = score_number_7; break;
      case 8: querySelector(selector_thousands).style.backgroundImage = score_number_8; break;
      case 9: querySelector(selector_thousands).style.backgroundImage = score_number_9; break;
    }
    
    switch(hundredths)
    {
      case 0: querySelector(selector_hundredths).style.backgroundImage = score_number_0; break;
      case 1: querySelector(selector_hundredths).style.backgroundImage = score_number_1; break;
      case 2: querySelector(selector_hundredths).style.backgroundImage = score_number_2; break;
      case 3: querySelector(selector_hundredths).style.backgroundImage = score_number_3; break;
      case 4: querySelector(selector_hundredths).style.backgroundImage = score_number_4; break;
      case 5: querySelector(selector_hundredths).style.backgroundImage = score_number_5; break;
      case 6: querySelector(selector_hundredths).style.backgroundImage = score_number_6; break;
      case 7: querySelector(selector_hundredths).style.backgroundImage = score_number_7; break;
      case 8: querySelector(selector_hundredths).style.backgroundImage = score_number_8; break;
      case 9: querySelector(selector_hundredths).style.backgroundImage = score_number_9; break;
    }
    
    switch(tenths)
    {
      case 0: querySelector(selector_tenths).style.backgroundImage = score_number_0; break;
      case 1: querySelector(selector_tenths).style.backgroundImage = score_number_1; break;
      case 2: querySelector(selector_tenths).style.backgroundImage = score_number_2; break;
      case 3: querySelector(selector_tenths).style.backgroundImage = score_number_3; break;
      case 4: querySelector(selector_tenths).style.backgroundImage = score_number_4; break;
      case 5: querySelector(selector_tenths).style.backgroundImage = score_number_5; break;
      case 6: querySelector(selector_tenths).style.backgroundImage = score_number_6; break;
      case 7: querySelector(selector_tenths).style.backgroundImage = score_number_7; break;
      case 8: querySelector(selector_tenths).style.backgroundImage = score_number_8; break;
      case 9: querySelector(selector_tenths).style.backgroundImage = score_number_9; break;
    }
    
    switch(tenths)
     {
       case 0: querySelector(selector_ones).style.backgroundImage = score_number_0; break;
       case 1: querySelector(selector_ones).style.backgroundImage = score_number_1; break;
       case 2: querySelector(selector_ones).style.backgroundImage = score_number_2; break;
       case 3: querySelector(selector_ones).style.backgroundImage = score_number_3; break;
       case 4: querySelector(selector_ones).style.backgroundImage = score_number_4; break;
       case 5: querySelector(selector_ones).style.backgroundImage = score_number_5; break;
       case 6: querySelector(selector_ones).style.backgroundImage = score_number_6; break;
       case 7: querySelector(selector_ones).style.backgroundImage = score_number_7; break;
       case 8: querySelector(selector_ones).style.backgroundImage = score_number_8; break;
       case 9: querySelector(selector_ones).style.backgroundImage = score_number_9; break;
     }
  }
}
