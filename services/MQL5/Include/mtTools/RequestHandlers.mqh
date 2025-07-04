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

#include <mtTools/HistoryInfo.mqh>
#include <mtTools/TradeRequest.mqh>
#include <mtTools/sockets/SocketFunctions.mqh>
#include <mtTools/Types.mqh>
#include <mtTools/AppErrors.mqh>
#include <mtTools/Utils.mqh>

//+------------------------------------------------------------------+
//| Error reporting                                                  |
//+------------------------------------------------------------------+
bool CheckError(ClientSocket &client, string funcName)
{
  int lastError = mControl.mGetLastError();
  if (lastError)
  {
    string desc = mControl.mGetDesc();

    Print("Error handling source: ", funcName, " description: ", desc);
    mControl.Check();
    ActionDoneOrError(client, lastError, funcName, desc);
    return true;
  }
  else
    return false;
}

//+------------------------------------------------------------------+
//| Reconfigure the script params                                    |
//+------------------------------------------------------------------+
void ScriptConfiguration(ClientSocket &client, RequestData &rdata)
{
  string symbol = rdata.symbol;
  string chartTimeFrame = rdata.chartTimeFrame;

  ArrayResize(symbolSubscriptions, symbolSubscriptionCount + 1);
  symbolSubscriptions[symbolSubscriptionCount].symbol = symbol;
  symbolSubscriptions[symbolSubscriptionCount].chartTimeFrame = chartTimeFrame;
  // to initialze with value 0 skips the first price
  symbolSubscriptions[symbolSubscriptionCount].lastBar = 0;
  symbolSubscriptionCount++;

  CJAVal info;

  info["error"] = false;
  info["done"] = true;
  string t = info.Serialize();

  client.responseData = t;
  ServerSocketSend(client);
}

//+------------------------------------------------------------------+
//| Account information                                              |
//+------------------------------------------------------------------+
void GetAccountInfo(ClientSocket &client)
{
  CJAVal info;

  info["error"] = false;
  info["broker"] = AccountInfoString(ACCOUNT_COMPANY);
  info["currency"] = AccountInfoString(ACCOUNT_CURRENCY);
  info["server"] = AccountInfoString(ACCOUNT_SERVER);
  info["trading_allowed"] = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
  info["bot_trading"] = AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
  info["balance"] = AccountInfoDouble(ACCOUNT_BALANCE);
  info["equity"] = AccountInfoDouble(ACCOUNT_EQUITY);
  info["margin"] = AccountInfoDouble(ACCOUNT_MARGIN);
  info["margin_free"] = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
  info["margin_level"] = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
  info["time"] = string(tm); // sending time for localtime dataframe

  string t = info.Serialize();

  client.responseData = t;
  ServerSocketSend(client);
}

//+------------------------------------------------------------------+
//| Balance information                                              |
//+------------------------------------------------------------------+
void GetBalanceInfo(ClientSocket &client)
{
  CJAVal info;
  info["balance"] = AccountInfoDouble(ACCOUNT_BALANCE);
  info["equity"] = AccountInfoDouble(ACCOUNT_EQUITY);
  info["margin"] = AccountInfoDouble(ACCOUNT_MARGIN);
  info["margin_free"] = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

  string t = info.Serialize();

  client.responseData = t;
  ServerSocketSend(client);
}

//+------------------------------------------------------------------+
//| Clear symbol subscriptions and indicators                        |
//+------------------------------------------------------------------+
void ResetSubscriptionsAndIndicators(ClientSocket &client)
{
  ArrayFree(symbolSubscriptions);
  symbolSubscriptionCount = 0;

  bool error = false;
  /*
  if(ArraySize(symbolSubscriptions)!=0 || ArraySize(indicators)!=0 || ArraySize(chartWindows)!=0 || error){
    // Set to only Alert. Fails too often, this happens when i.e. the backtrader script gets aborted unexpectedly
    mControl.Check();
    mControl.mSetUserError(65540, GetErrorType(65540));
    CheckError(client, __FUNCTION__);
  }
  */
  ActionDoneOrError(client, ERR_SUCCESS, __FUNCTION__, "ERR_SUCCESS");
}

