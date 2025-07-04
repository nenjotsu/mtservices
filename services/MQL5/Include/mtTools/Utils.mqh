//+------------------------------------------------------------------+
//|                 WiseFinanceSocketServer                           |
//|              Copyright 2023, Fortesense Labs.                     |
//|              https://www.github.com/FortesenseLabs                           |
//+------------------------------------------------------------------+
// Reference:
// - https://github.com/ejtraderLabs/Metatrader5-Docker
// - https://www.mql5.com/en/code/280
// - ejTrader

#property copyright "Copyright 2023, Fortesense Labs."
#property link "https://www.github.com/FortesenseLabs"
#property version "0.10"
#property description "Wise Finance Socket Server History Info Processor"

//+------------------------------------------------------------------+
//| Convert enum chart timeframe to string                           |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES timeframe)
{
  string tf;

  switch (timeframe)
  {
  case PERIOD_CURRENT:
    tf = "TICK";
    break;
  case PERIOD_M1:
    tf = "M1";
    break;
  case PERIOD_M5:
    tf = "M5";
    break;
  case PERIOD_M15:
    tf = "M15";
    break;
  case PERIOD_M30:
    tf = "M30";
    break;
  case PERIOD_H1:
    tf = "H1";
    break;
  case PERIOD_H2:
    tf = "H2";
    break;
  case PERIOD_H3:
    tf = "H3";
    break;
  case PERIOD_H4:
    tf = "H4";
    break;
  case PERIOD_H6:
    tf = "H6";
    break;
  case PERIOD_H8:
    tf = "H8";
    break;
  case PERIOD_H12:
    tf = "H12";
    break;
  case PERIOD_D1:
    tf = "D1";
    break;
  case PERIOD_W1:
    tf = "W1";
    break;
  case PERIOD_MN1:
    tf = "MN1";
    break;
  default:
    tf = "UNKNOWN";
    break;
  }

  return tf;
}

//+------------------------------------------------------------------+
//| Convert chart timeframe from string to enum                      |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES GetTimeframe(string timeframe)
{

  ENUM_TIMEFRAMES tf;
  tf = NULL;

  if (timeframe == "TICK")
    tf = PERIOD_CURRENT;

  if (timeframe == "M1")
    tf = PERIOD_M1;

  if (timeframe == "M5")
    tf = PERIOD_M5;

  if (timeframe == "M15")
    tf = PERIOD_M15;

  if (timeframe == "M30")
    tf = PERIOD_M30;

  if (timeframe == "H1")
    tf = PERIOD_H1;

  if (timeframe == "H2")
    tf = PERIOD_H2;

  if (timeframe == "H3")
    tf = PERIOD_H3;

  if (timeframe == "H4")
    tf = PERIOD_H4;

  if (timeframe == "H6")
    tf = PERIOD_H6;

  if (timeframe == "H8")
    tf = PERIOD_H8;

  if (timeframe == "H12")
    tf = PERIOD_H12;

  if (timeframe == "D1")
    tf = PERIOD_D1;

  if (timeframe == "W1")
    tf = PERIOD_W1;

  if (timeframe == "MN1")
    tf = PERIOD_MN1;

  // if tf == NULL an error will be raised in config function
  return (tf);
}

