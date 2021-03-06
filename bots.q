labels,:("\\ne";"\\ml";"\\bc";"\\df";"\\st";"\\an";"\\sn";"\\ud";"\\wk";"\\rh";"\\tv")!("news";"music";"bitcoin";"define";"stock";"antonym";"synonym";"urbandictionary";"wikipedia";"rhymes";"streaming lookup");

news:{[x;y;z]rc[;y;0]"\033[GGetting news";neg[wh](`getheadline;uct string z);}
defn:{[x;y;z] neg[wh](`dictlkup;trim "c"$3_x);}
urbd:{[x;y;z] neg[wh](`udlkup;trim "c"$3_x);}
wiki:{[x;y;z] neg[wh](`wikilkup;trim "c"$3_x);}
anty:{[x;y;z] neg[wh](`anty;trim "c"$3_x);}
syny:{[x;y;z] neg[wh](`syny;trim "c"$3_x);}
rhym:{[x;y;z] neg[wh](`rhym;trim "c"$3_x);}
strm:{[x;y;z] if[""~trim "c"$3_x;:rc[;y;0]"\033[GSTREAMBOT: usage \\tv {show or movie name}"];neg[wh](`strm;trim "c"$3_x);}
mulo:{[m;h;u]                                                                                   / [message;handle;user]
  if[()~key`:lfm_key;:rc[;h;0]"\033[Gmusic lookup not enabled"];                                / return error if unenabled
  .lfm.cache:@[get;`:lfm_cache;()!()];                                                          / load cache of lastfm usernames
  if[0=count msg:trim"c"$3_m;                                                                   / return help message if no input is provided
    options:("* enter 'user=<LFM_NAME>' to update lastfm username, leave blank to unset";
      "* usage='\\ml <USERNAME>(&<FILTER>&<PERIOD>)' OR '\\ml chart'";
      "* Filters: tracks, artists, chart\n* Periods: overall, 7day, 1month, 3month, 6month, 12month";
      "  users: ",$[0=count k:key .lfm.cache;"()";atproc", "sv "@",'string k]);
    :rc[;h;0]"\033[Gmusic lookup from lastfm enabled, available options:\n","\n"sv options;     / display available options
  ];
  if[msg like"user=*";                                                                          / update username for current user
    `:lfm_cache set$[0=count uname:(1+msg?"=")_msg;u _.lfm.cache;.lfm.cache,enlist[u]!enlist uname]; / update cache
    :rc[;h;0]"\033[GUpdated username";
  ];
  p:`$msg:("***";"&")0:msg;
  if[`chart in p;                                                                               / chart has been requested
    rc[;h;0]"\033[GSending Chart Request";
    p _:p?`chart;
    ad:`;
    if[`artists in p;ad:`artists;p _:p?`artists];
    if[not(r:p 0)in`,key .lfm.cache;:rc[;h;0]"\033[Guser not available"];                       / return error if user is unavailable
    :getchart[u;r;ad];
  ];
  msg:@[;`filter`period;lower]`name`filter`period!msg;
  if[not(`$msg`name)in key .lfm.cache;:rc[;h;0]"\033[Guser not available"];                     / return error if requested user is unavailable
  rc[;h;0]"\033[GSending Request";
  neg[wh](`.lfm.request;u;enlist[`$msg`name]#.lfm.cache;msg);                                   / send request to worker process
 };
getchart:{[u;r;ad]                                                                              / [user;request;additional] get chart for given parameters
  if[not`updatechart in cron`action;`cron insert(09:30+1+.z.D;`updatechart;`update)];           / update cron
  if[null u;                                                                                    / need to check for skipped steps if run by cron
    if[()~key`:lfm_key;:()];                                                                    / exit if unenabled
    .lfm.cache:@[get;`:lfm_cache;()!()];                                                        / load cache of lastfm usernames
    if[0=count .lfm.cache;:()];                                                                 / exit if no users are cached
  ];
  neg[wh](`.lfm.request;u;$[r=`;(::);((),r)#].lfm.cache;`filter`c!("chart";ad));                / send request
 };
updatechart:getchart[`;`];
updatechart`update;                                                                             / initialise cron job

btcp:{[x;y;z]
 a:" " vs trim"c"$3_x;
 if[1=count a;a,:enlist"0"];
 if[`~`$upper a[0];:rc[;y;0]"\033[GBITCOIN BOT HELP\nUsage: \\bc <cur/opt> [amt].\nSpecify a currency to get current value of 1BTC in currency. Optionally include an amount to convert that amount of BTC to given currency.\nAlternativley, supply an option (i.e. \"plot\") for different action e.g. \\bc plot\nSupported currencies: gbp,usd,eur,kfc. Options: plot"];
 if[not (c:`$upper a[0]) in `USD`GBP`EUR`PLOT`KFC;:rc[;y;0]"\033[GUnsupported currency/option. Supported currencies: gbp,usd,eur,kfc. Options: plot"];
 rc[;y;0]"\033[GGetting BTC price";neg[wh](`.btc.getprice;trim uct string z;c;"F"$a[1]);
 };

stkp:{[x;y;z]
  rc[;y;0]"\033[GGetting stock plot";neg[wh](`.plot.getplot;trim uct string z;`$"c"$3_x;y);
 }

workernames,:`news`music`bitcoin`defino`stock`shame`wiki`urbd`ant`syn`rhym`stream!"[",/:$[10;("NEWSBOT";"LASTFMBOT";"BTCBOT";"DICTBOT";"STOCKBOT";"SHAMEBOT";"WIKIBOT";"URBANBOT";"ANTONYMBOT";"SYNONYMBOT";"RHYMEBOT";"STREAMBOT")],\:"]:" / bot names used when printing to chat

tf,:("\\ne";"\\ml";"\\bc";"\\df";"\\st";"\\wk";"\\ud";"\\an";"\\sn";"\\rh";"\\tv")!(news;mulo;btcp;defn;stkp;wiki;urbd;anty;syny;rhym;strm);