//+------------------------------------------------------------------+
//| Fetch positions information                                      |
//+------------------------------------------------------------------+
void GetPositions(ClientSocket &client)
{
  CPositionInfo mPosition;
  CJAVal data, position;

  // Get positions
  int positionsTotal = PositionsTotal();
  // Create empty array if no positions
  if (!positionsTotal)
    data["positions"].Add(position);
  // Go through positions in a loop
  for (int i = 0; i < positionsTotal; i++)
  {
    mControl.mResetLastError();

    if (mPosition.Select(PositionGetSymbol(i)))
    {
      position["id"] = PositionGetInteger(POSITION_IDENTIFIER);
      position["magic"] = PositionGetInteger(POSITION_MAGIC);
      position["symbol"] = PositionGetString(POSITION_SYMBOL);
      position["type"] = EnumToString(ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE)));
      position["time_setup"] = PositionGetInteger(POSITION_TIME);
      position["open"] = PositionGetDouble(POSITION_PRICE_OPEN);
      position["stoploss"] = PositionGetDouble(POSITION_SL);
      position["takeprofit"] = PositionGetDouble(POSITION_TP);
      position["volume"] = PositionGetDouble(POSITION_VOLUME);
      position["current"] = PositionGetDouble(POSITION_PRICE_CURRENT);
      position["profit"] = PositionGetDouble(POSITION_PROFIT);
      position["swap"] = PositionGetDouble(POSITION_SWAP);
      position["comment"] = PositionGetString(POSITION_COMMENT);

      data["error"] = (bool)false;
      data["positions"].Add(position);
    }
    CheckError(client, __FUNCTION__);
  }

  string t = data.Serialize();
  client.responseData = t;
  ServerSocketSend(client);
}

// mControl mControl;

//+------------------------------------------------------------------+
//| Fetch orders information                                         |
//+------------------------------------------------------------------+
void GetOrders(ClientSocket &client)
{
  mControl.mResetLastError();

  COrderInfo mOrder;
  CJAVal data, order;

  // Get orders
  if (HistorySelect(0, TimeCurrent()))
  {
    int ordersTotal = OrdersTotal();
    // Create empty array if no orders
    if (!ordersTotal)
    {
      data["error"] = (bool)false;
      data["orders"].Add(order);
    }

    for (int i = 0; i < ordersTotal; i++)
    {
      if (mOrder.Select(OrderGetTicket(i)))
      {
        order["id"] = (string)mOrder.Ticket();
        order["magic"] = OrderGetInteger(ORDER_MAGIC);
        order["symbol"] = OrderGetString(ORDER_SYMBOL);
        order["type"] = EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE)));
        order["time_setup"] = OrderGetInteger(ORDER_TIME_SETUP);
        order["open"] = OrderGetDouble(ORDER_PRICE_OPEN);
        order["stoploss"] = OrderGetDouble(ORDER_SL);
        order["takeprofit"] = OrderGetDouble(ORDER_TP);
        order["volume"] = OrderGetDouble(ORDER_VOLUME_INITIAL);

        data["error"] = (bool)false;
        data["orders"].Add(order);
      }

      // use string concatenation to avoid errors in the case of json parsing
      // Error handling
      CheckError(client, __FUNCTION__);
    }
  }

  string t = data.Serialize();
  client.responseData = t;
  ServerSocketSend(client);
}

//+------------------------------------------------------------------+
//| Get historical data                                              |
//+------------------------------------------------------------------+
void HistoryInfo(ClientSocket &client)
{
  // Inefficient way to handle this
  string commandString[];
  ushort u_sep = StringGetCharacter("|", 0);
  int k = StringSplit(client.requestData, u_sep, commandString);

  // string symbol = "Step Index";
  string symbol = getMessageValue(commandString[1]);
  string timeFrame = getMessageValue(commandString[2]);
  string actionType = getMessageValue(commandString[3]);

  string fromDateStr = getMessageValue(commandString[4]);
  string toDateStr = getMessageValue(commandString[5]);

  // Validate
  datetime toDate = StringToTime(toDateStr);
  if (toDate == NULL)
  {
    toDate = TimeCurrent();
  }

  datetime fromDate = StringToTime(fromDateStr);

  Print(symbol, " ", timeFrame, " ", actionType, " Dates => ", fromDate, " ", toDate);

  if (actionType == "PRICE")
  {
    if (timeFrame == "TICK")
    {
      RetrieveAndSendTickData(client, symbol, timeFrame, fromDate, toDate);
    }
    else
    {
      RetrieveAndSendBarData(client, symbol, timeFrame, fromDate, toDate);
    }
  }
  else if (actionType == "TRADES")
  {
    HandleTradeData(client);
  }
  else
  {
    mControl.mSetUserError(65538, GetErrorType(65538));
    CheckError(client, __FUNCTION__);
  }
}