//+------------------------------------------------------------------+
//| Get retcode message by retcode id                                |
//+------------------------------------------------------------------+
string GetRetcodeID(int retcode)
{

  switch (retcode)
  {
  case 10004:
    return ("TRADE_RETCODE_REQUOTE");
    break;
  case 10006:
    return ("TRADE_RETCODE_REJECT");
    break;
  case 10007:
    return ("TRADE_RETCODE_CANCEL");
    break;
  case 10008:
    return ("TRADE_RETCODE_PLACED");
    break;
  case 10009:
    return ("TRADE_RETCODE_DONE");
    break;
  case 10010:
    return ("TRADE_RETCODE_DONE_PARTIAL");
    break;
  case 10011:
    return ("TRADE_RETCODE_ERROR");
    break;
  case 10012:
    return ("TRADE_RETCODE_TIMEOUT");
    break;
  case 10013:
    return ("TRADE_RETCODE_INVALID");
    break;
  case 10014:
    return ("TRADE_RETCODE_INVALID_VOLUME");
    break;
  case 10015:
    return ("TRADE_RETCODE_INVALID_PRICE");
    break;
  case 10016:
    return ("TRADE_RETCODE_INVALID_STOPS");
    break;
  case 10017:
    return ("TRADE_RETCODE_TRADE_DISABLED");
    break;
  case 10018:
    return ("TRADE_RETCODE_MARKET_CLOSED");
    break;
  case 10019:
    return ("TRADE_RETCODE_NO_MONEY");
    break;
  case 10020:
    return ("TRADE_RETCODE_PRICE_CHANGED");
    break;
  case 10021:
    return ("TRADE_RETCODE_PRICE_OFF");
    break;
  case 10022:
    return ("TRADE_RETCODE_INVALID_EXPIRATION");
    break;
  case 10023:
    return ("TRADE_RETCODE_ORDER_CHANGED");
    break;
  case 10024:
    return ("TRADE_RETCODE_TOO_MANY_REQUESTS");
    break;
  case 10025:
    return ("TRADE_RETCODE_NO_CHANGES");
    break;
  case 10026:
    return ("TRADE_RETCODE_SERVER_DISABLES_AT");
    break;
  case 10027:
    return ("TRADE_RETCODE_CLIENT_DISABLES_AT");
    break;
  case 10028:
    return ("TRADE_RETCODE_LOCKED");
    break;
  case 10029:
    return ("TRADE_RETCODE_FROZEN");
    break;
  case 10030:
    return ("TRADE_RETCODE_INVALID_FILL");
    break;
  case 10031:
    return ("TRADE_RETCODE_CONNECTION");
    break;
  case 10032:
    return ("TRADE_RETCODE_ONLY_REAL");
    break;
  case 10033:
    return ("TRADE_RETCODE_LIMIT_ORDERS");
    break;
  case 10034:
    return ("TRADE_RETCODE_LIMIT_VOLUME");
    break;
  case 10035:
    return ("TRADE_RETCODE_INVALID_ORDER");
    break;
  case 10036:
    return ("TRADE_RETCODE_POSITION_CLOSED");
    break;
  case 10038:
    return ("TRADE_RETCODE_INVALID_CLOSE_VOLUME");
    break;
  case 10039:
    return ("TRADE_RETCODE_CLOSE_ORDER_EXIST");
    break;
  case 10040:
    return ("TRADE_RETCODE_LIMIT_POSITIONS");
    break;
  case 10041:
    return ("TRADE_RETCODE_REJECT_CANCEL");
    break;
  case 10042:
    return ("TRADE_RETCODE_LONG_ONLY");
    break;
  case 10043:
    return ("TRADE_RETCODE_SHORT_ONLY");
    break;
  case 10044:
    return ("TRADE_RETCODE_CLOSE_ONLY");
    break;

  default:
    return ("TRADE_RETCODE_UNKNOWN=" + IntegerToString(retcode));
    break;
  }
}

//+------------------------------------------------------------------+
//| Get error message by error id                                    |
//+------------------------------------------------------------------+
string GetErrorType(int errorID)
{

  switch (errorID)
  {
  // Custom errors
  case 65537:
    return ("ERR_DESERIALIZATION");
    break;
  case 65538:
    return ("ERR_WRONG_ACTION");
    break;
  case 65539:
    return ("ERR_WRONG_ACTION_TYPE");
    break;
  case 65540:
    return ("ERR_CLEAR_SUBSCRIPTIONS_FAILED");
    break;
  case 65541:
    return ("ERR_RETRIEVE_DATA_FAILED");
    break;
  case 65542:
    return ("ERR_CVS_FILE_CREATION_FAILED");
    break;
  // custom errors
  case 02104:
    return ("ERR_MAX_BAR_COUNT_EXCEEDED"); //  "maximum data transfer limit exceeded"
    break;
  case 02105:
    return ("ERR_MAX_TICKS_COUNT_EXCEEDED"); //  "maximum data transfer limit exceeded"
    break;
  case 09103:
    return ("ERR_UNKNOWN_COMMAND"); 
    break;

  default:
    return ("ERR_CODE_UNKNOWN=" + IntegerToString(errorID));
    break;
  }
}

