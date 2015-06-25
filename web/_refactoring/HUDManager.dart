library HUDManager;

import 'dart:html';

class HUDManager 
{
  static const ROOT         = "../";
  static const FOLDER       = "images/";
  static const PREFIX       = "score_number_";
  static const POSTFIX      = "_resized.png";
  static const URL_PREFIX   = "url('";
  static const URL_POSTFIX  = "')";
  
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

  //Score selectors and reference holders
  static const selector_thousands   = "#div_score_digit_thousands";
  static const selector_hundredths  = "#div_score_digit_hundredths";
  static const selector_tenths      = "#div_score_digit_tenths";
  static const selector_ones        = "#div_score_digit_ones";
  DivElement digitThousands;
  DivElement digitHundredths;
  DivElement digitTenths;
  DivElement digitOnes;
  
  //Health selectors and reference holders
  static const selector_heart1 = "#div_health_heart_1";
  static const selector_heart2 = "#div_health_heart_2";
  static const selector_heart3 = "#div_health_heart_3";
  DivElement healthHeart1;
  DivElement healthHeart2;
  DivElement healthHeart3;
  
  //Message selectors and reference holders
  static const selector_start = "#div_start";
  static const selector_game_over_try_again = "#div_game_over_try_again_wrapper";
  static const selector_try_again = "#div_try_again";
  DivElement start;
  DivElement gameOverTryAgain;
  DivElement tryAgain;
  
  static const selector_script_trigger = "#div_script_trigger";
  DivElement scriptTrigger;
  
  HUDManager()
  {
    digitThousands    = querySelector(selector_thousands);
    digitHundredths   = querySelector(selector_hundredths);
    digitTenths       = querySelector(selector_tenths);
    digitOnes         = querySelector(selector_ones);
    
    healthHeart1      = querySelector(selector_heart1);
    healthHeart2      = querySelector(selector_heart2);
    healthHeart3      = querySelector(selector_heart3);
    
    start             = querySelector(selector_start);
    gameOverTryAgain  = querySelector(selector_game_over_try_again);
    tryAgain          = querySelector(selector_try_again);
    
    scriptTrigger     = querySelector(selector_script_trigger);
  }
  
  updateScore(int score) 
  {
//    print("Score: " + score.toString());
    // Parse score on digits and update accordingly
    int thousands = score ~/ 1000;
    int hundredths = (score - thousands * 1000) ~/ 100;
    int tenths = (score - thousands * 1000 - hundredths * 100) ~/ 10;
    int ones = score % 10;
    
//    print("T/H/T/O: " + thousands.toString() + "/" + hundredths.toString() + "/" + tenths.toString() + "/" + ones.toString());

    switch (thousands) {
      case 0: digitThousands.style.backgroundImage = score_number_0; break;
      case 1: digitThousands.style.backgroundImage = score_number_1; break;
      case 2: digitThousands.style.backgroundImage = score_number_2; break;
      case 3: digitThousands.style.backgroundImage = score_number_3; break;
      case 4: digitThousands.style.backgroundImage = score_number_4; break;
      case 5: digitThousands.style.backgroundImage = score_number_5; break;
      case 6: digitThousands.style.backgroundImage = score_number_6; break;
      case 7: digitThousands.style.backgroundImage = score_number_7; break;
      case 8: digitThousands.style.backgroundImage = score_number_8; break;
      case 9: digitThousands.style.backgroundImage = score_number_9; break;
    }
    
    switch(hundredths)
    {
      case 0: digitHundredths.style.backgroundImage = score_number_0; break;
      case 1: digitHundredths.style.backgroundImage = score_number_1; break;
      case 2: digitHundredths.style.backgroundImage = score_number_2; break;
      case 3: digitHundredths.style.backgroundImage = score_number_3; break;
      case 4: digitHundredths.style.backgroundImage = score_number_4; break;
      case 5: digitHundredths.style.backgroundImage = score_number_5; break;
      case 6: digitHundredths.style.backgroundImage = score_number_6; break;
      case 7: digitHundredths.style.backgroundImage = score_number_7; break;
      case 8: digitHundredths.style.backgroundImage = score_number_8; break;
      case 9: digitHundredths.style.backgroundImage = score_number_9; break;
    }
    
    switch(tenths)
    {
      case 0: digitTenths.style.backgroundImage = score_number_0; break;
      case 1: digitTenths.style.backgroundImage = score_number_1; break;
      case 2: digitTenths.style.backgroundImage = score_number_2; break;
      case 3: digitTenths.style.backgroundImage = score_number_3; break;
      case 4: digitTenths.style.backgroundImage = score_number_4; break;
      case 5: digitTenths.style.backgroundImage = score_number_5; break;
      case 6: digitTenths.style.backgroundImage = score_number_6; break;
      case 7: digitTenths.style.backgroundImage = score_number_7; break;
      case 8: digitTenths.style.backgroundImage = score_number_8; break;
      case 9: digitTenths.style.backgroundImage = score_number_9; break;
    }
    
    switch(ones)
     {
       case 0: digitOnes.style.backgroundImage = score_number_0; break;
       case 1: digitOnes.style.backgroundImage = score_number_1; break;
       case 2: digitOnes.style.backgroundImage = score_number_2; break;
       case 3: digitOnes.style.backgroundImage = score_number_3; break;
       case 4: digitOnes.style.backgroundImage = score_number_4; break;
       case 5: digitOnes.style.backgroundImage = score_number_5; break;
       case 6: digitOnes.style.backgroundImage = score_number_6; break;
       case 7: digitOnes.style.backgroundImage = score_number_7; break;
       case 8: digitOnes.style.backgroundImage = score_number_8; break;
       case 9: digitOnes.style.backgroundImage = score_number_9; break;
     }
  }
  
  updateHealth(int health)
  {
    switch(health)
    {
      case 0:
            healthHeart3.style.visibility = "hidden";
            gameOverTryAgain.style.visibility = "visible";
            break;
            
      case 1: healthHeart2.style.visibility = "hidden"; break;
      case 2: healthHeart1.style.visibility = "hidden"; break;
    }
  }
  
  reset()
  {
    healthHeart1.style.visibility = "visible";
    healthHeart2.style.visibility = "visible";
    healthHeart3.style.visibility = "visible";

    updateScore(0);
    gameOverTryAgain.style.visibility = "hidden";
    
    //fadeOut animation sets the display to "none", we have to set it back;
    start.style.display = "block";
    start.style.visibility = "visible";    
  }
  
  countdown()
  {
    scriptTrigger.click(); 
  }
}