//+------------------------------------------------------------------+
//| Trading request                                                   |
//+------------------------------------------------------------------+
void TradingRequest(ClientSocket &client)
{
  // Inefficient way to handle this
  string commandString[];
  ushort u_sep = StringGetCharacter("|", 0);
  int k = StringSplit(client.requestData, u_sep, commandString);

  // string symbol = "Step Index";
  string id = getMessageValue(commandString[1]);
  string actionType = getMessageValue(commandString[2]);
  string symbol = getMessageValue(commandString[3]);

  double volume = (double)getMessageValue(commandString[4]);
  double price = (double)getMessageValue(commandString[5]);

  double stopLoss = (double)getMessageValue(commandString[6]);
  double takeProfit = (double)getMessageValue(commandString[7]);
  int expiration = (int)getMessageValue(commandString[8]);

  double deviation = (double)getMessageValue(commandString[9]);
  string comment = getMessageValue(commandString[10]);

  TradeRequestData reqData;

  // Unwrap remaining request data
  reqData.id = (ulong)id; // .ToInt()
  reqData.actionType = actionType;
  reqData.symbol = symbol;

  reqData.volume = volume;
  reqData.price = (double)NormalizeDouble(price, _Digits);

  reqData.stoploss = stopLoss;
  reqData.takeprofit = takeProfit;
  reqData.expiration = expiration;

  reqData.deviation = deviation;
  reqData.comment = comment;

  TradingModule(client, reqData);
}

//+------------------------------------------------------------------+
//| Get Tick                                                       |
//+------------------------------------------------------------------+
void GetTick(ClientSocket &client)
{
  // PUB-SUB can be used for this functionality
  // put it inside the OnTick function

  // GET request handling code here
  // send an appropriate response back to the client

  // Inefficient way to handle this
  string commandString[];
  ushort u_sep = StringGetCharacter("|", 0);
  int k = StringSplit(client.requestData, u_sep, commandString);

  // string symbol = "Step Index";
  // string symbol[];
  // u_sep=StringGetCharacter("=",0);
  // k=StringSplit(commandString[1], u_sep, symbol);
  string symbol = getMessageValue(commandString[1]);

  MqlTick tick;

  ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;

  if (SymbolInfoTick(symbol, tick))
  {
    CJAVal Data;
    Data[0] = (string)tick.time_msc;
    Data[1] = (double)tick.bid;
    Data[2] = (double)tick.ask;

    CJAVal tickData;
    tickData["symbol"] = symbol;
    tickData["timeframe"] = TimeframeToString(timeframe);
    tickData["tick"].Set(Data);

    CJAVal jsonData;
    jsonData["event"] = "tick";
    jsonData["data"].Set(tickData);

    string jsonStr = jsonData.Serialize();
    // InformServerSocket(liveSocket, "/api/price/stream/tick", jsonStr, "TICK");
    client.responseData = jsonStr;
    ServerSocketSend(client);

    Print("[TICK] Sent Tick Data for ", symbol, " (", timeframe, ")");
    // Debug
    if (debug)
    {
      Print("New event on symbol: ", symbol);
      Print("data: ", jsonStr);
      // Sleep(1000);
    }
  }
  else
  {
    Print("Failed to get tick data for ", symbol, " (", timeframe, ")");
  }
}

// Handle Tick data request
void RequestHandler(ClientSocket &client)
{
  // RequestData reqData = ParseRequestData(client);
  string command = ParseRequestCommand(client);

  // if (command == "CONFIG")
  // {
  //   ScriptConfiguration(client, reqData);
  // }
  if (command == "ACCOUNT")
  {
    GetAccountInfo(client);
  }
  else if (command == "BALANCE")
  {
    GetBalanceInfo(client);
  }
  else if (command == "POSITIONS")
  {
    GetPositions(client);
  }
  else if (command == "ORDERS")
  {
    GetOrders(client);
  }
  else if (command == "TICK")
  {
    GetTick(client);
  }
  else if (command == "HISTORY")
  {
    // && !ValidateHistoryInfoRequest(reqData)
    HistoryInfo(client);
  }
  else if (command == "TRADE")
  {
    // && !ValidateTradeRequestData(reqData)
    TradingRequest(client);
  }
  // else if (command == "RESET")
  // {
  //   ResetSubscriptionsAndIndicators(client);
  // }
  // else if (command == "CALENDAR")
  // {
  //   // check the required params
  //   GetEconomicCalendar(client, reqData);
  // }
  else
  {
    SendErrorMessage(client, 09103, "unknown command");
  }
}