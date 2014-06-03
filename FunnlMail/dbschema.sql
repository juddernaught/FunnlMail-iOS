create table dbVersion (version TEXT);
insert into dbVersion (version) values ('1.0');

create table messages(
  messageID TEXT,
  messageJSON TEXT,
  read INTEGER,
  date TEXT,
  PRIMARY KEY (messageID)
);

create table funnels(
  funnelName TEXT,
  emailAddresses TEXT,
  phrases TEXT,
  PRIMARY KEY (funnelName)
);

create table emailServers(
  emailAddress TEXT,
  accessToken TEXT,
  refreshToken TEXT,
  PRIMARY KEY (emailAddress)
);

create table messageFilterXRef(
  funnelName TEXT,
  messageID TEXT,
  PRIMARY KEY (funnelName)
);

CREATE INDEX funnelNameIndex ON messageFilterXRef (funnelName);
CREATE INDEX messageIDIndex ON messageFilterXRef (messageID);

