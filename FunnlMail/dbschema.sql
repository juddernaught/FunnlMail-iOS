create table dbVersion (version TEXT);
insert into dbVersion (version) values ('1.0');

create table messages(
  messageID TEXT,
  messageJSON TEXT,
  read INTEGER,
  date REAL,
  PRIMARY KEY (messageID)
);

create table funnels(
  funnelId TEXT,
  funnelName TEXT,
  emailAddresses TEXT,
  phrases TEXT,
  PRIMARY KEY (funnelId)
);

create table emailServers(
  emailAddress TEXT,
  accessToken TEXT,
  refreshToken TEXT,
  PRIMARY KEY (emailAddress)
);

create table messageFilterXRef(
  messageID TEXT,
  funnelId TEXT
);

CREATE INDEX messageIDIndex ON messageFilterXRef (messageID);
CREATE INDEX funnelIdIndex ON messageFilterXRef (funnelId);


