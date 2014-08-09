create table dbVersion (version TEXT);
insert into dbVersion (version) values ('1.0');

create table messages(
messageID TEXT,
messageJSON TEXT,
gmailMessageID TEXT,
read INTEGER,
date REAL,
gmailthreadid TEXT,
messageBodyToBeRendered TEXT,
messageHTMLBody TEXT,
skipFlag INTEGER,
funnelJson TEXT,
categoryName TEXT,
PRIMARY KEY (messageID)
);

create table funnels(
funnelId TEXT,
funnelName TEXT,
emailAddresses TEXT,
phrases TEXT,
skipFlag INTEGER,
notificationsFlag INTEGER,
webhookIds TEXT,
funnelColor TEXT,
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
funnelId TEXT,
primary key (messageID, funnelId)
);

create table contacts(
name TEXT,
email TEXT,
thumbnail TEXT,
count INTEGER,
received_count INTEGER,
sent_count INTEGER,
sent_from_account_count INTEGER,
resource_url TEXT,
PRIMARY KEY (email)
);

CREATE INDEX messageIDIndex ON messageFilterXRef (messageID);
CREATE INDEX funnelIdIndex ON messageFilterXRef (funnelId);