//+------------------------------------------------------------------+
//| Return a textual description of the deinitialization reason code |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
{
  string text = "";
  //---
  switch (reasonCode)
  {
  case REASON_ACCOUNT:
    text = "Account was changed";
    break;
  case REASON_CHARTCHANGE:
    text = "Symbol or timeframe was changed";
    break;
  case REASON_CHARTCLOSE:
    text = "Chart was closed";
    break;
  case REASON_PARAMETERS:
    text = "Input-parameter was changed";
    break;
  case REASON_RECOMPILE:
    text = "Program " + __FILE__ + " was recompiled";
    break;
  case REASON_REMOVE:
    text = "Program " + __FILE__ + " was removed from chart";
    break;
  case REASON_TEMPLATE:
    text = "New template was applied to chart";
    break;
  default:
    text = "Another reason";
  }
  //---
  return text;
}

// Function to get the value of a field in a struct
// template <typename T>
// T GetStructFieldValue(const T &structInstance, const string &fieldName)
// {
//   if (StringFind(structInstance, fieldName) == 0)
//   {
//     return structInstance;
//   }
//   else
//   {
//     return 0; // Return 0 if the field is not found
//   }
// }

// Function to get the value of a field in the struct
string GetStructFieldValue(const RequestData &structInstance, string fieldName)
{
  if (fieldName == "action")
  {
    return structInstance.action;
  }
  else if (fieldName == "actionType")
  {
    return structInstance.actionType;
  }
  else if (fieldName == "symbol")
  {
    return structInstance.symbol;
  }
  else if (fieldName == "chartTimeFrame")
  {
    return structInstance.chartTimeFrame;
  }
  else if (fieldName == "fromDate")
  {
    return structInstance.fromDate;
  }
  else if (fieldName == "toDate")
  {
    return structInstance.toDate;
  }
  else if (fieldName == "id")
  {
    return structInstance.id;
  }
  else if (fieldName == "magic")
  {
    return structInstance.magic;
  }
  else if (fieldName == "volume")
  {
    return structInstance.volume;
  }
  else if (fieldName == "price")
  {
    return structInstance.price;
  }
  else if (fieldName == "stoploss")
  {
    return structInstance.stoploss;
  }
  else if (fieldName == "takeprofit")
  {
    return structInstance.takeprofit;
  }
  else if (fieldName == "expiration")
  {
    return structInstance.expiration;
  }
  else if (fieldName == "deviation")
  {
    return structInstance.deviation;
  }
  else if (fieldName == "comment")
  {
    return structInstance.comment;
  }
  else if (fieldName == "chartId")
  {
    return structInstance.chartId;
  }
  else if (fieldName == "indicatorChartId")
  {
    return structInstance.indicatorChartId;
  }
  else if (fieldName == "chartIndicatorSubWindow")
  {
    return structInstance.chartIndicatorSubWindow;
  }
  else if (fieldName == "style")
  {
    return structInstance.style;
  }
  else
  {
    // Handle the case where the field does not exist
    Print("Field '" + fieldName + "' not found in the struct.");
    return 0;
  }
}

string getMessageValue(string message)
{
  string value[];
  ushort u_sep = StringGetCharacter("=", 0);
  int k = StringSplit(message, u_sep, value);

  if (k >= 2)
    return value[1];  // Value after '='
  else
    return "";  // Or log error / handle gracefully
}
